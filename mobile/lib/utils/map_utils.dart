import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';

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

/// Returns an approximate distance between the given [LatLng] objects.
double distanceBetween(LatLng latLng1, LatLng latLng2) {
  // From https://sciencing.com/convert-distances-degrees-meters-7858322.html.
  var metersPerDegree = 111139;

  double latDelta = (latLng1.latitude - latLng2.latitude).abs();
  double lngDelta = (latLng1.longitude - latLng2.longitude).abs();
  double latDistance = latDelta * metersPerDegree;
  double lngDistance = lngDelta * metersPerDegree;

  return sqrt(pow(latDistance, 2) + pow(lngDistance, 2));
}

class FishingSpotMarker extends Marker {
  static final _normalIcon = BitmapDescriptor.defaultMarker;
  static final _activeIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

  final Id id;
  final FishingSpot fishingSpot;

  FishingSpotMarker({
    @required this.fishingSpot,
    void Function(FishingSpot) onTap,
    bool active = false,
  }) : id = fishingSpot.id, super(
    markerId: MarkerId(fishingSpot.id.uuid),
    position: LatLng(fishingSpot.lat, fishingSpot.lng),
    onTap: onTap == null ? null : () {
      onTap(fishingSpot);
    },
    icon: active ? _activeIcon : _normalIcon,
  );
}