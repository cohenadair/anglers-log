import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class NativeTimeZoneWrapper {
  static NativeTimeZoneWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).nativeTimeZoneWrapper;

  Future<List<String>> getAvailableTimeZones() =>
      FlutterTimezone.getAvailableTimezones();

  Future<String> getLocalTimeZone() => FlutterTimezone.getLocalTimezone();
}
