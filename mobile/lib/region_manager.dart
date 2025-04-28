import 'package:flutter/material.dart';
import 'package:mobile/wrappers/region_settings_wrapper.dart';
import 'package:region_settings/region_settings.dart';

class RegionManager {
  static var _instance = RegionManager._();

  static RegionManager get get => _instance;

  @visibleForTesting
  static void set(RegionManager manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = RegionManager._();

  RegionManager._();

  late final RegionSettings settings;

  Future<void> init() async {
    settings = await RegionSettingsWrapper.get.getSettings();
  }

  String get decimalFormat => settings.numberFormat.decimal;
}
