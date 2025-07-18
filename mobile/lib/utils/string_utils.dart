import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:mobile/l10n/l10n_extension.dart';

import '../l10n/gen/localizations.dart';

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
      : Strings.of(
          context,
        ).latLngNoLabels(formatCoordinate(lat), formatCoordinate(lng));
}

/// A convenience wrapper to access the app's strings.
/// TODO: Replace with L10n.get.app.*
class Strings {
  static AnglersLogLocalizations of(BuildContext context) {
    return L10n.get.app;
  }
}
