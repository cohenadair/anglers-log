import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../app_manager.dart';

class CrashlyticsWrapper {
  static CrashlyticsWrapper of(BuildContext context) =>
      AppManager.get.crashlyticsWrapper;

  const CrashlyticsWrapper();

  Future<void> log(String message) {
    return FirebaseCrashlytics.instance.log(message);
  }

  Future<void> setUserId(String identifier) {
    return FirebaseCrashlytics.instance.setUserIdentifier(identifier);
  }

  Future<void> setCustomKey(String key, Object value) {
    return FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  Future<void> recordError(
    dynamic message,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? printDetails,
    bool fatal = false,
  }) {
    return FirebaseCrashlytics.instance.recordError(
      message,
      stack,
      reason: reason,
      information: information,
      printDetails: printDetails,
      fatal: fatal,
    );
  }
}
