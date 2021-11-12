import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'log.dart';
import 'utils/void_stream_controller.dart';
import 'wrappers/firebase_auth_wrapper.dart';
import 'wrappers/io_wrapper.dart';

enum AuthError {
  // App errors.
  invalidUserId,
  unknownFirebaseException,
  noConnection,

  // All error codes returned by Firebase login and sign up methods.
  invalidEmail,
  userDisabled,
  userNotFound,
  wrongPassword,
  emailInUse,
  operationNotAllowed,
  weakPassword,
}

enum AuthState {
  unknown,
  loggedIn,
  loggedOut,

  // Doing initialization work on login.
  initializing,
}

class AuthManager {
  static AuthManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).authManager;

  /// Firebase blocks communication if you issue too many requests for things
  /// like email verification, so we limit to once per 24 hours.
  static const _verificationEmailFrequency = Duration.millisecondsPerDay;

  static const _collectionUser = "user";

  final _log = const Log("AuthManager");
  final _controller = VoidStreamController();

  final AppManager _appManager;

  User? _user;
  var _state = AuthState.unknown;

  AuthManager(this._appManager);

  FirebaseAuthWrapper get _firebaseAuth => _appManager.firebaseAuthWrapper;

  IoWrapper get _io => _appManager.ioWrapper;

  TimeManager get _timeManager => _appManager.timeManager;

  UserPreferenceManager get _userPreferenceManager =>
      _appManager.userPreferenceManager;

  /// A [Stream] that fires events when [state] updates. Listeners should
  /// access the [state] property directly, as it will always have a valid
  /// value, unlike the [AsyncSnapshot] passed to the listener function.
  Stream<void> get stream => _controller.stream;

  AuthState get state => _state;

  String? get userId => _user?.uid;

  String? get userEmail => _firebaseAuth.currentUser?.email;

  bool get isUserVerified => _user?.emailVerified ?? false;

  String get firestoreDocPath => "$_collectionUser/$userId";

  Future<void> initialize() {
    _firebaseAuth.authStateChanges().listen((user) async {
      _user = user;

      if (_user == null) {
        _setState(AuthState.loggedOut);
      } else {
        // Update state first so managers have the latest state while
        // initializing.
        _setState(AuthState.initializing);
        await _initializeManagers();

        // Send verification email after because it depends on
        // UserPreferenceManager being initialized.
        sendVerificationEmail(_verificationEmailFrequency);
      }
    });
    return Future.value();
  }

  Future<void> reloadUser() async {
    await _user?.reload();
    _user = _firebaseAuth.currentUser;
  }

  Future<void> logout() {
    return _firebaseAuth.signOut();
  }

  Future<AuthError?> login(String email, String password) async {
    return _loginOrSignUp(
      () => _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<AuthError?> signUp(String email, String password) async {
    return _loginOrSignUp(
      () => _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> sendResetPasswordEmail(String email) =>
      _firebaseAuth.sendPasswordResetEmail(email);

  /// Returns true if a verification email was sent to the user; false if the
  /// user is already verified, or enough time hasn't elapsed since the last
  /// email.
  Future<bool> sendVerificationEmail(int msBetweenSends) async {
    if (isUserVerified) {
      return true;
    }

    // Only send an email if one has never been sent before, or at least
    // minimumBetweenSends has elapsed since the last one was sent.
    var verificationSentAt = _userPreferenceManager.verificationEmailSentAt;
    var now = _timeManager.msSinceEpoch;
    if (verificationSentAt != null &&
        now - verificationSentAt < msBetweenSends) {
      var minBetweenSends = msBetweenSends / 1000 / 60;
      _log.d(
          "A verification email was sent less than $minBetweenSends min ago");
      return false;
    }

    _userPreferenceManager.setVerificationEmailSentAt(now);
    await _user?.sendEmailVerification();
    return true;
  }

  Future<AuthError?> _loginOrSignUp(
      Future<UserCredential> Function() authFunction) async {
    if (!(await _io.isConnected())) {
      return AuthError.noConnection;
    }

    try {
      return _isUserValid(await authFunction())
          ? null
          : AuthError.invalidUserId;
    } on FirebaseAuthException catch (error) {
      return _firebaseExceptionToAuthError(error.code);
    }
  }

  bool _isUserValid(UserCredential credential) {
    return !isEmpty(credential.user?.uid);
  }

  AuthError _firebaseExceptionToAuthError(String firebaseCode) {
    switch (firebaseCode) {
      case "invalid-email":
        return AuthError.invalidEmail;
      case "user-disabled":
        return AuthError.userDisabled;
      case "user-not-found":
        return AuthError.userNotFound;
      case "wrong-password":
        return AuthError.wrongPassword;
      case "email-already-in-use":
        return AuthError.emailInUse;
      case "operation-not-allowed":
        return AuthError.operationNotAllowed;
      case "weak-password":
        return AuthError.weakPassword;
    }

    _log.d("Unknown Firebase exception: $firebaseCode");
    return AuthError.unknownFirebaseException;
  }

  // Note that we need to initialize managers in sequence, as opposed to being
  // initialized in an AuthManagerListener callback. This is because there is
  // no guarantee of order execution in a Stream listener, and we need
  // guaranteed order when initializing local data. CatchManager, for example,
  // expects that SpeciesManager is already initialized with all its Species
  // objects.
  Future<void> _initializeManagers() async {
    // Need to initialize the local database before anything else, since all
    // entity managers depend on the local database.
    await _appManager.localDatabaseManager.initialize();

    // UserPreferenceManager includes "pro" override and needs to be initialized
    // before managers that upload data to Firebase.
    await _appManager.userPreferenceManager.initialize();

    // First initialize managers that are dependents of other managers.
    await _appManager.speciesManager.initialize();

    await _appManager.anglerManager.initialize();
    await _appManager.baitCategoryManager.initialize();
    await _appManager.baitManager.initialize();
    await _appManager.bodyOfWaterManager.initialize();
    await _appManager.catchManager.initialize();
    await _appManager.customEntityManager.initialize();
    await _appManager.reportManager.initialize();
    await _appManager.fishingSpotManager.initialize();
    await _appManager.methodManager.initialize();
    await _appManager.waterClarityManager.initialize();
    await _appManager.tripManager.initialize();

    // Ensure everything is initialized before managing any image state.
    await _appManager.imageManager.initialize();

    _setState(AuthState.loggedIn);
  }

  void _setState(AuthState state) {
    _state = state;
    _controller.notify();
  }
}
