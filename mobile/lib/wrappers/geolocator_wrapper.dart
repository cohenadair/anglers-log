import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class GeolocatorWrapper {
  static GeolocatorWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).geolocatorWrapper;

  Future<Position?> getLastKnownPosition() => Geolocator.getLastKnownPosition();

  Stream<Position> getPositionStream({LocationSettings? locationSettings}) =>
      Geolocator.getPositionStream(locationSettings: locationSettings);
}
