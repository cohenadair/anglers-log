import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/floating_bottom_container.dart';

/// A widget for displaying a fishing spot on a small [GoogleMap]. The
/// [FishingSpot] name and coordinates are rendered in a floating widget
/// below the map marker.
class StaticFishingSpot extends StatelessWidget {
  final _mapHeight = 250.0;

  final FishingSpot fishingSpot;
  final EdgeInsets padding;
  final VoidCallback onTap;

  final Completer<GoogleMapController> _mapController;

  StaticFishingSpot(this.fishingSpot, {
    this.padding,
    this.onTap,
    Completer<GoogleMapController> mapController,
  }) : _mapController = mapController ?? Completer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      height: _mapHeight,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(floatingCornerRadius),
            ),
            // TODO: Use a real static Google Map image if an API is ever made for Flutter.
            child: GoogleMap(
              onMapCreated: (controller) {
                if (!_mapController.isCompleted) {
                  _mapController.complete(controller);
                }

                // TODO: Remove when fixed in Google Maps.
                // https://github.com/flutter/flutter/issues/27550
                Future.delayed(Duration(milliseconds: 250), () {
                  controller.moveCamera(
                      CameraUpdate.newLatLng(fishingSpot.latLng));
                });
              },
              initialCameraPosition: CameraPosition(
                target: fishingSpot.latLng,
                zoom: 15,
              ),
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              markers: Set.from([
                Marker(
                  markerId: MarkerId(fishingSpot.id),
                  position: fishingSpot.latLng,
                ),
              ]),
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: false,
              tiltGesturesEnabled: false,
              zoomGesturesEnabled: false,
            ),
          ),
          FloatingBottomContainer(
            title: fishingSpot.name,
            subtitle: formatLatLng(
              context: context,
              lat: fishingSpot.lat,
              lng: fishingSpot.lng,
            ),
            margin: insetsSmall,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}