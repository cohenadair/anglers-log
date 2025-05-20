import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import '../app_manager.dart';

class NativeTimeZoneWrapper {
  static NativeTimeZoneWrapper of(BuildContext context) =>
      AppManager.get.nativeTimeZoneWrapper;

  Future<List<String>> getAvailableTimeZones() =>
      FlutterTimezone.getAvailableTimezones();

  Future<String> getLocalTimeZone() => FlutterTimezone.getLocalTimezone();
}
