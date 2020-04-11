import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/fishing_spot.dart';

void moveMap(Completer<GoogleMapController> controller, LatLng latLng,
    [bool animate = true])
{
  controller.future.then((controller) {
    var update = CameraUpdate.newLatLng(latLng);
    if (animate) {
      controller.animateCamera(update);
    } else {
      controller.moveCamera(update);
    }
  });
}

class FishingSpotMarker extends Marker {
  static final _normalIcon = BitmapDescriptor.defaultMarker;
  static final _activeIcon =
  BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

  FishingSpotMarker({
    @required FishingSpot fishingSpot,
    void Function(FishingSpot) onTap,
    bool active = false,
  }) : super(
    markerId: MarkerId(fishingSpot.id),
    position: fishingSpot.latLng,
    onTap: onTap == null ? null : () {
      onTap(fishingSpot);
    },
    icon: active ? _activeIcon : _normalIcon,
  );
}