import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/utils/map_utils.dart';

import '../properties_manager.dart';
import 'widget.dart';

/// A [MapboxMap] wrapper with default values/functionality set for this app.
class DefaultMapboxMap extends StatefulWidget {
  final LatLng startPosition;
  final String? style;
  final bool isMyLocationEnabled;

  /// See [MapboxMap.onMapCreated].
  final MapCreatedCallback? onMapCreated;

  /// See [MapboxMap.onStyleLoadedCallback].
  final OnStyleLoadedCallback? onStyleLoadedCallback;

  /// See [MapboxMap.onCameraIdle].
  final OnCameraIdleCallback? onCameraIdle;

  const DefaultMapboxMap({
    required this.startPosition,
    Key? key,
    this.style,
    this.isMyLocationEnabled = false,
    this.onMapCreated,
    this.onStyleLoadedCallback,
    this.onCameraIdle,
  });

  @override
  State<DefaultMapboxMap> createState() => _DefaultMapboxMapState();
}

class _DefaultMapboxMapState extends State<DefaultMapboxMap> {
  // Wait for navigation animations to finish before loading the map. This
  // allows for a smooth animation.
  late final Future<bool> _mapFuture;

  @override
  void initState() {
    super.initState();
    _mapFuture = Future.delayed(const Duration(milliseconds: 300), () => true);
  }

  @override
  Widget build(BuildContext context) {
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
            target: widget.startPosition,
            zoom: widget.startPosition.latitude == 0 ? 0 : mapZoomDefault,
          ),
          onMapCreated: widget.onMapCreated,
          onStyleLoadedCallback: widget.onStyleLoadedCallback,
          onCameraIdle: widget.onCameraIdle,
          trackCameraPosition: true,
          compassEnabled: false,
        );
      },
    );
  }
}
