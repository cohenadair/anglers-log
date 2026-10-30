/// Builds a store screenshot seed bundle from `seed/seed.json`. Runs on the
/// host (not the device), so all seed data is validated and serialized to
/// protobuf before the app is ever launched. `screenshots/capture` runs it
/// once per locale (see `capture.json` → `seed`).
///
/// The output bundle contains `seed.json` (database rows and preferences, ready
/// to be inserted by `capture_app.dart`) and an `images/` directory of JPEGs.
///
/// Usage, from this directory:
///   dart run build_seed.dart --check
///   dart run build_seed.dart --locale es --out /tmp/seed-es
///
/// See README.md for the seed file format.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:protobuf/protobuf.dart';
import 'package:screenshots_capture/seed.dart';

import 'seed_ids.dart';

const _baseLocale = "en";

/// Brand colors for placeholder photos.
const _placeholderGradient = ("#2E7D9A", "#16384A");

final _scriptDir = File.fromUri(Platform.script).parent.path;
final _seedDir = "$_scriptDir/seed";

/// Seed collection name to database table name and empty message builder.
const _collections = <String, (String, GeneratedMessage Function())>{
  "anglers": ("angler", Angler.new),
  "methods": ("method", Method.new),
  "waterClarities": ("water_clarity", WaterClarity.new),
  "species": ("species", Species.new),
  "baitCategories": ("bait_category", BaitCategory.new),
  "baits": ("bait", Bait.new),
  "gear": ("gear", Gear.new),
  "bodiesOfWater": ("body_of_water", BodyOfWater.new),
  "fishingSpots": ("fishing_spot", FishingSpot.new),
  "customEntities": ("custom_entity", CustomEntity.new),
  "gpsTrails": ("gps_trail", GpsTrail.new),
  "catches": ("catch", Catch.new),
  "trips": ("trip", Trip.new),
  "reports": ("custom_report", Report.new),
};

/// Collections whose entities record the time zone they were logged in.
const _timeZonedCollections = {"catches", "trips", "gpsTrails"};

/// Fields whose string values are user-visible and therefore translated.
const _translatableFields = {"name", "notes", "description", "color"};

const _imageNameField = "imageName";
const _imageNamesField = "imageNames";

/// Fields of type MultiMeasurement that accept the "5 lb 4 oz" shorthand.
const _measurementFields = {
  "length",
  "weight",
  "waterDepth",
  "waterTemperature",
  "temperature",
  "windSpeed",
  "pressure",
  "humidity",
  "visibility",
  "rodLength",
  "leaderLength",
  "tippetLength",
  "minDiveDepth",
  "maxDiveDepth",
};

/// Unit symbol to the proto's unit name, and whether it's metric.
const _units = {
  "in": ("inches", false),
  "ft": ("feet", false),
  "lb": ("pounds", false),
  "oz": ("ounces", false),
  "F": ("fahrenheit", false),
  "mph": ("miles_per_hour", false),
  "mi": ("miles", false),
  "inHg": ("inch_of_mercury", false),
  "psi": ("pounds_per_square_inch", false),
  "C": ("celsius", true),
  "cm": ("centimeters", true),
  "m": ("meters", true),
  "kg": ("kilograms", true),
  "kph": ("kilometers_per_hour", true),
  "km": ("kilometers", true),
  "mb": ("millibars", true),
  "%": ("percent", true),
};

const _degreesPerHalfTurn = 180;
const _degreesPerTurn = 360;

/// Preferences that skip onboarding and the translation warning.
const _defaultPreferences = {
  "did_onboard": true,
  "did_show_translation_warning": true,
};

Future<void> main(List<String> args) => runSeedCli(
  args,
  baseLocale: _baseLocale,
  check: _check,
  build: (options) => _build(
    locale: options.locale,
    outDir: options.outDir!,
    usesPlaceholderPhotos: options.usesPlaceholderPhotos,
  ),
);

Map<String, dynamic> _readSeed() =>
    jsonDecode(File("$_seedDir/seed.json").readAsStringSync())
        as Map<String, dynamic>;

SeedPhotos get _photos =>
    SeedPhotos("$_seedDir/photos", placeholderGradient: _placeholderGradient);

/// Human-readable problems with the seed: missing translations (for every
/// translation file), missing photos, unknown preference keys, and anything
/// that doesn't parse into its protobuf message.
List<String> _check() {
  var seed = _readSeed();
  var problems = <String>[];

  for (var locale in SeedTranslations.locales(
    _seedDir,
    baseLocale: _baseLocale,
  )) {
    problems.addAll(
      SeedTranslations.load(_seedDir, locale, baseLocale: _baseLocale)
          .missing(_translatableStrings(seed))
          .map((e) => "Missing $locale translation: \"$e\""),
    );
  }

  problems.addAll(_photos.missing(_photoStems(seed)));

  var keys = _seedKeys(seed);
  for (var key in _speciesCounterKeys(seed)) {
    if (!keys.contains(key)) {
      problems.add("Unknown seed key in species_counter: \"$key\"");
    }
  }

  try {
    _buildRows(
      seed,
      SeedTranslations.load(_seedDir, _baseLocale, baseLocale: _baseLocale),
      SeedClock(seed["timeZone"] as String),
    );
  } on Exception catch (e) {
    problems.add("Invalid seed: $e");
  }

  return problems;
}

