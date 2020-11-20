import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'log.dart';

class LocationMonitor {
  static LocationMonitor of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).locationMonitor;

  final Log _log = Log("LocationMonitor");
  final distanceFilterMeters = 20;

  final Geolocator _geolocator = Geolocator();

  Position _lastKnownPosition = Position();

  Future<void> initialize() async {
    _lastKnownPosition = await _geolocator.getLastKnownPosition();
    var stream = _geolocator.getPositionStream(
      LocationOptions(
        distanceFilter: distanceFilterMeters,
      ),
    );
    stream.listen((position) {
      if (position != null) {
        _lastKnownPosition = position;
        _log.d("Received location update $currentLocation");
      }
    });
  }

  LatLng get currentLocation => _lastKnownPosition == null
      ? null
      : LatLng(_lastKnownPosition.latitude, _lastKnownPosition.longitude);
}
