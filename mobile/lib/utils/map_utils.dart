import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:quiver/core.dart';

import '../model/gen/anglerslog.pb.dart';

import '../res/dimen.dart';
import 'protobuf_utils.dart';

const mapPinActive = "active-pin";
const mapPinInactive = "inactive-pin";
const mapPinSize = 1.25;
const mapZoomDefault = 13.0;
const mapZoomFollowingUser = 18.0;
const mapLineDefaultWidth = 2.5;

class MapType {
  static MapType of(BuildContext context) =>
      MapType.fromId(UserPreferenceManager.of(context).mapType) ??
      MapType.normal;

  static MapType? fromId(String? id) =>
      _allTypes.firstWhereOrNull((e) => e.id == id);

  static const normal = MapType._(
    "normal",
    "ckt1zqb8d1h1p17pglx4pmz4y/draft",
    "ckz1rne34000o14p36fu4of1y",
    "mapbox://styles/cohenadair/",
  );

  static const satellite = MapType._(
    "satellite",
    "ckt1m613b127t17qqf3mmw47h/draft",
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

class GpsMapTrail {
  static const _sizeDirectionArrow = 0.75;

  final MapboxMapController? controller;
  final List<Symbol> _symbols = [];

  Line? _line;

  GpsMapTrail(this.controller);

  Future<void> clear() async {
    if (_line != null) {
      controller?.removeLine(_line!);
    }
    controller?.removeSymbols(_symbols);
  }

  Future<void> draw(BuildContext context, GpsTrail trail) async {
    var geometry = _geometryFromTrail(trail);

    // Nothing needs to be added, exit early.
    if (_symbols.length == geometry.length) {
      return;
    }

    var symbols = <SymbolOptions>[];
    for (int i = 0; i < geometry.length; i++) {
      // Symbol already exists for this point.
      if (_symbols.length > i) {
        continue;
      }

      // Don't draw an arrow for the last point, because we have no reference
      // from which to calculate the bearing.
      if (i == geometry.length - 1) {
        break;
      }

      symbols.add(SymbolOptions(
        iconImage: "direction-arrow",
        iconRotate: _bearing(geometry[i], geometry[i + 1]),
        iconSize: _sizeDirectionArrow,
        geometry: geometry[i],
      ));
    }

    _symbols.addAll(await controller?.addSymbols(symbols) ?? []);
  }

  List<LatLng> _geometryFromTrail(GpsTrail trail) => trail.points
      .sorted((a, b) => a.timestamp.compareTo(b.timestamp))
      .map((e) => e.latLng)
      .toList();

  /// Copied from https://pub.dev/packages/geodesy.
  double _bearing(LatLng l1, LatLng l2) {
    var l1LatRadians = _degreeToRadian(l1.latitude);
    var l2LatRadians = _degreeToRadian(l2.latitude);
    var lngRadiansDiff = _degreeToRadian(l2.longitude - l1.longitude);
    var y = sin(lngRadiansDiff) * cos(l2LatRadians);
    var x = cos(l1LatRadians) * sin(l2LatRadians) -
        sin(l1LatRadians) * cos(l2LatRadians) * cos(lngRadiansDiff);
    var radians = atan2(y, x);
    return (_radianToDegree(radians) + 360) % 360;
  }

  double _degreeToRadian(num degree) => degree * pi / 180;

  double _radianToDegree(num radian) => radian * 180 / pi;
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

LatLngBounds? fishingSpotMapBounds(Iterable<FishingSpot> fishingSpots) {
  return mapBounds(fishingSpots.map((e) => e.latLng));
}

LatLngBounds? mapBounds(Iterable<LatLng> latLngs) {
  if (latLngs.isEmpty) {
    return null;
  }

  var mostWestLat = latLngs.first.latitude;
  var mostEastLat = latLngs.first.latitude;
  var mostNorthLng = latLngs.first.longitude;
  var mostSouthLng = latLngs.first.longitude;

  for (var latLng in latLngs) {
    var lat = latLng.latitude;
    var lng = latLng.longitude;

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

extension LatLngBoundsExt on LatLngBounds {
  LatLng get center => LatLng(
      southwest.latitude + (southwest.latitude - northeast.latitude).abs() / 2,
      southwest.longitude +
          (southwest.longitude - northeast.longitude).abs() / 2);
}

extension MapboxMapControllers on MapboxMapController {
  Future<bool?> animateToBounds(LatLngBounds? bounds) {
    if (bounds == null) {
      return Future.value(false);
    }
    return animateCamera(CameraUpdate.newLatLngBounds(
      bounds,
      left: paddingXL,
      right: paddingXL,
      top: paddingXL,
      bottom: paddingXL,
    ));
  }

  Future<void> startTracking() =>
      updateMyLocationTrackingMode(MyLocationTrackingMode.Tracking);

  Future<void> stopTracking() =>
      updateMyLocationTrackingMode(MyLocationTrackingMode.None);
}
