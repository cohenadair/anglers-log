import 'dart:ui';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/map/camera_position.dart';
import 'package:mobile/map/map_controller.dart';
import 'package:mobile/map/symbol.dart';
import 'package:mobile/map/symbol_options.dart';

class MapboxMapController extends MapController {
  final MapboxMap map;

  @override
  List<void Function(Symbol)> get onSymbolTapped {
    // TODO: implement onSymbolTapped
    print("NOT IMPLEMENTED: onSymbolTapped");
    return [];
  }

  @override
  List<Symbol> get symbols {
    // TODO: implement symbols
    print("NOT IMPLEMENTED: symbols");
    return [];
  }

  MapboxMapController(this.map);

  @override
  Future<void> startTracking() async {
    // TODO: implement startTracking
    print("NOT IMPLEMENTED: startTracking");
  }

  @override
  Future<void> stopTracking() async {
    // TODO: implement stopTracking
    print("NOT IMPLEMENTED: stopTracking");
  }

  @override
  void addListener(VoidCallback listener) {
    // TODO: implement addListener
    print("NOT IMPLEMENTED: addListener");
  }

  @override
  Future<Symbol> addSymbol(SymbolOptions options, Map<String, dynamic>? data) {
    // TODO: implement addSymbol
    print("NOT IMPLEMENTED: addSymbol");
    throw UnimplementedError();
  }

  @override
  Future<Iterable<Symbol>> addSymbols(
    Iterable<SymbolOptions> symbols,
    Iterable<Map<String, dynamic>> data,
  ) {
    // TODO: implement addSymbols
    print("NOT IMPLEMENTED: addSymbols");
    return Future.value([]);
  }

  @override
  Future<bool?> animateCamera(CameraPosition position) {
    // TODO: implement animateCamera
    print("NOT IMPLEMENTED: animateCamera");
    return Future.value(false);
  }

  @override
  // TODO: implement cameraPosition
  CameraPosition? get cameraPosition {
    print("NOT IMPLEMENTED: cameraPosition");
    return null;
  }

  @override
  Future<void> clearSymbols() {
    // TODO: implement clearSymbols
    print("NOT IMPLEMENTED: clearSymbols");
    return Future.value();
  }

  @override
  // TODO: implement fishingSpotSymbols
  Iterable<Symbol> get fishingSpotSymbols{
    print("NOT IMPLEMENTED: fishingSpotSymbols");
    return [];
  }

  @override
  Future<bool> getTelemetryEnabled() {
    // TODO: implement getTelemetryEnabled
    print("NOT IMPLEMENTED: getTelemetryEnabled");
    return Future.value(false);
  }

  @override
  // TODO: implement isCameraMoving
  bool get isCameraMoving {
    print("NOT IMPLEMENTED: isCameraMoving");
    return false;
  }

  @override
  Future<void> moveCamera(CameraPosition position) {
    // TODO: implement moveCamera
    print("NOT IMPLEMENTED: moveCamera");
    return Future.value();
  }

  @override
  void removeListener(VoidCallback listener) {
    print("NOT IMPLEMENTED: removeListener");
  }

  @override
  Future<void> removeSymbol(Symbol symbol) {
    // TODO: implement removeSymbol
    print("NOT IMPLEMENTED: removeSymbol");
    return Future.value();
  }

  @override
  Future<void> removeSymbols(Iterable<Symbol> symbols) {
    // TODO: implement removeSymbols
    print("NOT IMPLEMENTED: removeSymbols");
    return Future.value();
  }

  @override
  void setSymbolIconAllowOverlap(bool allowOverlap) {
    // TODO: implement setSymbolIconAllowOverlap
    print("NOT IMPLEMENTED: setSymbolIconAllowOverlap");
  }

  @override
  Future<void> setTelemetryEnabled(bool enabled) {
    // TODO: implement setTelemetryEnabled
    print("NOT IMPLEMENTED: setTelemetryEnabled");
    return Future.value();
  }

  @override
  Future<void> updateSymbol(Symbol symbol, SymbolOptions options) {
    // TODO: implement updateSymbol
    print("NOT IMPLEMENTED: updateSymbol");
    return Future.value();
  }
}
