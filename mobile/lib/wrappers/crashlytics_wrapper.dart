import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsWrapper {
  const CrashlyticsWrapper();

  Future<void> log(String message) {
    return FirebaseCrashlytics.instance.log(message);
  }

  Future<void> recordError(String message, StackTrace? stack, String reason) {
    return FirebaseCrashlytics.instance
        .recordError(message, stack, reason: reason);
  }
}
