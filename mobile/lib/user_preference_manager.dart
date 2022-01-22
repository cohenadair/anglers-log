import 'package:flutter/material.dart';
import 'package:mobile/utils/atmosphere_utils.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'preference_manager.dart';
import 'utils/catch_utils.dart';

class UserPreferenceManager extends PreferenceManager {
  static UserPreferenceManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).userPreferenceManager;

  static const _keyAtmosphereFieldIds = "atmosphere_field_ids";
  static const _keyBaitVariantFieldIds = "bait_variant_field_ids";
  static const _keyCatchFieldIds = "catch_field_ids";
  static const _keyTripFieldIds = "trip_field_ids";
  static const _keyCatchLengthSystem = "catch_length_system";
  static const _keyCatchWeightSystem = "catch_weight_system";
  static const _keyWaterDepthSystem = "water_depth_system";
  static const _keyWaterTemperatureSystem = "water_temperature_system";
  static const _keyAirTemperatureSystem = "air_temperature_system";
  static const _keyAirPressureSystem = "air_pressure_system";
  static const _keyAirVisibilitySystem = "air_visibility_system";
  static const _keyWindSpeedSystem = "wind_speed_system";
  static const _keyAutoFetchAtmosphere = "auto_fetch_atmosphere";

  static const _keyRateTimerStartedAt = "rate_timer_started_at";
  static const _keyDidRateApp = "did_rate_app";
  static const _keyDidOnboard = "did_onboard";
  static const _keyDidSetupBackup = "did_setup_backup";
  static const _keyLastBackupAt = "last_backup_at";
  static const _keyAutoBackup = "auto_backup";
  static const _keyUserEmail = "user_email";
  static const _keyUserName = "user_name";

  static const _keySelectedReportId = "selected_report_id";
  static const _keyMapType = "map_type";

  UserPreferenceManager(AppManager appManager) : super(appManager);

  @override
  String get tableName => "user_preference";

  Future<void> setAtmosphereFieldIds(List<Id> ids) =>
      putIdCollection(_keyAtmosphereFieldIds, ids);

  List<Id> get atmosphereFieldIds => idList(_keyAtmosphereFieldIds);

  Future<void> setBaitVariantFieldIds(List<Id> ids) =>
      putIdCollection(_keyBaitVariantFieldIds, ids);

  List<Id> get baitVariantFieldIds => idList(_keyBaitVariantFieldIds);

  Future<void> setCatchFieldIds(List<Id> ids) =>
      putIdCollection(_keyCatchFieldIds, ids);

  List<Id> get catchFieldIds => idList(_keyCatchFieldIds);

  Future<void> setTripFieldIds(List<Id> ids) =>
      putIdCollection(_keyTripFieldIds, ids);

  List<Id> get tripFieldIds => idList(_keyTripFieldIds);

  Future<void> setCatchLengthSystem(MeasurementSystem? system) =>
      put(_keyCatchLengthSystem, system?.value);

  MeasurementSystem get catchLengthSystem =>
      MeasurementSystem.valueOf(preferences[_keyCatchLengthSystem] ??
          MeasurementSystem.imperial_whole.value)!;

  Future<void> setCatchWeightSystem(MeasurementSystem? system) =>
      put(_keyCatchWeightSystem, system?.value);

  MeasurementSystem get catchWeightSystem =>
      MeasurementSystem.valueOf(preferences[_keyCatchWeightSystem] ??
          MeasurementSystem.imperial_whole.value)!;

  Future<void> setWaterDepthSystem(MeasurementSystem? system) =>
      put(_keyWaterDepthSystem, system?.value);

  MeasurementSystem get waterDepthSystem =>
      MeasurementSystem.valueOf(preferences[_keyWaterDepthSystem] ??
          MeasurementSystem.imperial_whole.value)!;

  Future<void> setWaterTemperatureSystem(MeasurementSystem? system) =>
      put(_keyWaterTemperatureSystem, system?.value);

  MeasurementSystem get waterTemperatureSystem =>
      MeasurementSystem.valueOf(preferences[_keyWaterTemperatureSystem] ??
          MeasurementSystem.imperial_whole.value)!;

  Future<void> setAirTemperatureSystem(MeasurementSystem? system) =>
      put(_keyAirTemperatureSystem, system?.value);

  MeasurementSystem get airTemperatureSystem =>
      MeasurementSystem.valueOf(preferences[_keyAirTemperatureSystem] ??
          MeasurementSystem.imperial_whole.value)!;

  Future<void> setAirPressureSystem(MeasurementSystem? system) =>
      put(_keyAirPressureSystem, system?.value);

  MeasurementSystem get airPressureSystem =>
      MeasurementSystem.valueOf(preferences[_keyAirPressureSystem] ??
          MeasurementSystem.imperial_whole.value)!;

  Future<void> setAirVisibilitySystem(MeasurementSystem? system) =>
      put(_keyAirVisibilitySystem, system?.value);

  MeasurementSystem get airVisibilitySystem =>
      MeasurementSystem.valueOf(preferences[_keyAirVisibilitySystem] ??
          MeasurementSystem.imperial_whole.value)!;

  Future<void> setWindSpeedSystem(MeasurementSystem? system) =>
      put(_keyWindSpeedSystem, system?.value);

  MeasurementSystem get windSpeedSystem =>
      MeasurementSystem.valueOf(preferences[_keyWindSpeedSystem] ??
          MeasurementSystem.imperial_whole.value)!;

  // ignore: avoid_positional_boolean_parameters
  Future<void> setAutoFetchAtmosphere(bool autoFetch) =>
      put(_keyAutoFetchAtmosphere, autoFetch);

  bool get autoFetchAtmosphere => preferences[_keyAutoFetchAtmosphere] ?? false;

  Future<void> setRateTimerStartedAt(int? timestamp) =>
      put(_keyRateTimerStartedAt, timestamp);

  int? get rateTimerStartedAt => preferences[_keyRateTimerStartedAt];

  // ignore: avoid_positional_boolean_parameters
  Future<void> setDidRateApp(bool rated) => put(_keyDidRateApp, rated);

  bool get didRateApp => preferences[_keyDidRateApp] ?? false;

  // ignore: avoid_positional_boolean_parameters
  Future<void> setDidOnboard(bool onboarded) => put(_keyDidOnboard, onboarded);

  bool get didOnboard => preferences[_keyDidOnboard] ?? false;

  // ignore: avoid_positional_boolean_parameters
  Future<void> setDidSetupBackup(bool setupBackup) =>
      put(_keyDidSetupBackup, setupBackup);

  bool get didSetupBackup => preferences[_keyDidSetupBackup] ?? false;

  Future<void> setLastBackupAt(int lastBackupAt) =>
      put(_keyLastBackupAt, lastBackupAt);

  int? get lastBackupAt => preferences[_keyLastBackupAt];

  // ignore: avoid_positional_boolean_parameters
  Future<void> setAutoBackup(bool auto) => put(_keyAutoBackup, auto);

  bool get autoBackup => preferences[_keyAutoBackup] ?? false;

  Future<void> setSelectedReportId(Id? id) => putId(_keySelectedReportId, id);

  Id? get selectedReportId => id(_keySelectedReportId);

  Future<void> setMapType(String? type) => put(_keyMapType, type);

  String? get mapType => preferences[_keyMapType];

  Future<void> setUserEmail(String? email) => put(_keyUserEmail, email);

  String? get userEmail => preferences[_keyUserEmail];

  Future<void> setUserName(String? name) => put(_keyUserName, name);

  String? get userName => preferences[_keyUserName];

  bool _isTrackingAtmosphereField(Id fieldId) =>
      atmosphereFieldIds.isEmpty || atmosphereFieldIds.contains(fieldId);

  bool get isTrackingMoonPhases =>
      _isTrackingAtmosphereField(atmosphereFieldIdMoonPhase);

  bool _isTrackingCatchField(Id fieldId) =>
      catchFieldIds.isEmpty || catchFieldIds.contains(fieldId);

  bool get isTrackingAnglers => _isTrackingCatchField(catchFieldIdAngler);

  bool get isTrackingBaits => _isTrackingCatchField(catchFieldIdBait);

  bool get isTrackingFishingSpots =>
      _isTrackingCatchField(catchFieldIdFishingSpot);

  bool get isTrackingImages => _isTrackingCatchField(catchFieldIdImages);

  bool get isTrackingSpecies => _isTrackingCatchField(catchFieldIdSpecies);

  bool get isTrackingLength => _isTrackingCatchField(catchFieldIdLength);

  bool get isTrackingWeight => _isTrackingCatchField(catchFieldIdWeight);

  bool get isTrackingMethods => _isTrackingCatchField(catchFieldIdMethods);

  bool get isTrackingSeasons => _isTrackingCatchField(catchFieldIdSeason);

  bool get isTrackingTides => _isTrackingCatchField(catchFieldIdTide);

  bool get isTrackingPeriods => _isTrackingCatchField(catchFieldIdPeriod);

  bool get isTrackingWaterClarities =>
      _isTrackingCatchField(catchFieldIdWaterClarity);
}
