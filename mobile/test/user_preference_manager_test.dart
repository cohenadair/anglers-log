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

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());

    userPreferenceManager = TestUserPreferenceManager(appManager.app);
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
        ));
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
}
