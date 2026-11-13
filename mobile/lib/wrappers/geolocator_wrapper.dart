import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:material_ui/material_ui.dart';

import '../app_manager.dart';

class GeolocatorWrapper {
  static GeolocatorWrapper of(BuildContext context) =>
      AppManager.get.geolocatorWrapper;

  Future<Position?> getLastKnownPosition() => Geolocator.getLastKnownPosition();

  Stream<Position> getPositionStream({LocationSettings? locationSettings}) =>
      Geolocator.getPositionStream(locationSettings: locationSettings);
}
