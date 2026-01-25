import 'package:adair_flutter_lib/widgets/safe_future_builder.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/map/map_controller.dart';
import 'package:mobile/widgets/static_fishing_spot_map.dart';

import '../map/lat_lng.dart';
import '../map/mapbox_map_controller.dart';
import '../utils/map_utils.dart';

/// A [MapboxMap] wrapper with default values/functionality set for this app.
///
/// See:
///  - [StaticFishingSpotMap]
///  - [FishingSpotMap]
///  - [EditCoordinatesPage]
class DefaultMapboxMap extends StatefulWidget {
  final LatLng? startPosition;
  final double? startZoom;
  final String? style;
  final bool isMyLocationEnabled;

  final void Function(MapController)? onMapCreated;

  /// See [MapWidget.onStyleLoadedListener].
  final OnStyleLoadedListener? onStyleLoadedListener;

  /// See [MapWidget.onMapIdleListener].
  final OnMapIdleListener? onMapIdle;

  /// See [MapWidget.onCameraChangeListener].
  final OnCameraChangeListener? onCameraChangeListener;

  const DefaultMapboxMap({
    this.startPosition,
    Key? key,
    this.startZoom,
    this.style,
    this.isMyLocationEnabled = false,
    this.onMapCreated,
    this.onStyleLoadedListener,
    this.onMapIdle,
    this.onCameraChangeListener,
  });

  @override
  State<DefaultMapboxMap> createState() => _DefaultMapboxMapState();
}

class _DefaultMapboxMapState extends State<DefaultMapboxMap> {
  // Wait for navigation animations to finish before loading the map. This
  // allows for a smooth animation.
  // TODO: Is this still needed?
  late final Future<bool> _mapFuture;

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  @override
  void initState() {
    super.initState();
    _mapFuture = Future.delayed(const Duration(milliseconds: 300), () => true);
  }

  @override
  Widget build(BuildContext context) {
    var start =
        widget.startPosition ??
        _locationMonitor.currentLatLng ??
        const LatLng(0, 0);

    return SafeFutureBuilder<bool>(
      future: _mapFuture,
      errorReason: "Loading map",
      builder: (context, _) {
        return MapWidget(
          // Hide default attribution views, so we can show our own and
          // position them easier.
          // TODO: What's the new equivalent?
          // attributionButtonMargins: const Point(0, -1000),
          // logoViewMargins: const Point(0, -1000),
          // TODO: Must disable "my location" on Android due to a crash caused
          //   by conflicting Google Play Services versions between the
          //   Geolocator and Mapbox plugins. Undo this change has part of #762.
          //   More details on crash:
          //     https://github.com/Baseflow/flutter-geolocator/issues/1214
          // myLocationEnabled: IoWrapper.get.isAndroid
          //     ? false
          //     : widget.isMyLocationEnabled,
          styleUri: widget.style ?? MapType.of(context).url,
          cameraOptions: CameraOptions(
            center: start.toMapboxPoint(),
            zoom: start.latitude == 0 ? 0 : widget.startZoom ?? mapZoomDefault,
          ),
          onMapCreated: (mapboxMap) =>
              widget.onMapCreated?.call(MapboxMapController(mapboxMap)),
          onStyleLoadedListener: widget.onStyleLoadedListener,
          onMapIdleListener: widget.onMapIdle,
          onCameraChangeListener: widget.onCameraChangeListener,
          // TODO: What's the new equivalent?
          // trackCameraPosition: true,
          // compassEnabled: false,
        );
      },
    );
  }
}
