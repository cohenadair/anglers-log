import 'dart:convert';
import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quiver/strings.dart';

import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'properties_manager.dart';
import 'user_preference_manager.dart';
import 'utils/atmosphere_utils.dart';
import 'utils/protobuf_utils.dart';
import 'utils/string_utils.dart';
import 'wrappers/http_wrapper.dart';

class AtmosphereFetcher {
  static const _authority = "weather.visualcrossing.com";
  static const _path =
      "/VisualCrossingWebServices/rest/services/timeline/%s,%s/%s";

  final _log = Log("AtmosphereFetcher");

  final BuildContext context;
  final int timestamp;
  final LatLng? latLng;

  HttpWrapper get _http => HttpWrapper.of(context);

  PropertiesManager get _propertiesManager => PropertiesManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  AtmosphereFetcher(this.context, this.timestamp, this.latLng);

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

    var temperature = json["temp"];
    if (temperature != null) {
      result.temperature = _measurement(
          temperature,
          _userPreferenceManager.airTemperatureSystem,
          Unit.celsius,
          Unit.fahrenheit,
          Unit.fahrenheit);
    }

    var humidity = json["humidity"];
    if (humidity != null) {
      result.humidity = humidity.round();
    }

    var windSpeed = json["windspeed"];
    if (windSpeed != null) {
      result.windSpeed = _measurement(
          windSpeed,
          _userPreferenceManager.windSpeedSystem,
          Unit.kilometers_per_hour,
          Unit.miles_per_hour,
          Unit.miles_per_hour);
    }

    var windDirection = json["winddir"];
    if (windDirection != null) {
      result.windDirection = Directions.fromDegrees(windDirection);
    }

    var pressure = json["pressure"];
    if (pressure != null) {
      result.pressure = _measurement(
          pressure,
          _userPreferenceManager.airPressureSystem,
          Unit.millibars,
          Unit.pounds_per_square_inch,
          Unit.millibars);
    }

    var visibility = json["visibility"];
    if (visibility != null) {
      result.visibility = _measurement(
          visibility,
          _userPreferenceManager.airVisibilitySystem,
          Unit.kilometers,
          Unit.miles,
          Unit.miles);
    }

    var conditions = json["conditions"];
    if (isNotEmpty(conditions)) {
      result.skyConditions.addAll(SkyConditions.fromTypes(conditions));
    }

    var sunrise = json["sunriseEpoch"];
    if (sunrise != null && sunrise > 0) {
      result.sunriseTimestamp = Int64(sunrise * Duration.millisecondsPerSecond);
    }

    var sunset = json["sunsetEpoch"];
    if (sunset != null && sunset > 0) {
      result.sunsetTimestamp = Int64(sunset * Duration.millisecondsPerSecond);
    }

    var moon = json["moonphase"];
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

    var json = jsonDecode(response.body);
    if (!_isValidJsonMap(json)) {
      _log.e("Response body is a non-JSON format: ${response.body}");
      return null;
    }

    var daysJson = json["days"]?.first;
    if (!_isValidJsonMap(daysJson)) {
      _log.e("Response body has invalid \"days\" key: ${response.body}");
      return null;
    }

    return daysJson;
  }

  bool _isValidJsonMap(dynamic possibleJson) =>
      possibleJson != null && possibleJson is Map<String, dynamic>;

  Measurement _measurement(double value, MeasurementSystem? system,
      Unit metricUnit, Unit imperialUnit, Unit apiUnit) {
    var unit = system == null || system == MeasurementSystem.metric
        ? metricUnit
        : imperialUnit;
    return Measurement(
      unit: unit,
      value: unit.convertFrom(apiUnit, value),
    );
  }
}
