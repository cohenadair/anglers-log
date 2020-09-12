import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:quiver/strings.dart';

/// A trimmed, case-insensitive string comparison.
bool equalsTrimmedIgnoreCase(String s1, String s2) =>
    equalsIgnoreCase(s1.trim(), s2.trim());

/// Supported formats:
///   - %s
/// For each argument, toString() is called to replace %s.
String format(String s, List<dynamic> args) {
  int index = 0;
  return s.replaceAllMapped(RegExp(r'%s'), (Match match) =>
      args[index++].toString());
}

String formatLatLng({
  @required BuildContext context,
  @required double lat,
  @required double lng,
  bool includeLabels = true,
}) {
  final int decimalPlaces = 6;

  return format(
    includeLabels
        ? Strings.of(context).latLng : Strings.of(context).latLngNoLabels, [
      lat.toStringAsFixed(decimalPlaces),
      lng.toStringAsFixed(decimalPlaces),
    ],
  );
}

bool parseBool(String str) {
  int intBool = int.tryParse(str);
  if (intBool == null) {
    return false;
  } else {
    return intBool == 1 ? true : false;
  }
}