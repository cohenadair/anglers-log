import 'dart:math';

import 'package:adair_flutter_lib/res/theme.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:quiver/core.dart';

import '../catch_manager.dart';
import '../map/map_controller.dart';
import '../model/gen/anglers_log.pb.dart';
import 'protobuf_utils.dart';

// TODO: Move to map/ directory.

const mapZoomDefault = 13.0;

// From https://sciencing.com/convert-distances-degrees-meters-7858322.html.
const metersPerDegree = 111139;

// TODO: Move to its own class in the map/ directory.
// TODO: Abstract out Mapbox-specific functionality.
class MapType {
  static MapType of(BuildContext context) =>
      MapType.fromId(UserPreferenceManager.get.mapType) ??
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

  static const _allTypes = [light, satellite, dark];

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

// TODO: Move to map/ directory.
class SymbolTrail {
  final MapController? _mapController;
  final void Function(Id catchId)? _onCatchSymbolTapped;
  final List<Symbol> _symbols = [];

  SymbolTrail(this._mapController, [this._onCatchSymbolTapped]) {
    _mapController?.addOnSymbolTapped(_onSymbolTapped);
  }

  Future<void> clear() async {
    _mapController?.removeSymbols(_symbols);
    _mapController?.removeOnSymbolTapped(_onSymbolTapped);
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

    var symbols = <Symbol>[];
    for (int i = 0; i < trail.points.length; i++) {
      // Symbol already exists for this point.
      if (_symbols.length <= i) {
        symbols.add(Symbols.fromGpsTrailPoint(trail.points[i]));
      }
    }

    if (includeCatches) {
      var catches = CatchManager.get.catchesForGpsTrail(trail);
      for (var cat in catches) {
        final spot = FishingSpotManager.of(context).entity(cat.fishingSpotId)!;
        symbols.add(Symbols.fromFishingSpot(spot)..metadata.catchId = cat.id);
      }
    }

    await _mapController?.addSymbols(symbols);
    _symbols.addAll(_mapController?.symbols ?? []);
  }

  void _onSymbolTapped(Symbol symbol) {
    if (_onCatchSymbolTapped == null || !symbol.metadata.hasCatchId()) {
      return;
    }
    _onCatchSymbolTapped(symbol.metadata.catchId);
  }
}

/// Returns an approximate distance, in meters, between the given [LatLng]
/// objects.
// TODO: Move to LatLngs extension.
double distanceBetween(LatLng? latLng1, LatLng? latLng2) {
  if (latLng1 == null || latLng2 == null) {
    return 0;
  }

  var latDelta = (latLng1.lat - latLng2.lat).abs();
  var lngDelta = (latLng1.lng - latLng2.lng).abs();
  var latDistance = latDelta * metersPerDegree;
  var lngDistance = lngDelta * metersPerDegree;

  return sqrt(pow(latDistance, 2) + pow(lngDistance, 2));
}

// TODO: Move to FishingSpots extension.
LatLngBounds? fishingSpotMapBounds(Iterable<FishingSpot> fishingSpots) {
  return latLngsToBounds(fishingSpots.map((e) => e.latLng));
}

// TODO: Move to LatLngBoundsExt.
LatLngBounds? latLngsToBounds(Iterable<LatLng> latLngs) {
  if (latLngs.isEmpty) {
    return null;
  }

  var mostWestLat = latLngs.first.lat;
  var mostEastLat = latLngs.first.lat;
  var mostNorthLng = latLngs.first.lng;
  var mostSouthLng = latLngs.first.lng;

  for (var latLng in latLngs) {
    var lat = latLng.lat;
    var lng = latLng.lng;

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
    southwest: LatLng(lat: mostWestLat, lng: mostSouthLng),
    northeast: LatLng(lat: mostEastLat, lng: mostNorthLng),
  );
}

// TODO: Should be part of the MapType class.
Color mapIconColor(MapType mapType) =>
    mapType == MapType.light ? Colors.black : Colors.white;
