import 'dart:convert';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/atmosphere_utils.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(managers.localDatabaseManager.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(true));

    when(managers.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());

    UserPreferenceManager.reset();
  });

  test("Gear is added to catch field IDs", () async {
    when(managers.localDatabaseManager.fetchAll(any)).thenAnswer((_) {
      return Future.value([
        {
          "id": "catch_field_ids",
          "value": jsonEncode([catchFieldIdSpecies.uuid.toString()]),
        }
      ]);
    });
    await UserPreferenceManager.get.init();
    expect(
      UserPreferenceManager.get.catchFieldIds.contains(catchFieldIdGear),
      isTrue,
    );
  });

  test("Gear is not added to catch field IDs", () async {
    when(managers.localDatabaseManager.fetchAll(any)).thenAnswer((_) {
      return Future.value([
        {
          "id": "did_set_default_gear_tracking",
          "value": "true",
        }
      ]);
    });
    await UserPreferenceManager.get.init();
    expect(
      UserPreferenceManager.get.catchFieldIds.contains(catchFieldIdGear),
      isFalse,
    );
  });

  test("catchLengthSystem defaults to imperial", () {
    expect(UserPreferenceManager.get.preference("catch_length_system"), isNull);
    expect(UserPreferenceManager.get.catchLengthSystem,
        MeasurementSystem.imperial_whole);
  });

  test("catchWeightSystem defaults to imperial", () {
    expect(UserPreferenceManager.get.preference("catch_weight_system"), isNull);
    expect(UserPreferenceManager.get.catchWeightSystem,
        MeasurementSystem.imperial_whole);
  });

  test("waterDepthSystem defaults to imperial", () {
    expect(UserPreferenceManager.get.preference("water_depth_system"), isNull);
    expect(UserPreferenceManager.get.waterDepthSystem,
        MeasurementSystem.imperial_whole);
  });

  test("waterTemperatureSystem defaults to imperial", () {
    expect(
      UserPreferenceManager.get.preference("water_temperature_system"),
      isNull,
    );
    expect(UserPreferenceManager.get.waterTemperatureSystem,
        MeasurementSystem.imperial_decimal);
  });

  test("airTemperatureSystem defaults to imperial", () {
    expect(
      UserPreferenceManager.get.preference("air_temperature_system"),
      isNull,
    );
    expect(UserPreferenceManager.get.airTemperatureSystem,
        MeasurementSystem.imperial_whole);
  });

  test("airPressureSystem defaults to imperial", () {
    expect(
      UserPreferenceManager.get.preference("air_pressure_system"),
      isNull,
    );
    expect(UserPreferenceManager.get.airPressureSystem,
        MeasurementSystem.imperial_decimal);
  });

  test("airPressureImperialUnit defaults to inHg", () {
    expect(UserPreferenceManager.get.preference("air_pressure_imperial_unit"),
        isNull);
    expect(UserPreferenceManager.get.airPressureImperialUnit,
        Unit.inch_of_mercury);
  });

  test("airVisibilitySystem defaults to imperial", () {
    expect(
        UserPreferenceManager.get.preference("air_visibility_system"), isNull);
    expect(UserPreferenceManager.get.airVisibilitySystem,
        MeasurementSystem.imperial_whole);
  });

  test("windSpeedSystem defaults to imperial", () {
    expect(UserPreferenceManager.get.preference("wind_speed_system"), isNull);
    expect(UserPreferenceManager.get.windSpeedSystem,
        MeasurementSystem.imperial_whole);
  });

  test("windSpeedMetricUnit defaults to km/h", () {
    expect(
        UserPreferenceManager.get.preference("wind_speed_metric_unit"), isNull);
    expect(UserPreferenceManager.get.windSpeedMetricUnit,
        Unit.kilometers_per_hour);
  });

  test("tideHeightSystem defaults to imperial", () {
    expect(UserPreferenceManager.get.preference("tide_height_system"), isNull);
    expect(UserPreferenceManager.get.tideHeightSystem,
        MeasurementSystem.imperial_whole);
  });

  test("rodLengthSystem defaults to imperial", () {
    expect(UserPreferenceManager.get.preference("rod_length_system"), isNull);
    expect(UserPreferenceManager.get.rodLengthSystem,
        MeasurementSystem.imperial_whole);
  });

  test("leaderLengthSystem defaults to imperial", () {
    expect(
      UserPreferenceManager.get.preference("leader_length_system"),
      isNull,
    );
    expect(UserPreferenceManager.get.leaderLengthSystem,
        MeasurementSystem.imperial_whole);
  });

  test("tippetLengthSystem defaults to imperial", () {
    expect(
      UserPreferenceManager.get.preference("tippet_length_system"),
      isNull,
    );
    expect(UserPreferenceManager.get.tippetLengthSystem,
        MeasurementSystem.imperial_whole);
  });

  test("autoFetchTide defaults to false", () {
    expect(
      UserPreferenceManager.get.preference("auto_fetch_tide"),
      isNull,
    );
    expect(UserPreferenceManager.get.autoFetchTide, isFalse);
  });

  test("didShowTranslationWarning defaults to false", () {
    expect(
      UserPreferenceManager.get.preference("did_show_translation_warning"),
      isNull,
    );
    expect(UserPreferenceManager.get.didShowTranslationWarning, isFalse);
  });

  test("_isTrackingAtmosphereField when no IDs are tracked", () {
    expect(UserPreferenceManager.get.atmosphereFieldIds, isEmpty);
    expect(UserPreferenceManager.get.isTrackingMoonPhases, isTrue);
  });

  test("_isTrackingAtmosphereField when some IDs are tracked", () {
    UserPreferenceManager.get
        .setAtmosphereFieldIds([atmosphereFieldIdSkyCondition]);
    expect(UserPreferenceManager.get.isTrackingMoonPhases, isFalse);
  });

  test("_isTrackingCatchField when no IDs are tracked", () {
    expect(UserPreferenceManager.get.catchFieldIds, isEmpty);
    expect(UserPreferenceManager.get.isTrackingAnglers, isTrue);
  });

  test("_isTrackingCatchField when some IDs are tracked", () {
    UserPreferenceManager.get.setCatchFieldIds([catchFieldIdWaterClarity]);
    expect(UserPreferenceManager.get.isTrackingAnglers, isFalse);
  });

  test("Default fishing spot distance", () {
    expect(
      UserPreferenceManager.get.fishingSpotDistance,
      MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 100,
        ),
      ),
    );
  });

  test("Non-default fishing spot distance", () {
    UserPreferenceManager.get.setFishingSpotDistance(MultiMeasurement(
      system: MeasurementSystem.metric,
      mainValue: Measurement(
        unit: Unit.meters,
        value: 30,
      ),
    ));

    expect(
      UserPreferenceManager.get.fishingSpotDistance,
      MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 30,
        ),
      ),
    );
  });

  test("Default GPS trail distance", () {
    expect(
      UserPreferenceManager.get.minGpsTrailDistance,
      MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 150,
        ),
      ),
    );
  });

  test("Non-default fishing spot distance", () {
    UserPreferenceManager.get.setMinGpsTrailDistance(MultiMeasurement(
      system: MeasurementSystem.metric,
      mainValue: Measurement(
        unit: Unit.meters,
        value: 50,
      ),
    ));

    expect(
      UserPreferenceManager.get.minGpsTrailDistance,
      MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 50,
        ),
      ),
    );
  });

  test("statsDateRange returns null if absent", () {
    expect(UserPreferenceManager.get.statsDateRange, isNull);
  });

  test("statsDateRange returns non-null", () async {
    var dateRange = DateRange(
      startTimestamp: Int64(10),
      endTimestamp: Int64(15),
    );
    await UserPreferenceManager.get.setStatsDateRange(dateRange);
    expect(UserPreferenceManager.get.statsDateRange, isNotNull);
    expect(UserPreferenceManager.get.statsDateRange, dateRange);

    await UserPreferenceManager.get.setStatsDateRange(null);
    expect(UserPreferenceManager.get.statsDateRange, isNull);
  });

  test("Theme mode defaults to light", () async {
    expect(UserPreferenceManager.get.themeMode, ThemeMode.light);
  });

  test("Saved theme mode is returned", () async {
    await UserPreferenceManager.get.setThemeMode(ThemeMode.dark);
    expect(UserPreferenceManager.get.themeMode, ThemeMode.dark);
  });
}
