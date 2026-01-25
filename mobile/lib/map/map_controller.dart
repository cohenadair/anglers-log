import 'dart:ui';

import 'package:mobile/map/camera_position.dart';

import 'lat_lng_bounds.dart';
import 'symbol.dart';
import 'symbol_options.dart';

abstract class MapController {
  // Legacy mapbox_gl methods.

  CameraPosition? get cameraPosition;

  bool get isCameraMoving;

  List<Symbol> get symbols;

  List<void Function(Symbol)> get onSymbolTapped;

  Future<Iterable<Symbol>> addSymbols(
    Iterable<SymbolOptions> symbols,
    Iterable<Map<String, dynamic>> data,
  );

  Future<Symbol> addSymbol(SymbolOptions options, Map<String, dynamic>? data);

  Future<void> removeSymbols(Iterable<Symbol> symbols);

  Future<void> removeSymbol(Symbol symbol);

  Future<void> clearSymbols();

  /// Must retain existing fields (not set in [options]).
  Future<void> updateSymbol(Symbol symbol, SymbolOptions options);

  void addListener(VoidCallback listener);

  void removeListener(VoidCallback listener);

  Future<void> setTelemetryEnabled(bool enabled);

  Future<bool> getTelemetryEnabled();

  void setSymbolIconAllowOverlap(bool allowOverlap);

  Future<bool?> animateCamera(CameraPosition position);

  Future<void> moveCamera(CameraPosition position);

  // Legacy Anglers' Log extension methods.

  Future<void> startTracking();

  Future<void> stopTracking();

  Iterable<Symbol> get fishingSpotSymbols =>
      symbols.where((e) => e.hasFishingSpot);

  Future<bool?> animateToBounds(LatLngBounds? bounds, double screenHeight) {
    if (bounds == null) {
      return Future.value(false);
    }

    // These are completely arbitrary values that will give enough padding to
    // account for floating map widgets in most cases. It also looks nicer on
    // the screen.
    var verticalPadding = screenHeight / 4;
    var horizontalPadding = screenHeight / 6;

    return animateCamera(
      CameraPosition(
        target: bounds.center,
        left: horizontalPadding,
        right: horizontalPadding,
        top: verticalPadding,
        bottom: verticalPadding,
      ),
    );
  }

  // New methods.
}
