import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class CrashlyticsWrapper {
  static CrashlyticsWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).crashlyticsWrapper;

  const CrashlyticsWrapper();

  Future<void> log(String message) {
    return FirebaseCrashlytics.instance.log(message);
  }

  Future<void> setUserId(String identifier) {
    return FirebaseCrashlytics.instance.setUserIdentifier(identifier);
  }

  Future<void> recordError(String message, StackTrace? stack, String reason) {
    return FirebaseCrashlytics.instance
        .recordError(message, stack, reason: reason);
  }
}
