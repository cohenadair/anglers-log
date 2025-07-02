import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'log.dart';
import 'wrappers/geolocator_wrapper.dart';
import 'wrappers/permission_handler_wrapper.dart';

class LocationMonitor {
  static LocationMonitor of(BuildContext context) =>
      AppManager.get.locationMonitor;

  final _log = const Log("LocationMonitor");
  final _distanceFilterMeters = 10;
  final _controller = StreamController<LocationPoint>.broadcast();

  final AppManager _appManager;

  StreamSubscription<Position>? _positionUpdateSub;
  LocationPoint? _lastKnownLocation;
  bool _initialized = false;

  PermissionHandlerWrapper get _permissionHandler =>
      _appManager.permissionHandlerWrapper;

  LocationMonitor(this._appManager);

  GeolocatorWrapper get _geolocatorWrapper => _appManager.geolocatorWrapper;

  Future<void> initialize() async {
    if (_initialized ||
        (!(await _permissionHandler.isLocationAlwaysGranted) &&
            !(await _permissionHandler.isLocationGranted))) {
      return;
    }

    var pos = await _geolocatorWrapper.getLastKnownPosition();
    if (pos != null) {
      _onLocationChanged(LocationPoint.fromPosition(pos));
    }

    _updatePositionStream();
    _initialized = true;
  }

  Stream<LocationPoint> get stream => _controller.stream;

  LatLng? get currentLatLng => _lastKnownLocation?.latLng;

  LocationPoint? get currentLocation => _lastKnownLocation;

  void _updatePositionStream([String? notificationDescription]) {
    bool isBackgroundMode = isNotEmpty(notificationDescription);

    LocationSettings? settings;
    if (IoWrapper.get.isIOS) {
      settings = AppleSettings(
        distanceFilter: _distanceFilterMeters,
        showBackgroundLocationIndicator: isBackgroundMode,
        allowBackgroundLocationUpdates: isBackgroundMode,
        pauseLocationUpdatesAutomatically: !isBackgroundMode,
      );
    } else if (IoWrapper.get.isAndroid) {
      ForegroundNotificationConfig? foregroundConfig;
      if (isBackgroundMode) {
        // TODO: Set notification icon color
        //  https://github.com/Baseflow/flutter-geolocator/issues/1277
        foregroundConfig = ForegroundNotificationConfig(
          notificationTitle: notificationDescription!,
          notificationText: "",
        );
      }

      settings = AndroidSettings(
        distanceFilter: _distanceFilterMeters,
        foregroundNotificationConfig: foregroundConfig,
      );
    } else {
      _log.w("Unsupported OS");
    }

    _positionUpdateSub?.cancel();
    _positionUpdateSub =
        _geolocatorWrapper.getPositionStream(locationSettings: settings).listen(
              (pos) => _onLocationChanged(LocationPoint.fromPosition(pos)),
              onError: (e) => _log.w(
                  "Device location disabled or insufficient permission for updates"),
            );
  }

  Future<void> enableBackgroundMode(String notificationDescription) async {
    if (IoWrapper.get.isAndroid) {
      // TODO: Should probably show an explanation of why we need permission
      //  here (i.e. re-use NotificationPermissionPage).
      await _permissionHandler.requestNotification();
    }
    _updatePositionStream(notificationDescription);
  }

  void disableBackgroundMode() => _updatePositionStream();

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
