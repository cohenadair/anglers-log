import 'dart:convert';
import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'properties_manager.dart';
import 'user_preference_manager.dart';
import 'utils/atmosphere_utils.dart';
import 'utils/number_utils.dart';
import 'utils/protobuf_utils.dart';
import 'utils/string_utils.dart';
import 'wrappers/http_wrapper.dart';

class AtmosphereFetcher {
  static const _authority = "weather.visualcrossing.com";
  static const _path =
      "/VisualCrossingWebServices/rest/services/timeline/%s,%s/%s";

  final _log = Log("AtmosphereFetcher");

  final AppManager appManager;
  final int timestamp;
  final LatLng? latLng;

  HttpWrapper get _http => appManager.httpWrapper;

  PropertiesManager get _propertiesManager => appManager.propertiesManager;

  UserPreferenceManager get _userPreferenceManager =>
      appManager.userPreferenceManager;

  AtmosphereFetcher(this.appManager, this.timestamp, this.latLng);

  Future<Atmosphere?> fetch() async {
    if (latLng == null) {
      return null;
    }

    // Only include fields the user specifically wants. This excludes unwanted
    // data from the start so we don't have to worry about it at the UI level.
    // It also slightly decreases data consumption.
    var showingFieldIds = _userPreferenceManager.atmosphereFieldIds;
    var elements = <String>[];
    for (var id in showingFieldIds) {
      if (id == atmosphereFieldIdTemperature) {
        elements.add("temp");
      } else if (id == atmosphereFieldIdHumidity) {
        elements.add("humidity");
      } else if (id == atmosphereFieldIdSkyCondition) {
        elements.add("conditions");
      } else if (id == atmosphereFieldIdMoonPhase) {
        elements.add("moonphase");
      } else if (id == atmosphereFieldIdPressure) {
        elements.add("pressure");
      } else if (id == atmosphereFieldIdVisibility) {
        elements.add("visibility");
      } else if (id == atmosphereFieldIdWindSpeed) {
        elements.add("windspeed");
      } else if (id == atmosphereFieldIdWindDirection) {
        elements.add("winddir");
      } else if (id == atmosphereFieldIdSunriseTimestamp) {
        elements.add("sunriseEpoch");
      } else if (id == atmosphereFieldIdSunsetTimestamp) {
        elements.add("sunsetEpoch");
      }
    }
    var json = await get(elements.join(","));
    if (json == null) {
      return null;
    }

    return _atmosphereFromJson(json);
  }

  Atmosphere _atmosphereFromJson(Map<String, dynamic> json) {
    var result = Atmosphere();

    var temperature = doubleFromDynamic(json["temp"]);
    if (temperature != null) {
      result.temperature = _measurement(
        value: temperature,
        system: _userPreferenceManager.airTemperatureSystem,
        metricUnit: Unit.celsius,
        imperialUnit: Unit.fahrenheit,
        apiUnit: Unit.fahrenheit,
      );
    }

    var humidity = intFromDynamic(json["humidity"]);
    if (humidity != null) {
      result.humidity = Measurement(
        unit: Unit.percent,
        value: humidity.roundToDouble(),
      );
    }

    var windSpeed = doubleFromDynamic(json["windspeed"]);
    if (windSpeed != null) {
      result.windSpeed = _measurement(
        value: windSpeed,
        system: _userPreferenceManager.windSpeedSystem,
        metricUnit: Unit.kilometers_per_hour,
        imperialUnit: Unit.miles_per_hour,
        apiUnit: Unit.miles_per_hour,
      );
    }

    var windDirection = doubleFromDynamic(json["winddir"]);
    if (windDirection != null) {
      result.windDirection = Directions.fromDegrees(windDirection);
    }

    var pressure = doubleFromDynamic(json["pressure"]);
    if (pressure != null) {
      result.pressure = _measurement(
        value: pressure,
        system: _userPreferenceManager.airPressureSystem,
        metricUnit: Unit.millibars,
        imperialUnit: Unit.pounds_per_square_inch,
        apiUnit: Unit.millibars,
      );
    }

    var visibility = doubleFromDynamic(json["visibility"]);
    if (visibility != null) {
      result.visibility = _measurement(
        value: visibility,
        system: _userPreferenceManager.airVisibilitySystem,
        metricUnit: Unit.kilometers,
        imperialUnit: Unit.miles,
        apiUnit: Unit.miles,
      );
    }

    var conditions = json["conditions"];
    if (conditions is String && isNotEmpty(conditions)) {
      result.skyConditions.addAll(SkyConditions.fromTypes(conditions));
    }

    var sunrise = intFromDynamic(json["sunriseEpoch"]);
    if (sunrise != null && sunrise > 0) {
      result.sunriseMillis = Int64(sunrise * Duration.millisecondsPerSecond);
    }

    var sunset = intFromDynamic(json["sunsetEpoch"]);
    if (sunset != null && sunset > 0) {
      result.sunsetMillis = Int64(sunset * Duration.millisecondsPerSecond);
    }

    var moon = doubleFromDynamic(json["moonphase"]);
    if (moon != null) {
      result.moonPhase = MoonPhases.fromDouble(moon);
    }

    return result;
  }

  Future<Map<String, dynamic>?> get(String elements) async {
    var params = {
      "key": _propertiesManager.visualCrossingApiKey,
      "lang": "id",
      "include": "current",
      "elements": elements,
    };

    var uri = Uri.https(
      _authority,
      format(_path, [
        latLng!.latitude,
        latLng!.longitude,
        (timestamp / Duration.millisecondsPerSecond).round(),
      ]),
      params,
    );

    var response = await _http.get(uri);

    if (response.statusCode != HttpStatus.ok) {
      _log.e("Error fetching data: ${response.statusCode}, query=$uri");
      return null;
    }

    // Catch any parsing errors as a safety measure. We cannot trust that
    // the response object will always be a value JSON string.
    dynamic json;
    try {
      json = jsonDecode(response.body);
    } on Exception {
      json = null;
    }

    if (!_isValidJsonMap(json)) {
      _log.e("Response body is a non-JSON format: ${response.body}");
      return null;
    }

    var daysList = json["days"];
    if (daysList == null || !(daysList is List)) {
      _log.e("Response body has invalid \"days\" key: ${response.body}");
      return null;
    }

    var daysJson = daysList.first;
    if (!_isValidJsonMap(daysJson)) {
      _log.e("Response body has invalid \"days\" key: ${response.body}");
      return null;
    }

    return daysJson;
  }

  bool _isValidJsonMap(dynamic possibleJson) =>
      possibleJson != null && possibleJson is Map<String, dynamic>;

  Measurement _measurement({
    required double value,
    required MeasurementSystem? system,
    required Unit metricUnit,
    required Unit imperialUnit,
    required Unit apiUnit,
  }) {
    var unit = system == null || system == MeasurementSystem.metric
        ? metricUnit
        : imperialUnit;

    var convertedValue = unit.convertFrom(apiUnit, value);
    if (system == MeasurementSystem.imperial_whole) {
      convertedValue = convertedValue.roundToDouble();
    }

    return Measurement(
      unit: unit,
      value: convertedValue,
    );
  }
}
