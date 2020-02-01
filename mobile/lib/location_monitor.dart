import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/log.dart';
import 'package:provider/provider.dart';

class LocationMonitor {
  static LocationMonitor of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).locationMonitor;

  static final LocationMonitor _instance = LocationMonitor._internal();
  factory LocationMonitor.get() => _instance;
  LocationMonitor._internal();

  final Log _log = Log("LocationMonitor");
  final distanceFilterMeters = 20;

  final Geolocator _geolocator = Geolocator();

  Position _lastKnownPosition = Position();

  Future<void> initialize() async {
    _lastKnownPosition = await _geolocator.getLastKnownPosition();
    _geolocator.getPositionStream(LocationOptions(
      distanceFilter: distanceFilterMeters,
    )).listen((Position position) {
      if (position != null) {
        _log.d("Received location update $currentLocation");
        _lastKnownPosition = position;
      }
    });
  }

  LatLng get currentLocation =>
      LatLng(_lastKnownPosition.latitude, _lastKnownPosition.longitude);
}