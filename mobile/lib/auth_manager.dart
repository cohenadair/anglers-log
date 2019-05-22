import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

enum AuthError {
  unknown,
  invalidCredentials,
}

class AuthManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _userId;

  String get userId => _userId;

  AuthManager() {
    _auth.onAuthStateChanged.listen((FirebaseUser user) {
      if (user != null) {
        _userId = user.uid;
      }
    });
  }

  /// Returns a widget that listens for authentications changes.
  Widget getAuthStateListenerWidget({
    @required Widget loading,
    @required Widget authenticate,
    @required Widget finished
  }) {
    return StreamBuilder<FirebaseUser>(
      stream: _auth.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading;
        } else {
          return snapshot.hasData ? finished : authenticate;
        }
      },
    );
  }

  Future<void> logout() async {
    return await _auth.signOut();
  }

  Future<AuthError> login(String email, String password) async {
    try {
      FirebaseUser user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      return _isUserValid(user) ? null : AuthError.unknown;
    } catch (error) {
      return AuthError.invalidCredentials;
    }
  }

  Future<AuthError> signUp(String email, String password) async {
    try {
      FirebaseUser user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      return _isUserValid(user) ? null : AuthError.unknown;
    } catch (error) {
      return AuthError.unknown;
    }
  }

  bool _isUserValid(FirebaseUser user) {
    return user != null && !isEmpty(user.uid);
  }
}