import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../app_manager.dart';

class GoogleSignInWrapper {
  static GoogleSignInWrapper of(BuildContext context) =>
      AppManager.get.googleSignInWrapper;

  Future<void> initialize({String? serverClientId}) =>
      GoogleSignIn.instance.initialize(serverClientId: serverClientId);

  Future<GoogleSignInAccount?>? attemptLightweightAuthentication() =>
      GoogleSignIn.instance.attemptLightweightAuthentication();

  Future<GoogleSignInAccount> authenticate() =>
      GoogleSignIn.instance.authenticate();

  Future<void> disconnect() => GoogleSignIn.instance.disconnect();
}
