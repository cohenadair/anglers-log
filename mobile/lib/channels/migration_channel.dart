import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:quiver/strings.dart';

import '../wrappers/services_wrapper.dart';

const _channelName = "com.cohenadair.anglerslog/migration";

enum LegacyJsonErrorCode {
  invalidJson,
  platformException,
  missingPluginException,
  missingData,
}

class LegacyJsonResult {
  /// The path to the old database file. Non-null if [error] is empty.
  final String? databasePath;

  /// The path to the old images directory. Non-null if [error] is empty.
  final String? imagesPath;

  /// The legacy JSON. Non-null if [error] is empty.
  final Map<String, dynamic>? json;

  final LegacyJsonErrorCode? errorCode;
  final String? errorDescription;

  LegacyJsonResult({
    this.databasePath,
    this.imagesPath,
    this.json,
    this.errorCode,
    this.errorDescription,
  });

  /// If there's an old database file, there's data to migrate.
  bool get hasLegacyData => isNotEmpty(databasePath);

  bool get hasError => errorCode != null;

  @override
  String toString() => "{"
      "databasePath=$databasePath, "
      "imagesPath:$imagesPath, "
      "json=$json, "
      "errorCode=$errorCode, "
      "errorDescription=$errorDescription"
      "}";
}

Future<LegacyJsonResult?> legacyJson(ServicesWrapper servicesWrapper) async {
  var name = "legacyJson";

  try {
    var result =
        await servicesWrapper.methodChannel(_channelName).invokeMethod(name);

    if (result == null) {
      return null;
    } else {
      Map<String, dynamic>? json;
      LegacyJsonErrorCode? errorCode;

      if (isEmpty(result["db"]) ||
          isEmpty(result["img"]) ||
          result["json"] == null) {
        errorCode = LegacyJsonErrorCode.missingData;
      } else {
        try {
          json = jsonDecode(result["json"]);
        } on FormatException {
          errorCode = LegacyJsonErrorCode.invalidJson;
        }
      }

      return LegacyJsonResult(
        databasePath: result["db"],
        imagesPath: result["img"],
        json: json,
        errorCode: errorCode,
        errorDescription: result["json"],
      );
    }
  } on PlatformException catch (e) {
    return LegacyJsonResult(
      errorCode: LegacyJsonErrorCode.platformException,
      errorDescription: e.message,
    );
  } on MissingPluginException catch (e) {
    return LegacyJsonResult(
      errorCode: LegacyJsonErrorCode.missingPluginException,
      errorDescription: e.message,
    );
  }
}
