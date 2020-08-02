import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

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
    Widget name = isEmpty(fishingSpot.name) ? null : Label(fishingSpot.name,
      style: TextStyle(fontWeight: FontWeight.bold),
    );

    String latLngString = formatLatLng(context: context, lat: fishingSpot.lat,
        lng: fishingSpot.lng);
    Widget coordinates = Label(latLngString);
    if (name == null) {
      coordinates = SubtitleLabel(latLngString);
    }

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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: insetsSmall,
              decoration: FloatingBoxDecoration.rectangle(),
              child: Material(
                color: Colors.transparent,
                child: ListItem(
                  contentPadding: EdgeInsets.only(
                    left: paddingDefault,
                    right: paddingSmall,
                  ),
                  title: name ?? coordinates,
                  subtitle: name == null ? null : coordinates,
                  onTap: onTap,
                  trailing: onTap == null ? null : RightChevronIcon(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}