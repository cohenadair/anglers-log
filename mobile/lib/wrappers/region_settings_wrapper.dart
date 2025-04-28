import 'package:flutter/material.dart';
import 'package:region_settings/region_settings.dart';

class RegionSettingsWrapper {
  static var _instance = RegionSettingsWrapper._();

  static RegionSettingsWrapper get get => _instance;

  @visibleForTesting
  static void set(RegionSettingsWrapper manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = RegionSettingsWrapper._();

  RegionSettingsWrapper._();

  late final RegionSettings settings;

  Future<RegionSettings> getSettings() => RegionSettings.getSettings();
}
