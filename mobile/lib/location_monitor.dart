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

  final _log = Log("LocationMonitor");
  final distanceFilterMeters = 20;

  final AppManager appManager;

  Position? _lastKnownPosition;
  bool _initialized = false;

  PermissionHandlerWrapper get _permissionHandler =>
      appManager.permissionHandlerWrapper;

  LocationMonitor(this.appManager);

  Future<void> initialize() async {
    if (_initialized || !(await _permissionHandler.isLocationGranted)) {
      return;
    }

    _lastKnownPosition = await Geolocator.getLastKnownPosition();
    var stream = Geolocator.getPositionStream(
      distanceFilter: distanceFilterMeters,
    );
    stream.listen((position) {
      _lastKnownPosition = position;
      _log.d("Received location update $currentLocation");
    });

    _initialized = true;
  }

  LatLng? get currentLocation => _lastKnownPosition == null
      ? null
      : LatLng(_lastKnownPosition!.latitude, _lastKnownPosition!.longitude);
}
