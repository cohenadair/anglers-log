import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class FirebaseAuthWrapper {
  static FirebaseAuthWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).firebaseAuthWrapper;

  Stream<User> authStateChanges() => FirebaseAuth.instance.authStateChanges();

  Future<void> signOut() => FirebaseAuth.instance.signOut();

  Future<UserCredential> signInWithEmailAndPassword({
    String email,
    String password,
  }) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    String email,
    String password,
  }) {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
