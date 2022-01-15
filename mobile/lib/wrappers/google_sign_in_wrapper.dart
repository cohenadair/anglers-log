import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class GoogleSignInWrapper {
  static GoogleSignInWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).googleSignInWrapper;

  GoogleSignIn newInstance(List<String> scopes) =>
      GoogleSignIn(scopes: scopes);
}