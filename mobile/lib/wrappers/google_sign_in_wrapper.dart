import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../app_manager.dart';

class GoogleSignInWrapper {
  static GoogleSignInWrapper of(BuildContext context) =>
      AppManager.get.googleSignInWrapper;

  GoogleSignIn newInstance(List<String> scopes) => GoogleSignIn(scopes: scopes);

  Future<AuthClient?> authenticatedClient(GoogleSignIn? googleSignIn) async {
    // Need a wrapper here because extension methods cannot be mocked.
    return Future.value(await googleSignIn?.authenticatedClient());
  }
}
