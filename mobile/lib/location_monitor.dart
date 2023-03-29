import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'log.dart';
import 'wrappers/geolocator_wrapper.dart';
import 'wrappers/permission_handler_wrapper.dart';

class LocationMonitor {
  static LocationMonitor of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).locationMonitor;

  final _log = const Log("LocationMonitor");
  final _distanceFilterMeters = 10.0;
  final _controller = StreamController<LocationPoint>.broadcast();

  final AppManager _appManager;
  final Location _location;

  LocationPoint? _lastKnownLocation;
  bool _initialized = false;

  PermissionHandlerWrapper get _permissionHandler =>
      _appManager.permissionHandlerWrapper;

  LocationMonitor(this._appManager)
      : _location = _appManager.locationWrapper.newLocation();

  GeolocatorWrapper get _geolocatorWrapper => _appManager.geolocatorWrapper;

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
    _geolocatorWrapper
        .getCurrentPosition()
        .then((value) => _onLocationChanged(LocationPoint.fromPosition(value)));

    _location.onLocationChanged
        .listen((value) =>
            _onLocationChanged(LocationPoint.fromLocationData(value)))
        .onError((error, _) => _log.d("Location stream error: $error"));

    _initialized = true;
  }

  Stream<LocationPoint> get stream => _controller.stream;

  LatLng? get currentLatLng => _lastKnownLocation?.latLng;

  LocationPoint? get currentLocation => _lastKnownLocation;

  Future<bool> enableBackgroundMode(String notificationDescription) async {
    await _location.changeNotificationOptions(
      title: notificationDescription,
      iconName: "notification_icon",
      // TODO: Uncomment when
      //  https://github.com/Lyokone/flutterlocation/issues/702 is fixed.
      // onTapBringToFront: true,
    );
    return _location.enableBackgroundMode(enable: true);
  }

  Future<bool> disableBackgroundMode() =>
      _location.enableBackgroundMode(enable: false);

  void _onLocationChanged(LocationPoint loc) {
    if (!loc.isValid) {
      _log.w("Location ($loc) not valid, nothing to do...");
      return;
    }

    _log.d("Received location update $loc");
    _lastKnownLocation = loc;
    _controller.add(_lastKnownLocation!);
  }
}

class LocationPoint {
  static LocationPoint fromLocationData(LocationData data) {
    if (data.latitude == null || data.longitude == null) {
      return LocationPoint.invalid();
    }
    return LocationPoint(
      lat: data.latitude!,
      lng: data.longitude!,
      heading: data.heading,
    );
  }

  static LocationPoint fromPosition(Position pos) {
    return LocationPoint(
      lat: pos.latitude,
      lng: pos.longitude,
      heading: pos.heading,
    );
  }

  double lat;
  double lng;
  double? heading;

  LocationPoint({
    required this.lat,
    required this.lng,
    required this.heading,
  });

  LocationPoint.invalid()
      : lat = 0,
        lng = 0,
        heading = null;

  LatLng get latLng => LatLng(lat, lng);

  bool get isValid => lat != 0 && lng != 0;

  GpsTrailPoint toGpsTrailPoint(int timestamp) {
    return GpsTrailPoint(
      timestamp: Int64(timestamp),
      lat: lat,
      lng: lng,
      heading: heading,
    );
  }

  @override
  String toString() => "{lat=$lat, lng=$lng, heading=$heading}";
}
