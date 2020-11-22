import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/gen/anglerslog.pb.dart';

void moveMap(Completer<GoogleMapController> controller, LatLng latLng,
    {bool animate = true}) {
  controller.future.then((controller) {
    var update = CameraUpdate.newLatLng(latLng);
    if (animate) {
      controller.animateCamera(update);
    } else {
      controller.moveCamera(update);
    }
  });
}

/// Returns an approximate distance, in meters, between the given [LatLng]
/// objects.
double distanceBetween(LatLng latLng1, LatLng latLng2) {
  if (latLng1 == null || latLng2 == null) {
    return 0;
  }

  // From https://sciencing.com/convert-distances-degrees-meters-7858322.html.
  var metersPerDegree = 111139;

  var latDelta = (latLng1.latitude - latLng2.latitude).abs();
  var lngDelta = (latLng1.longitude - latLng2.longitude).abs();
  var latDistance = latDelta * metersPerDegree;
  var lngDistance = lngDelta * metersPerDegree;

  return sqrt(pow(latDistance, 2) + pow(lngDistance, 2));
}

LatLngBounds mapBounds(Set<Marker> markers) {
  if (markers == null || markers.isEmpty) {
    return null;
  }

  var mostWestLat = markers.first.position.latitude;
  var mostEastLat = markers.first.position.latitude;
  var mostNorthLng = markers.first.position.longitude;
  var mostSouthLng = markers.first.position.longitude;

  for (var marker in markers) {
    var lat = marker.position.latitude;
    var lng = marker.position.longitude;

    if (lat < mostWestLat) {
      mostWestLat = lat;
    }

    if (lat > mostEastLat) {
      mostEastLat = lat;
    }

    if (lng < mostSouthLng) {
      mostSouthLng = lng;
    }

    if (lng > mostNorthLng) {
      mostNorthLng = lng;
    }
  }

  return LatLngBounds(
    southwest: LatLng(mostWestLat, mostSouthLng),
    northeast: LatLng(mostEastLat, mostNorthLng),
  );
}

class FishingSpotMarker extends Marker {
  static final _normalIcon = BitmapDescriptor.defaultMarker;
  static final _activeIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

  final Id id;
  final FishingSpot fishingSpot;
  final void Function(FishingSpot) onTapFishingSpot;
  final bool active;
  final double zIndex;

  FishingSpotMarker({
    @required this.fishingSpot,
    this.onTapFishingSpot,
    this.active = false,
    this.zIndex,
  })  : id = fishingSpot.id,
        super(
          markerId: MarkerId(fishingSpot.id.uuid),
          position: LatLng(fishingSpot.lat, fishingSpot.lng),
          onTap: onTapFishingSpot == null
              ? null
              : () => onTapFishingSpot(fishingSpot),
          icon: active ? _activeIcon : _normalIcon,
          zIndex: zIndex,
        );

  FishingSpotMarker duplicate({
    bool active = false,
    double zIndex,
  }) {
    return FishingSpotMarker(
      fishingSpot: fishingSpot,
      onTapFishingSpot: onTapFishingSpot,
      active: active,
      zIndex: zIndex ?? this.zIndex,
    );
  }
}
