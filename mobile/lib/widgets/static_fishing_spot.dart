import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/floating_container.dart';

/// A widget for displaying a fishing spot on a small [GoogleMap]. The
/// [FishingSpot] name and coordinates are rendered in a floating widget
/// below the map marker.
class StaticFishingSpot extends StatefulWidget {
  final FishingSpot fishingSpot;
  final EdgeInsets padding;
  final VoidCallback onTap;

  StaticFishingSpot(
    this.fishingSpot, {
    this.padding,
    this.onTap,
    Completer<GoogleMapController> mapController,
  });

  @override
  _StaticFishingSpotState createState() => _StaticFishingSpotState();
}

class _StaticFishingSpotState extends State<StaticFishingSpot> {
  final _mapHeight = 250.0;
  final _mapZoom = 15.0;
  final _mapPositionOffset = 0.001500;

  final Completer<GoogleMapController> _mapController = Completer();

  // Need to offset the map position so the marker appears in the middle of
  // the bottom of the map and the floating container.
  LatLng get _cameraPosition => LatLng(
      widget.fishingSpot.lat + _mapPositionOffset, widget.fishingSpot.lng);

  @override
  void didUpdateWidget(StaticFishingSpot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.fishingSpot != oldWidget.fishingSpot) {
      moveMap(_mapController, _cameraPosition, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng cameraPosition = _cameraPosition;

    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        padding: widget.padding,
        height: _mapHeight,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(floatingCornerRadius),
              ),
              // TODO: Use a real static Google Map image if an API is ever made for Flutter.
              // TODO: Move Google logo - https://github.com/flutter/flutter/issues/39610
              child: GoogleMap(
                onMapCreated: (controller) {
                  if (!_mapController.isCompleted) {
                    _mapController.complete(controller);
                  }

                  // TODO: Remove when fixed in Google Maps.
                  // https://github.com/flutter/flutter/issues/27550
                  Future.delayed(Duration(milliseconds: 250), () {
                    controller
                        .moveCamera(CameraUpdate.newLatLng(cameraPosition));
                  });
                },
                initialCameraPosition: CameraPosition(
                  target: cameraPosition,
                  zoom: _mapZoom,
                ),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                markers: Set.from([
                  Marker(
                    markerId: MarkerId(widget.fishingSpot.id.uuid),
                    position: widget.fishingSpot.latLng,
                  ),
                ]),
                rotateGesturesEnabled: false,
                scrollGesturesEnabled: false,
                tiltGesturesEnabled: false,
                zoomGesturesEnabled: false,
              ),
            ),
            FloatingContainer(
              title: widget.fishingSpot.name,
              subtitle: formatLatLng(
                context: context,
                lat: widget.fishingSpot.lat,
                lng: widget.fishingSpot.lng,
              ),
              margin: insetsSmall,
              alignment: Alignment.topCenter,
              onTap: widget.onTap,
            ),
          ],
        ),
      ),
    );
  }
}
