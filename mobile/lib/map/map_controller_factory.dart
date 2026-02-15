import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'map_controller.dart';
import 'mapbox_map_controller.dart';

class MapControllerFactory {
  static var _instance = MapControllerFactory._();

  static MapControllerFactory get get => _instance;

  @visibleForTesting
  static void set(MapControllerFactory manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = MapControllerFactory._();

  MapControllerFactory._();

  Future<MapController> createMapbox(
    MapboxMap map, {
    bool myLocationEnabled = true,
  }) {
    return MapboxMapController.create(
      map,
      myLocationEnabled: myLocationEnabled,
    );
  }
}
