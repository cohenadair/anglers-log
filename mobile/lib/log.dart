import 'dart:async';
import 'package:flutter/foundation.dart';
import 'wrappers/crashlytics_wrapper.dart';

class Log {
  final String _className;
  final CrashlyticsWrapper _crashlytics;
  final bool _isDebug;

  const Log(
    this._className, {
    CrashlyticsWrapper crashlytics = const CrashlyticsWrapper(),
    bool isDebug = kDebugMode,
  })  : _crashlytics = crashlytics,
        _isDebug = isDebug;

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

  /// Does [work] and measures performance in milliseconds. If [work] takes
  /// longer than [msThreshold] to finish, an error message is logged, otherwise
  /// only a debug message is logged.
  ///
  /// The value of [work] is returned.
  Future<T> p<T>(
      String tag, int msThreshold, FutureOr<T> Function() work) async {
    var stopwatch = Stopwatch()..start();
    var result = await work();

    var elapsed = stopwatch.elapsed.inMilliseconds;
    if (elapsed > msThreshold) {
      e(StackTrace.current, "$tag exceeded threshold: ${elapsed}ms");
    } else {
      d("$tag took ${elapsed}ms");
    }

    return result;
  }

  void _log(String msg, [StackTrace? stackTrace]) {
    // Don't engage Crashlytics at all if we're on a debug build. Event if
    // crash reporting is off, Crashlytics queues crashes to be sent later.
    if (_isDebug) {
      // ignore: avoid_print
      print(msg);
      return;
    }

    if (stackTrace == null) {
      _crashlytics.log(msg);
    } else {
      _crashlytics.recordError(msg, stackTrace, "Logged error");
    }
  }
}
