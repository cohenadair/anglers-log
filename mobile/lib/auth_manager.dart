import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
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

class AuthManager {
  static AuthManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).authManager;

  final AppManager _appManager;
  final FirebaseAuth _firebaseAuth;

  String _userId;

  IoWrapper get _io => _appManager.ioWrapper;

  String get userId => _userId;

  AuthManager(this._appManager, this._firebaseAuth) {
    _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        _userId = user.uid;
      }
    });
  }

  /// Returns a widget that listens for authentications changes.
  Widget listenerWidget({
    @required Widget loading,
    @required Widget authenticate,
    @required Widget finished,
  }) {
    return StreamBuilder<User>(
      stream: _firebaseAuth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return snapshot.hasData ? finished : authenticate;
        } else {
          return loading;
        }
      },
    );
  }

  Future<void> logout() async {
    return await _firebaseAuth.signOut();
  }

  Future<AuthError> login(String email, String password) async {
    return _loginOrSignUp(() => _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        ));
  }

  Future<AuthError> signUp(String email, String password) async {
    return _loginOrSignUp(() => _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ));
  }

  Future<AuthError> _loginOrSignUp(
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
    return !isEmpty(credential?.user?.uid);
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
      case "invalid-email":
        return AuthError.invalidEmail;
      case "operation-not-allowed":
        return AuthError.operationNotAllowed;
      case "weak-password":
        return AuthError.weakPassword;
    }

    return AuthError.unknownFirebaseException;
  }
}
