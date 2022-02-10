import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';

int Function(String, String) get ignoreCaseAlphabeticalComparator =>
    (lhs, rhs) => compareIgnoreCase(lhs, rhs);

/// A trimmed, case-insensitive string comparison.
bool equalsTrimmedIgnoreCase(String? s1, String? s2) =>
    equalsIgnoreCase(s1?.trim(), s2?.trim());

bool containsTrimmedLowerCase(String fullString, String filter) =>
    fullString.toLowerCase().trim().contains(filter.toLowerCase().trim());

/// Supported formats:
///   - %s
/// For each argument, toString() is called to replace %s.
String format(String s, List<dynamic> args) {
  var index = 0;
  return s.replaceAllMapped(RegExp(r'%s'), (match) => args[index++].toString());
}

String formatList(List<String> items) {
  return items.where(isNotEmpty).join(", ");
}

String formatLatLng({
  required BuildContext context,
  required double lat,
  required double lng,
  bool includeLabels = true,
}) {
  const decimalPlaces = 6;

  return format(
    includeLabels
        ? Strings.of(context).latLng
        : Strings.of(context).latLngNoLabels,
    [
      lat.toStringAsFixed(decimalPlaces),
      lng.toStringAsFixed(decimalPlaces),
    ],
  );
}

bool parseBoolFromInt(String str) {
  var intBool = int.tryParse(str);
  if (intBool == null) {
    return false;
  } else {
    return intBool == 1 ? true : false;
  }
}

String newLineOrEmpty(String input) => input.isEmpty ? "" : "\n";