/// Writes the seed bundle for [locale] to [outDir]. Throws if the seed has
/// missing translations, or missing photos unless [usesPlaceholderPhotos].
Future<void> _build({
  required String locale,
  required String outDir,
  required bool usesPlaceholderPhotos,
}) async {
  var seed = _readSeed();
  var translations = SeedTranslations.load(
    _seedDir,
    locale,
    baseLocale: _baseLocale,
  );
  var missing = translations.missing(_translatableStrings(seed));
  if (missing.isNotEmpty) {
    throw Exception(
      "Missing $locale translations in seed/translations/$locale.json: "
      "${missing.map((e) => "\"$e\"").join(", ")}",
    );
  }

  var imagesDir = Directory("$outDir/images")..createSync(recursive: true);
  var images = <String>[];
  for (var stem in _photoStems(seed)) {
    await _photos.writeJpeg(
      stem,
      "${imagesDir.path}/$stem.jpg",
      usesPlaceholder: usesPlaceholderPhotos,
    );
    images.add("$stem.jpg");
  }

  var clock = SeedClock(seed["timeZone"] as String);
  File("$outDir/seed.json").writeAsStringSync(
    jsonEncode({
      "tables": _buildRows(seed, translations, clock),
      "preferences": _buildPreferences(seed, clock),
      "images": images,
    }),
  );
}

/// The seed's collections, which is everything that's translated or has
/// photos (as opposed to, e.g., preferences).
List<Object?> _entities(Map<String, dynamic> seed) => [
  for (var collection in _collections.keys) seed[collection],
];

/// All distinct base-locale strings that need a translation, in seed order.
Set<String> _translatableStrings(Map<String, dynamic> seed) =>
    collectStrings(_entities(seed), _translatableFields);

Set<String> _photoStems(Map<String, dynamic> seed) {
  var result = <String>{};
  visitJsonFields(_entities(seed), (key, value) {
    if (key == _imageNameField && value is String) {
      result.add(value);
    } else if (key == _imageNamesField && value is List) {
      result.addAll(value.cast<String>());
    }
  });
  return result;
}

Set<String> _seedKeys(Map<String, dynamic> seed) => {
  for (var collection in _collections.keys)
    for (var raw in ((seed[collection] as List?) ?? []))
      (raw as Map<String, dynamic>)["key"] as String,
};

Iterable<String> _speciesCounterKeys(Map<String, dynamic> seed) =>
    (((seed["preferences"] as Map<String, dynamic>?)?["species_counter"]
                as Map<String, dynamic>?) ??
            const {})
        .keys;

Map<String, List<Map<String, String>>> _buildRows(
  Map<String, dynamic> seed,
  SeedTranslations translations,
  SeedClock clock,
) {
  var seenKeys = <String>{};
  var result = <String, List<Map<String, String>>>{};

  for (var MapEntry(key: collection, value: (table, builder))
      in _collections.entries) {
    for (var raw
        in ((seed[collection] as List?) ?? []).cast<Map<String, dynamic>>()) {
      var key = raw["key"] as String?;
      if (key == null) {
        throw Exception("$collection entity is missing a \"key\": $raw");
      }
      if (!seenKeys.add(key)) {
        throw Exception("Duplicate seed key: $key");
      }

      var json = _transform(raw, clock, translations) as Map<String, dynamic>;
      _applyCollectionDefaults(collection, json, raw, clock.zone.name);

      var message = builder();
      try {
        message.mergeFromProto3Json(json);
      } on Exception catch (e) {
        throw Exception("$collection/$key: $e");
      }
      result.putIfAbsent(table, () => []).add({
        "id": anglersLogSeedUuid(key),
        "bytes": base64Encode(message.writeToBuffer()),
      });
    }
  }
  return result;
}

void _applyCollectionDefaults(
  String collection,
  Map<String, dynamic> json,
  Map<String, dynamic> raw,
  String timeZoneName,
) {
  if (_timeZonedCollections.contains(collection)) {
    json.putIfAbsent("timeZone", () => timeZoneName);
  }

  if (collection == "baits") {
    for (var variant in (json["variants"] as List? ?? [])) {
      (variant as Map<String, dynamic>)["baseId"] = json["id"];
    }
  }

  if (collection == "gpsTrails") {
    json["points"] = _gpsTrailPoints(
      (raw["points"] as List).cast<List>(),
      int.parse(json["startTimestamp"] as String),
      int.parse(json["endTimestamp"] as String),
    );
  }
}

