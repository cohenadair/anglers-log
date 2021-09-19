import 'dart:math';

import 'package:mapbox_gl/mapbox_gl.dart';

import '../model/gen/anglerslog.pb.dart';

/// Returns an approximate distance, in meters, between the given [LatLng]
/// objects.
double distanceBetween(LatLng? latLng1, LatLng? latLng2) {
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

LatLngBounds? mapBounds(Iterable<FishingSpot> fishingSpots) {
  if (fishingSpots.isEmpty) {
    return null;
  }

  var mostWestLat = fishingSpots.first.lat;
  var mostEastLat = fishingSpots.first.lat;
  var mostNorthLng = fishingSpots.first.lng;
  var mostSouthLng = fishingSpots.first.lng;

  for (var fishingSpot in fishingSpots) {
    var lat = fishingSpot.lat;
    var lng = fishingSpot.lng;

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
