import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:mobile/l10n/l10n_extension.dart';
import 'package:quiver/strings.dart';

import '../l10n/gen/localizations.dart';

typedef LocalizedStringCallback = String Function(BuildContext);

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

String formatCoordinate(double value, [int numberOfDecimalPlaces = 6]) {
  return value.toStringAsFixed(numberOfDecimalPlaces);
}

String formatLatLng({
  required BuildContext context,
  required double lat,
  required double lng,
  bool includeLabels = true,
}) {
  return includeLabels
      ? Strings.of(context).latLng(formatCoordinate(lat), formatCoordinate(lng))
      : Strings.of(context)
          .latLngNoLabels(formatCoordinate(lat), formatCoordinate(lng));
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

/// A convenience wrapper to access the app's strings.
/// TODO: Replace with L10n.get.app.*
class Strings {
  static AnglersLogLocalizations of(BuildContext context) {
    return L10n.get.app;
  }
}