/// Recursively converts seed conveniences into proto3 JSON: keys and key
/// references into IDs, relative timestamps into epoch milliseconds,
/// measurement shorthand into MultiMeasurement JSON, and translatable strings
/// into their translation.
dynamic _transform(
  dynamic node,
  SeedClock clock,
  SeedTranslations translations,
) {
  if (node is List) {
    return node.map((e) => _transform(e, clock, translations)).toList();
  }
  if (node is! Map<String, dynamic>) {
    return node;
  }

  var result = <String, dynamic>{};
  node.forEach((key, value) {
    if (key == "key") {
      result["id"] = {"uuid": anglersLogSeedUuid(value as String)};
    } else if (key == "points") {
      // GPS trail points are converted with the trail's timestamps; see
      // _applyCollectionDefaults.
    } else if (key.endsWith("Id") && value is String) {
      result[key] = {"uuid": anglersLogSeedUuid(value)};
    } else if (key.endsWith("Ids") && value is List) {
      result[key] = value
          .map((e) => {"uuid": anglersLogSeedUuid(e as String)})
          .toList();
    } else if (_isTimestampField(key) && value is String) {
      result[key] = clock.timestamp(value).toString();
    } else if (_measurementFields.contains(key) && value is String) {
      result[key] = _measurement(value);
    } else if (key == _imageNameField && value is String) {
      result[key] = "$value.jpg";
    } else if (key == _imageNamesField && value is List) {
      result[key] = value.map((e) => "$e.jpg").toList();
    } else if (_translatableFields.contains(key) && value is String) {
      result[key] = translations.translate(value);
    } else {
      result[key] = _transform(value, clock, translations);
    }
  });
  return result;
}

bool _isTimestampField(String key) =>
    key == "timestamp" || key.endsWith("Timestamp");

/// "24.5 in" -> imperial decimal inches, "5 lb 4 oz" -> imperial whole pounds
/// and ounces, "12 cm" -> metric centimeters.
Map<String, dynamic> _measurement(String value) {
  var parts = value.split(" ");
  if (parts.length != 2 && parts.length != 4) {
    throw Exception("Invalid measurement \"$value\"");
  }

  Map<String, dynamic> part(String number, String unitSymbol) {
    var unit = _units[unitSymbol];
    if (unit == null) {
      throw Exception("Unknown unit \"$unitSymbol\" in \"$value\"");
    }
    return {"unit": unit.$1, "value": double.parse(number)};
  }

  String system;
  if (_units[parts[1]]?.$2 ?? false) {
    system = "metric";
  } else if (parts.length == 2 && parts[0].contains(".")) {
    system = "imperial_decimal";
  } else {
    system = "imperial_whole";
  }

  return {
    "system": system,
    "mainValue": part(parts[0], parts[1]),
    if (parts.length == 4) "fractionValue": part(parts[2], parts[3]),
  };
}

/// Spreads [points] evenly between [start] and [end], each heading towards
/// the next point (the last heading towards the first, closing the loop).
List<Map<String, dynamic>> _gpsTrailPoints(
  List<List> points,
  int start,
  int end,
) {
  var step = points.length < 2 ? 0 : (end - start) ~/ (points.length - 1);
  return [
    for (var i = 0; i < points.length; i++)
      {
        "timestamp": (start + i * step).toString(),
        "lat": points[i][0],
        "lng": points[i][1],
        "heading": _heading(points[i], points[(i + 1) % points.length]),
      },
  ];
}

/// The compass bearing, in degrees, from [from] to [to] (`[lat, lng]`).
double _heading(List from, List to) {
  double rad(num deg) => deg * pi / _degreesPerHalfTurn;
  var lat1 = rad(from[0] as num);
  var lat2 = rad(to[0] as num);
  var dLng = rad((to[1] as num) - (from[1] as num));
  var y = sin(dLng) * cos(lat2);
  var x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
  return (atan2(y, x) * _degreesPerHalfTurn / pi + _degreesPerTurn) %
      _degreesPerTurn;
}

/// Preferences are written to the `user_preference` table as JSON. Values
/// that are seed keys (or maps/lists keyed by seed keys) are converted to
/// UUIDs, and "now" to the current timestamp. Preferences needed to skip
/// onboarding and the change log are added automatically.
Map<String, dynamic> _buildPreferences(
  Map<String, dynamic> seed,
  SeedClock clock,
) {
  var keys = _seedKeys(seed);

  dynamic resolve(dynamic value) {
    if (value == "now") {
      return clock.timestamp("now");
    }
    if (value is String && keys.contains(value)) {
      return anglersLogSeedUuid(value);
    }
    if (value is List) {
      return value.map(resolve).toList();
    }
    if (value is Map<String, dynamic>) {
      return value.map(
        (k, v) =>
            MapEntry(keys.contains(k) ? anglersLogSeedUuid(k) : k, resolve(v)),
      );
    }
    return value;
  }

  return {
    ..._defaultPreferences,
    // Without this, the app thinks it was just updated and shows its change
    // log.
    "app_version": pubspecVersion("$_scriptDir/../../mobile/pubspec.yaml"),
    ...((seed["preferences"] as Map<String, dynamic>?) ?? {}).map(
      (k, v) => MapEntry(k, resolve(v)),
    ),
  };
}
