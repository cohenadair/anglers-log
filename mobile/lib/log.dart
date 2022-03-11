import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class Log {
  final String _className;

  const Log(this._className);

  String get _prefix => "AL-$_className: ";

  void d(String msg) {
    _log("D/$_prefix$msg");
  }

  void e(StackTrace stackTrace, String msg) {
    _log("E/$_prefix$msg", stackTrace);
  }

  void w(String msg) {
    _log("W/$_prefix$msg");
  }

  void _log(String msg, [StackTrace? stackTrace]) {
    // Don't engage Crashlytics at all if we're on a debug build. Event if
    // crash reporting is off, Crashlytics queues crashes to be sent later.
    if (kDebugMode) {
      print(msg);
      return;
    }

    if (stackTrace == null) {
      FirebaseCrashlytics.instance.log(msg);
    } else {
      FirebaseCrashlytics.instance
          .recordError(msg, stackTrace, reason: "Logged error");
    }
  }
}
