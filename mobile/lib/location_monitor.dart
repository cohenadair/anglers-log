import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'log.dart';
import 'wrappers/permission_handler_wrapper.dart';

class LocationMonitor {
  static LocationMonitor of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).locationMonitor;

  final _log = const Log("LocationMonitor");
  final distanceFilterMeters = 20;

  final AppManager _appManager;

  Position? _lastKnownPosition;
  bool _initialized = false;

  PermissionHandlerWrapper get _permissionHandler =>
      _appManager.permissionHandlerWrapper;

  LocationMonitor(this._appManager);

  Future<void> initialize() async {
    if (_initialized || !(await _permissionHandler.isLocationGranted)) {
      return;
    }

    _lastKnownPosition = await Geolocator.getLastKnownPosition();

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        distanceFilter: distanceFilterMeters,
      ),
    ).listen((position) {
      _lastKnownPosition = position;
      _log.d("Received location update $currentLocation");
    }).onError((error, _) {
      // Don't crash the app if there's a location error. This can happen
      // occasionally when the app is in the background, and background modes
      // aren't correctly setup on iOS. Since we don't currently use background
      // locations, simply log an error.
      _log.d("Location stream error: $error");
    });

    _initialized = true;
  }

  LatLng? get currentLocation => _lastKnownPosition == null
      ? null
      : LatLng(_lastKnownPosition!.latitude, _lastKnownPosition!.longitude);
}
