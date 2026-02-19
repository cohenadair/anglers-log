import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxWrapper {
  static var _instance = MapboxWrapper._();

  static MapboxWrapper get get => _instance;

  @visibleForTesting
  static void set(MapboxWrapper manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = MapboxWrapper._();

  MapboxWrapper._();

  void setAccessToken(String token) => MapboxOptions.setAccessToken(token);
}
