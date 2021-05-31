import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../utils/map_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/floating_container.dart';
import 'widget.dart';

/// A widget for displaying a fishing spot on a small [GoogleMap]. The
/// [FishingSpot] name and coordinates are rendered in a floating widget
/// below the map marker.
class StaticFishingSpot extends StatefulWidget {
  final FishingSpot fishingSpot;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  StaticFishingSpot(
    this.fishingSpot, {
    this.padding,
    this.onTap,
  });

  @override
  _StaticFishingSpotState createState() => _StaticFishingSpotState();
}

// TODO: Map moves slightly when scrolling inside a scrollable view; for
//  example, SaveCatchPage. Verify fixed when Google Maps library is updated.

class _StaticFishingSpotState extends State<StaticFishingSpot> {
  final _mapHeight = 250.0;
  final _mapZoom = 15.0;
  final _mapPositionOffset = 0.001250;

  final Completer<GoogleMapController> _mapController = Completer();

  // TODO: Remove this when Google Maps performance issue is fixed.
  // https://github.com/flutter/flutter/issues/28493
  late final Future<bool> _mapFuture;

  // Need to offset the map position so the marker appears in the middle of
  // the bottom of the map and the floating container.
  LatLng get _cameraPosition => LatLng(
      widget.fishingSpot.lat + _mapPositionOffset, widget.fishingSpot.lng);

  @override
  void initState() {
    super.initState();
    _mapFuture = Future.delayed(Duration(milliseconds: 150), () => true);
  }

  @override
  void didUpdateWidget(StaticFishingSpot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.fishingSpot != oldWidget.fishingSpot) {
      moveMap(_mapController, _cameraPosition, animate: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HorizontalSafeArea(
      child: Container(
        padding: widget.padding,
        height: _mapHeight,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(floatingCornerRadius),
              ),
              child: IgnorePointer(
                child: _buildMap(),
              ),
            ),
            _buildFishingSpot(),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    var loadingColor = Colors.grey.shade100;

    return FutureBuilder<bool>(
      future: _mapFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(color: loadingColor);
        }

        return Stack(
          children: [
            GoogleMap(
              onMapCreated: (controller) {
                if (!_mapController.isCompleted) {
                  _mapController.complete(controller);
                }
              },
              initialCameraPosition: CameraPosition(
                target: _cameraPosition,
                zoom: _mapZoom,
              ),
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              markers: {
                Marker(
                  markerId: MarkerId(widget.fishingSpot.id.uuid),
                  position: widget.fishingSpot.latLng,
                ),
              },
              mapToolbarEnabled: false,
            ),
            // TODO: GoogleMap, on iOS, "jumps" the marker from the top left to
            //  the center on initial load. Using a FutureBuilder here ensures
            //  a smooth animation when rendering the map. See
            //  https://github.com/flutter/flutter/issues/27550.
            FutureBuilder<bool>(
              future: Future.delayed(Duration(milliseconds: 50), () => true),
              builder: (context, snapshot) => AnimatedSwitcher(
                duration: defaultAnimationDuration,
                child: snapshot.hasData ? Empty() : Container(
                  color: loadingColor,
                  constraints: BoxConstraints.expand(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFishingSpot() {
    return FloatingContainer(
      title: widget.fishingSpot.name,
      subtitle: formatLatLng(
        context: context,
        lat: widget.fishingSpot.lat,
        lng: widget.fishingSpot.lng,
      ),
      margin: insetsSmall,
      alignment: Alignment.topCenter,
      onTap: widget.onTap,
    );
  }
}
