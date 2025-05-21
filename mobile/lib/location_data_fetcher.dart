import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/utils/permission_utils.dart';

import 'app_manager.dart';
import 'log.dart';
import 'widgets/fetch_input_header.dart';

class LocationDataFetcher<T> {
  static const _log = Log("LocationDataFetcher");

  LatLng? _latLng;

  LocationMonitor get _locationMonitor => AppManager.get.locationMonitor;

  LocationDataFetcher(this._latLng);

  LatLng? get latLng => _latLng;

  /// Returns null if this [LocationDataFetcher] has a valid [LatLng] value.
  /// Will request location permission from the user if needed.
  @protected
  @mustCallSuper
  Future<FetchInputResult<T?>?> fetch(BuildContext context) async {
    if (latLng != null) {
      return null;
    }

    var permissionError =
        Strings.of(context).locationDataFetcherPermissionError;

    var locationPermissionResult =
        await requestLocationPermissionWithResultIfNeeded(
      context,
      deniedMessage: Strings.of(context).locationDataFetcherErrorNoPermission,
    );

    switch (locationPermissionResult) {
      case RequestLocationResult.granted:
        _latLng = _locationMonitor.currentLatLng;
        return null;
      case RequestLocationResult.deniedDialog:
      case RequestLocationResult.inProgress:
        return FetchInputResult.noNotify();
      case RequestLocationResult.denied:
        // Shouldn't be possible with the flow of
        // requestLocationPermissionWithResultIfNeeded at this time.
        _log.e(StackTrace.current, "Impossible code path");
        return null;
      case RequestLocationResult.error:
        return FetchInputResult(data: null, errorMessage: permissionError);
    }
  }
}
