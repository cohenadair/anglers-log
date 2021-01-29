import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class FirebaseWrapper {
  static FirebaseWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).firebaseWrapper;

  Future<void> initializeApp() => Firebase.initializeApp();
}
