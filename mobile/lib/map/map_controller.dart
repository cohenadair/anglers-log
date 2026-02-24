import 'package:flutter/material.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';

import '../utils/map_utils.dart';

typedef OnSymbolTappedCallback = void Function(Symbol);
typedef OnMapCreatedCallback = void Function(MapController);

abstract class MapController {
  /// Should be _continuously_ called while the map is moving.
  set onMapMoveCallback(VoidCallback? callback);

  bool get isCameraMoving;

  List<Symbol> get symbols;

  void addOnSymbolTapped(OnSymbolTappedCallback onSymbolTapped);

  void removeOnSymbolTapped(OnSymbolTappedCallback onSymbolTapped);

  Future<Iterable<Symbol>> addSymbols(Iterable<Symbol> symbols);

  Future<Symbol> addSymbol(Symbol symbol);

  Future<void> removeSymbols(Iterable<Symbol> symbols);

  Future<void> removeSymbol(Symbol symbol);

  Future<void> clearSymbols();

  Future<Symbol> updateSymbol(Symbol symbol);

  Future<void> setAllowSymbolOverlap(bool allowOverlap);

  Future<CameraPosition> cameraPosition();

  Future<void> animateCamera(CameraPosition position, {bool easeIn = false});

  Future<void> moveCamera(CameraPosition position);

  Future<void> animateToBounds(LatLngBounds? bounds);

  Future<void> setAttributionBottomPadding(double bottom);

  Future<void> setLogoBottomPadding(double bottom);

  Future<bool> isTelemetryEnabled();

  Future<void> setTelemetryEnabled(bool enabled);

  Future<void> setMapType(MapType type);

  /// Redraws/repaints/whatever the map. Used first for ensuring symbol pins
  /// are updated correctly when selecting/deselecting fishing spots.
  Future<void> redraw();

  Iterable<Symbol> get fishingSpotSymbols =>
      symbols.where((e) => e.metadata.hasFishingSpot());
}
