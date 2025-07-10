import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:quiver/strings.dart';
import 'package:timezone/timezone.dart';

import 'app_manager.dart';
import 'location_data_fetcher.dart';
import 'log.dart';
import 'model/gen/anglers_log.pb.dart';
import 'properties_manager.dart';
import 'user_preference_manager.dart';
import 'utils/atmosphere_utils.dart';
import 'utils/network_utils.dart';
import 'utils/number_utils.dart';
import 'utils/protobuf_utils.dart';
import 'utils/string_utils.dart';
import 'widgets/fetch_input_header.dart';
import 'wrappers/http_wrapper.dart';

class AtmosphereFetcher extends LocationDataFetcher<Atmosphere?> {
  static const _authority = "weather.visualcrossing.com";
  static const _path =
      "/VisualCrossingWebServices/rest/services/timeline/%s,%s/%s";

  final _log = const Log("AtmosphereFetcher");

  final TZDateTime dateTime;

  HttpWrapper get _httpWrapper => AppManager.get.httpWrapper;

  AtmosphereFetcher(this.dateTime, super._latLng);

  @override
  Future<FetchInputResult<Atmosphere?>> fetch(BuildContext context) async {
    var result = await super.fetch(context);
    if (result != null) {
      return result;
    }

    if (latLng == null) {
      return FetchInputResult();
    }

    _log.d("Fetching data...");

    // Only include fields the user specifically wants. This excludes unwanted
    // data from the start so we don't have to worry about it at the UI level.
    // It also slightly decreases data consumption. Note that if
    // atmosphereFieldIds is empty, the request returns all available fields.
    var showingFieldIds = UserPreferenceManager.get.atmosphereFieldIds;
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
      return FetchInputResult();
    }

    return FetchInputResult<Atmosphere>(data: _atmosphereFromJson(json));
  }

  Atmosphere _atmosphereFromJson(Map<String, dynamic> json) {
    var result = Atmosphere();

    var temperature = doubleFromDynamic(json["temp"]);
    if (temperature != null) {
      result.temperature = _multiMeasurement(
        value: temperature,
        system: UserPreferenceManager.get.airTemperatureSystem,
        metricUnit: Unit.celsius,
        imperialUnit: Unit.fahrenheit,
        apiUnit: Unit.fahrenheit,
      );
    }

    var humidity = intFromDynamic(json["humidity"]);
    if (humidity != null) {
      result.humidity = MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.percent,
          value: humidity.roundToDouble(),
        ),
      );
    }

    var windSpeed = doubleFromDynamic(json["windspeed"]);
    if (windSpeed != null) {
      result.windSpeed = _multiMeasurement(
        value: windSpeed,
        system: UserPreferenceManager.get.windSpeedSystem,
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
      result.pressure = _multiMeasurement(
        value: pressure,
        system: UserPreferenceManager.get.airPressureSystem,
        metricUnit: Unit.millibars,
        imperialUnit: UserPreferenceManager.get.airPressureImperialUnit,
        apiUnit: Unit.millibars,
      );
    }

    var visibility = doubleFromDynamic(json["visibility"]);
    if (visibility != null) {
      result.visibility = _multiMeasurement(
        value: visibility,
        system: UserPreferenceManager.get.airVisibilitySystem,
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
      result.sunriseTimestamp = Int64(sunrise * Duration.millisecondsPerSecond);
    }

    var sunset = intFromDynamic(json["sunsetEpoch"]);
    if (sunset != null && sunset > 0) {
      result.sunsetTimestamp = Int64(sunset * Duration.millisecondsPerSecond);
    }

    var moon = doubleFromDynamic(json["moonphase"]);
    if (moon != null) {
      result.moonPhase = MoonPhases.fromDouble(moon);
    }

    result.timeZone = dateTime.locationName;

    return result;
  }

  Future<Map<String, dynamic>?> get(String elements) async {
    var params = {
      "key": PropertiesManager.get.visualCrossingApiKey,
      "lang": "id",
      "include": "current",
      "elements": elements,
    };

    var uri = Uri.https(
      _authority,
      format(_path, [
        latLng!.latitudeString,
        latLng!.longitudeString,
        (dateTime.millisecondsSinceEpoch / Duration.millisecondsPerSecond)
            .round(),
      ]),
      params,
    );
    var json = await getRestJson(_httpWrapper, uri);
    if (json == null) {
      return null;
    }

    var currentConditionsJson = json["currentConditions"];
    if (!isValidJsonMap(currentConditionsJson)) {
      _log.e(StackTrace.current,
          "Body has invalid \"currentConditions\" key: $json");
      return null;
    }

    return currentConditionsJson;
  }

  MultiMeasurement _multiMeasurement({
    required double value,
    required MeasurementSystem system,
    required Unit metricUnit,
    required Unit imperialUnit,
    required Unit apiUnit,
  }) {
    var unit = system == MeasurementSystem.metric ? metricUnit : imperialUnit;

    var convertedValue = unit.convertFrom(apiUnit, value);
    if (system == MeasurementSystem.imperial_whole) {
      convertedValue = convertedValue.roundToDouble();
    }

    return MultiMeasurement(
      system: system,
      mainValue: Measurement(
        unit: unit,
        value: convertedValue,
      ),
    );
  }
}
