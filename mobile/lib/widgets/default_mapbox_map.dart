import 'package:adair_flutter_lib/widgets/safe_future_builder.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/map/map_controller.dart';
import 'package:mobile/map/map_controller_factory.dart';
import 'package:mobile/widgets/static_fishing_spot_map.dart';

import '../map/mapbox_map_controller.dart';
import '../model/gen/anglers_log.pb.dart';
import '../utils/map_utils.dart';
import '../utils/protobuf_utils.dart';

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
        widget.startPosition ?? _locationMonitor.currentLatLng ?? LatLngs.zero;

    return SafeFutureBuilder<bool>(
      future: _mapFuture,
      errorReason: "Loading map",
      builder: (context, _) {
        return MapWidget(
          styleUri: widget.style ?? MapType.of(context).url,
          cameraOptions: CameraOptions(
            center: start.point,
            zoom: start.lat == 0 ? 0 : widget.startZoom ?? mapZoomDefault,
          ),
          onMapCreated: (mapboxMap) => MapControllerFactory.get.createMapbox(
            mapboxMap,
            myLocationEnabled: widget.isMyLocationEnabled,
          ).then((mapboxMap) => widget.onMapCreated?.call(mapboxMap)),
          onMapIdleListener: widget.onMapIdle,
          onCameraChangeListener: widget.onCameraChangeListener,
        );
      },
    );
  }
}
