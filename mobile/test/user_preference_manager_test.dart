import 'dart:convert';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/atmosphere_utils.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_app_manager.dart';

class TestUserPreferenceManager extends UserPreferenceManager {
  TestUserPreferenceManager(AppManager appManager) : super(appManager);

  dynamic preference(String key) => preferences[key];
}

void main() {
  late StubbedAppManager appManager;
  late TestUserPreferenceManager userPreferenceManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.localDatabaseManager.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());

    userPreferenceManager = TestUserPreferenceManager(appManager.app);
  });

  test("Gear is added to catch field IDs", () async {
    when(appManager.localDatabaseManager.fetchAll(any)).thenAnswer((_) {
      return Future.value([
        {
          "id": "catch_field_ids",
          "value": jsonEncode([catchFieldIdSpecies.uuid.toString()]),
        }
      ]);
    });
    var manager = TestUserPreferenceManager(appManager.app);
    await manager.initialize();
    expect(manager.catchFieldIds.contains(catchFieldIdGear), isTrue);
  });

  test("Gear is not added to catch field IDs", () async {
    when(appManager.localDatabaseManager.fetchAll(any)).thenAnswer((_) {
      return Future.value([
        {
          "id": "did_set_default_gear_tracking",
          "value": "true",
        }
      ]);
    });
    var manager = TestUserPreferenceManager(appManager.app);
    await manager.initialize();
    expect(manager.catchFieldIds.contains(catchFieldIdGear), isFalse);
  });

  test("catchLengthSystem defaults to imperial", () {
    expect(userPreferenceManager.preference("catch_length_system"), isNull);
    expect(userPreferenceManager.catchLengthSystem,
        MeasurementSystem.imperial_whole);
  });

  test("catchWeightSystem defaults to imperial", () {
    expect(userPreferenceManager.preference("catch_weight_system"), isNull);
    expect(userPreferenceManager.catchWeightSystem,
        MeasurementSystem.imperial_whole);
  });

  test("waterDepthSystem defaults to imperial", () {
    expect(userPreferenceManager.preference("water_depth_system"), isNull);
    expect(userPreferenceManager.waterDepthSystem,
        MeasurementSystem.imperial_whole);
  });

  test("waterTemperatureSystem defaults to imperial", () {
    expect(
        userPreferenceManager.preference("water_temperature_system"), isNull);
    expect(userPreferenceManager.waterTemperatureSystem,
        MeasurementSystem.imperial_whole);
  });

  test("airTemperatureSystem defaults to imperial", () {
    expect(userPreferenceManager.preference("air_temperature_system"), isNull);
    expect(userPreferenceManager.airTemperatureSystem,
        MeasurementSystem.imperial_whole);
  });

  test("airPressureSystem defaults to imperial", () {
    expect(userPreferenceManager.preference("air_pressure_system"), isNull);
    expect(userPreferenceManager.airPressureSystem,
        MeasurementSystem.imperial_decimal);
  });

  test("airPressureImperialUnit defaults to inHg", () {
    expect(
        userPreferenceManager.preference("air_pressure_imperial_unit"), isNull);
    expect(userPreferenceManager.airPressureImperialUnit, Unit.inch_of_mercury);
  });

  test("airVisibilitySystem defaults to imperial", () {
    expect(userPreferenceManager.preference("air_visibility_system"), isNull);
    expect(userPreferenceManager.airVisibilitySystem,
        MeasurementSystem.imperial_whole);
  });

  test("windSpeedSystem defaults to imperial", () {
    expect(userPreferenceManager.preference("wind_speed_system"), isNull);
    expect(userPreferenceManager.windSpeedSystem,
        MeasurementSystem.imperial_whole);
  });

  test("tideHeightSystem defaults to imperial", () {
    expect(userPreferenceManager.preference("tide_height_system"), isNull);
    expect(userPreferenceManager.tideHeightSystem,
        MeasurementSystem.imperial_whole);
  });

  test("rodLengthSystem defaults to imperial", () {
    expect(userPreferenceManager.preference("rod_length_system"), isNull);
    expect(userPreferenceManager.rodLengthSystem,
        MeasurementSystem.imperial_whole);
  });

  test("leaderLengthSystem defaults to imperial", () {
    expect(userPreferenceManager.preference("leader_length_system"), isNull);
    expect(userPreferenceManager.leaderLengthSystem,
        MeasurementSystem.imperial_whole);
  });

  test("tippetLengthSystem defaults to imperial", () {
    expect(userPreferenceManager.preference("tippet_length_system"), isNull);
    expect(userPreferenceManager.tippetLengthSystem,
        MeasurementSystem.imperial_whole);
  });

  test("autoFetchTide defaults to false", () {
    expect(userPreferenceManager.preference("auto_fetch_tide"), isNull);
    expect(userPreferenceManager.autoFetchTide, isFalse);
  });

  test("_isTrackingAtmosphereField when no IDs are tracked", () {
    expect(userPreferenceManager.atmosphereFieldIds, isEmpty);
    expect(userPreferenceManager.isTrackingMoonPhases, isTrue);
  });

  test("_isTrackingAtmosphereField when some IDs are tracked", () {
    userPreferenceManager
        .setAtmosphereFieldIds([atmosphereFieldIdSkyCondition]);
    expect(userPreferenceManager.isTrackingMoonPhases, isFalse);
  });

  test("_isTrackingCatchField when no IDs are tracked", () {
    expect(userPreferenceManager.catchFieldIds, isEmpty);
    expect(userPreferenceManager.isTrackingAnglers, isTrue);
  });

  test("_isTrackingCatchField when some IDs are tracked", () {
    userPreferenceManager.setCatchFieldIds([catchFieldIdWaterClarity]);
    expect(userPreferenceManager.isTrackingAnglers, isFalse);
  });

  test("Default fishing spot distance", () {
    expect(
      userPreferenceManager.fishingSpotDistance,
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
    userPreferenceManager.setFishingSpotDistance(MultiMeasurement(
      system: MeasurementSystem.metric,
      mainValue: Measurement(
        unit: Unit.meters,
        value: 30,
      ),
    ));

    expect(
      userPreferenceManager.fishingSpotDistance,
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
      userPreferenceManager.minGpsTrailDistance,
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
    userPreferenceManager.setMinGpsTrailDistance(MultiMeasurement(
      system: MeasurementSystem.metric,
      mainValue: Measurement(
        unit: Unit.meters,
        value: 50,
      ),
    ));

    expect(
      userPreferenceManager.minGpsTrailDistance,
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
    expect(userPreferenceManager.statsDateRange, isNull);
  });

  test("statsDateRange returns non-null", () async {
    var dateRange = DateRange(
      startTimestamp: Int64(10),
      endTimestamp: Int64(15),
    );
    await userPreferenceManager.setStatsDateRange(dateRange);
    expect(userPreferenceManager.statsDateRange, isNotNull);
    expect(userPreferenceManager.statsDateRange, dateRange);

    await userPreferenceManager.setStatsDateRange(null);
    expect(userPreferenceManager.statsDateRange, isNull);
  });

  test("Theme mode defaults to light", () async {
    expect(userPreferenceManager.themeMode, ThemeMode.light);
  });

  test("Saved theme mode is returned", () async {
    await userPreferenceManager.setThemeMode(ThemeMode.dark);
    expect(userPreferenceManager.themeMode, ThemeMode.dark);
  });
}
