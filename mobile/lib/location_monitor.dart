import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'i18n/strings.dart';
import 'log.dart';
import 'wrappers/permission_handler_wrapper.dart';

class LocationMonitor {
  static LocationMonitor of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).locationMonitor;

  final _log = const Log("LocationMonitor");
  final _distanceFilterMeters = 10.0;
  final _controller = StreamController<LatLng?>.broadcast();

  final AppManager _appManager;
  final _location = Location();

  LatLng? _lastKnownLocation;
  bool _initialized = false;

  PermissionHandlerWrapper get _permissionHandler =>
      _appManager.permissionHandlerWrapper;

  LocationMonitor(this._appManager);

  Future<void> initialize() async {
    if (_initialized ||
        (!(await _permissionHandler.isLocationAlwaysGranted) &&
            !(await _permissionHandler.isLocationGranted))) {
      return;
    }

    await _location.changeSettings(distanceFilter: _distanceFilterMeters);

    // TODO: Location package doesn't get the "last known" location on startup;
    //  it waits for the next location to come in so we use Geolocator to get
    //  the last location immediately. Location package v5+ fixes this.
    geo.Geolocator.getCurrentPosition().then(
        (value) => _onLocationChanged(LatLng(value.latitude, value.longitude)));

    _location.onLocationChanged
        .listen((value) => _onLocationChanged(
            value.latitude == null || value.longitude == null
                ? null
                : LatLng(value.latitude!, value.longitude!)))
        .onError((error, _) => _log.d("Location stream error: $error"));

    _initialized = true;
  }

  Stream<LatLng?> get stream => _controller.stream;

  LatLng? get currentLocation => _lastKnownLocation;

  Future<bool> enableBackgroundMode(BuildContext context) async {
    await _location.changeNotificationOptions(
      title: Strings.of(context).permissionLocationNotificationDescription,
      iconName: "notification_icon",
      // TODO: Uncomment when
      //  https://github.com/Lyokone/flutterlocation/issues/702 is fixed.
      // onTapBringToFront: true,
    );
    return _location.enableBackgroundMode(enable: true);
  }

  Future<bool> disableBackgroundMode() =>
      _location.enableBackgroundMode(enable: false);

  void _onLocationChanged(LatLng? latLng) {
    if (latLng == null) {
      _log.w("Coordinates are null, nothing to do...");
      return;
    }

    _log.d("Received location update ${latLng.latitude}, ${latLng.longitude}");
    _lastKnownLocation = latLng;
    _controller.add(currentLocation);
  }
}
