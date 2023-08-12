import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiver/strings.dart';

import '../log.dart';

const _log = Log("NumberUtils");

/// Converts [value] to a [double], if possible. This function will work if
/// [value] is one of the following data types:
///   - String
///   - int
///   - double
double? doubleFromDynamic(dynamic value) {
  if (value == null) {
    // ignore: avoid_returning_null
    return null;
  } else if (value is String) {
    return Doubles.tryLocaleParse(value);
  } else if (value is int) {
    return value.toDouble();
  } else if (value is double) {
    return value;
  }
  _log.w("Can't convert type to double: ${value.runtimeType}");
  // ignore: avoid_returning_null
  return null;
}

/// Converts [value] to an [int], if possible. This function will work if
/// [value] is one of the following data types:
///   - String
///   - int
///   - double
int? intFromDynamic(dynamic value) {
  if (value == null) {
    // ignore: avoid_returning_null
    return null;
  } else if (value is String) {
    return int.tryParse(value);
  } else if (value is double) {
    return value.round();
  } else if (value is int) {
    return value;
  }
  _log.w("Can't convert type to int: ${value.runtimeType}");
  // ignore: avoid_returning_null
  return null;
}

int percent(int numerator, int denominator) {
  assert(denominator > 0);
  return (numerator / denominator * 100).round();
}

extension Doubles on double {
  bool get isWhole => this % 1 == 0;

  int? roundIfWhole() => isWhole ? round() : null;

  /// Returns a display value for the double. [decimalPlaces] defaults to 2, and
  /// [locale] defaults to the device's current locale.
  String displayValue({
    int? decimalPlaces,
    String? locale,
  }) {
    if (isWhole || (decimalPlaces != null && decimalPlaces <= 0)) {
      return round().toString();
    }

    var decimals = decimalPlaces ?? 2;
    var languageTag =
        WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag();
    var fixed = (NumberFormat.decimalPattern(locale ?? languageTag)
          ..minimumFractionDigits = decimals
          ..maximumFractionDigits = decimals)
        .format(this);

    if (fixed[fixed.length - 1] == "0") {
      fixed = fixed.substring(0, fixed.length - 1);
    }

    return fixed;
  }

  /// Returns a parsed [double], taking the [locale] into account. [locale]
  /// defaults to the device's current locale.
  ///
  /// If the locale parsing fails, normal parsing is tried.
  static double? tryLocaleParse(
    String? input, {
    String? locale,
  }) {
    if (isEmpty(input)) {
      return null;
    }

    try {
      var languageTag =
          WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag();
      return NumberFormat.decimalPattern(locale ?? languageTag).parse(input!)
          as double;
    } catch (_) {
      var result = double.tryParse(input!);
      if (result == null) {
        _log.w("Failed to parse double: $input");
      }
      return result;
    }
  }
}
