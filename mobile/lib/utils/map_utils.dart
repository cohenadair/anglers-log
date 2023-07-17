import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:quiver/core.dart';
import 'package:quiver/strings.dart';

import '../catch_manager.dart';
import '../model/gen/anglerslog.pb.dart';

import '../res/dimen.dart';
import 'protobuf_utils.dart';

const mapPinActive = "active-pin";
const mapPinInactive = "inactive-pin";
const mapPinSize = 1.25;
const mapImageDirectionArrow = "direction-arrow";
const mapZoomDefault = 13.0;
const mapZoomFollowingUser = 18.0;
const mapLineDefaultWidth = 2.5;

// From https://sciencing.com/convert-distances-degrees-meters-7858322.html.
const metersPerDegree = 111139;

class MapType {
  static MapType of(BuildContext context) =>
      MapType.fromId(UserPreferenceManager.of(context).mapType) ??
      (context.isDarkTheme ? MapType.dark : MapType.light);

  static MapType? fromId(String? id) =>
      _allTypes.firstWhereOrNull((e) => e.id == id);

  static const light = MapType._(
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

  static const dark = MapType._(
    "dark",
    "clgo7x3ne008a01pa2pi4e0h2",
    "clgo8mr7o008k01nu7oj86r25",
    "mapbox://styles/cohenadair/",
  );

  static const _allTypes = [
    light,
    satellite,
    dark,
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
  static const _symbolDataCatchId = "catch_id";

  final MapboxMapController? controller;
  final void Function(Id catchId)? onCatchSymbolTapped;
  final List<Symbol> _symbols = [];

  GpsMapTrail(this.controller, [this.onCatchSymbolTapped]) {
    controller?.onSymbolTapped.add(_onSymbolTapped);
  }

  Future<void> clear() async {
    controller?.removeSymbols(_symbols);
    controller?.onSymbolTapped.remove(_onSymbolTapped);
  }

  Future<void> draw(
    BuildContext context,
    GpsTrail trail, {
    bool includeCatches = false,
  }) async {
    // Nothing needs to be added, exit early.
    if (_symbols.length == trail.points.length) {
      return;
    }

    var symbols = <SymbolOptions>[];
    var data = <Map<String, dynamic>>[];
    for (int i = 0; i < trail.points.length; i++) {
      // Symbol already exists for this point.
      if (_symbols.length > i) {
        continue;
      }

      symbols.add(SymbolOptions(
        iconImage: mapImageDirectionArrow,
        iconRotate: trail.points[i].heading,
        iconSize: _sizeDirectionArrow,
        geometry: trail.points[i].latLng,
      ));
      data.add({});
    }

    if (includeCatches) {
      var catches = CatchManager.of(context).catchesForGpsTrail(trail);
      for (var cat in catches) {
        symbols.add(SymbolOptions(
          iconImage: mapPinInactive,
          iconSize: mapPinSize,
          geometry:
              FishingSpotManager.of(context).entity(cat.fishingSpotId)!.latLng,
        ));
        data.add({_symbolDataCatchId: cat.id.uuid});
      }
    }

    _symbols.addAll(await controller?.addSymbols(symbols, data) ?? []);
  }

  void _onSymbolTapped(Symbol symbol) {
    if (onCatchSymbolTapped == null) {
      return;
    }

    var id = symbol.data?[_symbolDataCatchId];
    if (isEmpty(id)) {
      return;
    }

    onCatchSymbolTapped!(Id(uuid: id));
  }
}

/// Returns an approximate distance, in meters, between the given [LatLng]
/// objects.
double distanceBetween(LatLng? latLng1, LatLng? latLng2) {
  if (latLng1 == null || latLng2 == null) {
    return 0;
  }

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
    mapType == MapType.light ? Colors.black : Colors.white;

extension LatLngs on LatLng {
  static const numOfDigits = 6;

  String get latitudeString => latitude.toStringAsFixed(numOfDigits);

  String get longitudeString => longitude.toStringAsFixed(numOfDigits);
}

extension LatLngBoundsExt on LatLngBounds {
  LatLng get center => LatLng(
      southwest.latitude + (southwest.latitude - northeast.latitude).abs() / 2,
      southwest.longitude +
          (southwest.longitude - northeast.longitude).abs() / 2);

  LatLngBounds grow(double byMeters) {
    var offset = byMeters / metersPerDegree;
    return LatLngBounds(
      northeast:
          LatLng(northeast.latitude + offset, northeast.longitude + offset),
      southwest:
          LatLng(southwest.latitude - offset, southwest.longitude - offset),
    );
  }

  bool contains(LatLng latLng) {
    return latLng.latitude <= northeast.latitude &&
        latLng.latitude >= southwest.latitude &&
        latLng.longitude <= northeast.longitude &&
        latLng.longitude >= southwest.longitude;
  }
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
