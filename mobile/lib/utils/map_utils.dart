import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:quiver/core.dart';

import '../model/gen/anglerslog.pb.dart';

import 'protobuf_utils.dart';

const mapPinActive = "active-pin";
const mapPinInactive = "inactive-pin";
const mapPinSize = 1.25;
const mapZoomDefault = 13.0;

class MapType {
  static MapType of(BuildContext context) =>
      MapType.fromId(UserPreferenceManager.of(context).mapType) ??
      MapType.normal;

  static MapType? fromId(String? id) =>
      _allTypes.firstWhereOrNull((e) => e.id == id);

  static const normal = MapType._(
    "normal",
    "ckt1zqb8d1h1p17pglx4pmz4y",
    "ckz1rne34000o14p36fu4of1y",
    "mapbox://styles/cohenadair/",
  );

  static const satellite = MapType._(
    "satellite",
    "ckt1m613b127t17qqf3mmw47h",
    "ckz1rts30002y15pq6t19lygy",
    "mapbox://styles/cohenadair/",
  );

  static const _allTypes = [
    normal,
    satellite,
  ];

  final String id;

  /// Mapbox ID for general map use.
  final String mapboxId;

  /// Mapbox ID for static map use.
  final String mapboxStaticId;

  final String _url;

  const MapType._(this.id, this.mapboxId, this.mapboxStaticId, this._url);

  String get url => "$_url$mapboxId";

  @override
  bool operator ==(Object other) =>
      other is MapType &&
      other.id == id &&
      other.mapboxId == other.mapboxId &&
      other._url == _url;

  @override
  int get hashCode => hash3(id, mapboxId, _url);
}

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

SymbolOptions createSymbolOptions(
  FishingSpot fishingSpot, {
  bool isActive = false,
}) {
  return SymbolOptions(
    geometry: fishingSpot.latLng,
    iconImage: isActive ? mapPinActive : mapPinInactive,
    iconSize: mapPinSize,
  );
}

Color mapIconColor(MapType mapType) =>
    mapType == MapType.normal ? Colors.black : Colors.white;
