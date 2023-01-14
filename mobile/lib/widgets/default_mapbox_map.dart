import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/widgets/static_fishing_spot_map.dart';

import '../properties_manager.dart';
import 'widget.dart';

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

  /// See [MapboxMap.onMapCreated].
  final MapCreatedCallback? onMapCreated;

  /// See [MapboxMap.onStyleLoadedCallback].
  final OnStyleLoadedCallback? onStyleLoadedCallback;

  /// See [MapboxMap.onCameraIdle].
  final OnCameraIdleCallback? onCameraIdle;

  /// See [MapboxMap.onCameraTrackingChanged].
  final OnCameraTrackingChangedCallback? onCameraTrackingChanged;

  const DefaultMapboxMap({
    this.startPosition,
    Key? key,
    this.startZoom,
    this.style,
    this.isMyLocationEnabled = false,
    this.onMapCreated,
    this.onStyleLoadedCallback,
    this.onCameraIdle,
    this.onCameraTrackingChanged,
  });

  @override
  State<DefaultMapboxMap> createState() => _DefaultMapboxMapState();
}

class _DefaultMapboxMapState extends State<DefaultMapboxMap> {
  // Wait for navigation animations to finish before loading the map. This
  // allows for a smooth animation.
  late final Future<bool> _mapFuture;

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  @override
  void initState() {
    super.initState();
    _mapFuture = Future.delayed(const Duration(milliseconds: 300), () => true);
  }

  @override
  Widget build(BuildContext context) {
    var start = widget.startPosition ??
        _locationMonitor.currentLatLng ??
        const LatLng(0, 0);

    return EmptyFutureBuilder<bool>(
      future: _mapFuture,
      builder: (context, _) {
        return MapboxMap(
          accessToken: PropertiesManager.of(context).mapboxApiKey,
          // Hide default attribution views, so we can show our own and
          // position them easier.
          attributionButtonMargins: const Point(0, -1000),
          logoViewMargins: const Point(0, -1000),
          myLocationEnabled: widget.isMyLocationEnabled,
          styleString: widget.style ?? MapType.of(context).url,
          initialCameraPosition: CameraPosition(
            target: start,
            zoom: start.latitude == 0 ? 0 : widget.startZoom ?? mapZoomDefault,
          ),
          onMapCreated: widget.onMapCreated,
          onStyleLoadedCallback: widget.onStyleLoadedCallback,
          onCameraIdle: widget.onCameraIdle,
          onCameraTrackingChanged: widget.onCameraTrackingChanged,
          trackCameraPosition: true,
          compassEnabled: false,
        );
      },
    );
  }
}
