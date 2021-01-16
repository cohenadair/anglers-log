import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:quiver/strings.dart';

import '../wrappers/services_wrapper.dart';

const _channelName = "com.cohenadair.anglerslog/migration";

class LegacyJsonResult {
  /// If [error] is empty, [json] is non-null.
  final Map<String, dynamic> json;

  /// If not empty, [json] is null.
  final String error;

  LegacyJsonResult(this.json, this.error);

  /// If one of [json] or [error] is not null, we have legacy data to migrate.
  bool get hasLegacyData => json != null || isNotEmpty(error);

  @override
  String toString() => "{json=$json, error=$error}";
}

/// Returns a JSON map of legacy data.
Future<LegacyJsonResult> legacyJson(ServicesWrapper servicesWrapper) async {
  var name = "legacyJson";

  String result;
  try {
    result =
        await servicesWrapper.methodChannel(_channelName).invokeMethod(name);
  } on PlatformException catch (e) {
    return LegacyJsonResult(null, e.message);
  }

  return LegacyJsonResult(result == null ? null : jsonDecode(result), null);
}
