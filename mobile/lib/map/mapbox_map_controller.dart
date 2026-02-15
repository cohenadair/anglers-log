import 'dart:convert';
import 'dart:ui';

import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/map/map_controller.dart';
import 'package:mobile/utils/protobuf_utils.dart';

import '../model/gen/anglers_log.pb.dart';
import '../utils/map_utils.dart';

class MapboxMapController extends MapController {
  static const _animCameraEaseInMs = 1000;
  static const _pinActive = "active-pin";
  static const _pinInactive = "inactive-pin";
  static const _pinDirectionArrow = "direction-arrow";
  static const _keyCustomData = "symbol";

  static Point latLngToPoint(LatLng latLng) =>
      Point(coordinates: Position(latLng.lng, latLng.lat));

  final MapboxMap _map;
  final _annotations = <PointAnnotation>[];
  final _tapEventMap = <OnSymbolTappedCallback, Cancelable>{};
  final _log = const Log("MapboxMapController");

  late final PointAnnotationManager _pointManager;

  VoidCallback? _onMapMoveCallback;
  var _isCameraMoving = false;

  static Future<MapboxMapController> create(
    MapboxMap map, {
    bool myLocationEnabled = true,
  }) async {
    final result = MapboxMapController._(map);

    await Future.wait([
      map.setDebugOptions([]),
      map.attribution.updateSettings(AttributionSettings(enabled: false)),
      map.logo.updateSettings(LogoSettings(enabled: false)),
      map.compass.updateSettings(CompassSettings(enabled: false)),
      map.scaleBar.updateSettings(ScaleBarSettings(enabled: false)),
      map.location.updateSettings(
        LocationComponentSettings(enabled: myLocationEnabled),
      ),
      result.init(),
    ]);

    return result;
  }

  MapboxMapController._(this._map);

  Future<void> init() async {
    _pointManager = await _map.annotations.createPointAnnotationManager();
    _pointManager.setSymbolZOrder(.SOURCE);

    _map.setOnMapMoveListener(_onMapMove);
  }

  @override
  set onMapMoveCallback(VoidCallback? callback) =>
      _onMapMoveCallback = callback;

  @override
  List<Symbol> get symbols =>
      _annotations.map((a) => _pointAnnotationToSymbol(a)).toList();

  @override
  bool get isCameraMoving => _isCameraMoving;

  /// Note that [onSymbolTapped] is used as a key in a map so this controller
  /// can manage listeners and cancel them as needed. As such, an instance
  /// or global method reference should be used rather than a closure.
  @override
  void addOnSymbolTapped(OnSymbolTappedCallback onSymbolTapped) {
    _tapEventMap[onSymbolTapped] = _pointManager.tapEvents(
      onTap: (a) => onSymbolTapped(_pointAnnotationToSymbol(a)),
    );
  }

  @override
  void removeOnSymbolTapped(OnSymbolTappedCallback onSymbolTapped) {
    final tapEvent = _tapEventMap[onSymbolTapped];
    if (tapEvent == null) {
      _log.w("Calling removeOnSymbolTapped for a callback that doesn't exist");
      return;
    }
    tapEvent.cancel();
    _tapEventMap.remove(onSymbolTapped);
  }

  @override
  Future<bool> isTelemetryEnabled() {
    // TODO: https://github.com/mapbox/mapbox-maps-flutter/issues/63
    print("NOT IMPLEMENTED: isTelemetryEnabled");
    return Future.value(false);
  }

  @override
  Future<void> setTelemetryEnabled(bool enabled) {
    // TODO: https://github.com/mapbox/mapbox-maps-flutter/issues/63
    print("NOT IMPLEMENTED: updateTelemetryEnabled");
    return Future.value();
  }

  @override
  Future<void> setMapType(MapType type) => _map.loadStyleURI(type.url);

  @override
  Future<Symbol> addSymbol(Symbol symbol) async {
    await addSymbols([symbol]);
    return _latestVersionOfSymbol(symbol);
  }

  @override
  Future<Iterable<Symbol>> addSymbols(Iterable<Symbol> symbols) async {
    final addedAnnotations = await _pointManager.createMulti(
      symbols.map((s) => _symbolToPointAnnotationOptions(s)).toList(),
    );
    await _syncAnnotations();

    _log.d(
      "Added ${addedAnnotations.length} annotations; total: ${_annotations.length}",
    );

    return addedAnnotations
        .where((a) => a != null)
        .map((a) => _pointAnnotationToSymbol(a!));
  }

  @override
  Future<void> removeSymbol(Symbol symbol) async => removeSymbols([symbol]);

  @override
  Future<void> removeSymbols(Iterable<Symbol> symbols) async {
    final ids = symbols.map((s) => s.id);
    await _pointManager.deleteMulti(
      _annotations.where((a) => ids.contains(a.id)).toList(),
    );
    await _syncAnnotations();
    _log.d(
      "Deleted ${symbols.length} annotations; total: ${_annotations.length}",
    );
  }

  @override
  Future<void> clearSymbols() => _pointManager.deleteAll();

  @override
  Future<Symbol> updateSymbol(Symbol symbol) async {
    // Mapbox annotation zIndex isn't controllable explicitly, so we remove and
    // re-add the annotation to render on top of all other symbols, rather than
    // using the MapboxMap.update(PointAnnotation) method.
    _log.d("Updating symbol by removing and re-adding");
    await removeSymbol(symbol);
    return await addSymbol(symbol);
  }

  @override
  Future<CameraPosition> cameraPosition() async =>
      _cameraStateToPosition(await _map.getCameraState());

  @override
  Future<void> moveCamera(CameraPosition position) =>
      _map.setCamera(_positionToCameraOptions(position));

  @override
  Future<void> animateCamera(CameraPosition position, {bool easeIn = false}) {
    return easeIn
        ? _map.easeTo(
            _positionToCameraOptions(position),
            MapAnimationOptions(duration: _animCameraEaseInMs),
          )
        : _map.flyTo(_positionToCameraOptions(position), null);
  }

  @override
  Future<void> animateToBounds(LatLngBounds? bounds) async {
    if (bounds == null) {
      return;
    }

    final mapBounds = CoordinateBounds(
      southwest: latLngToPoint(bounds.southwest),
      northeast: latLngToPoint(bounds.northeast),
      infiniteBounds: true,
    );

    final camera = await _map.cameraForCoordinateBounds(
      mapBounds,
      MbxEdgeInsets(
        top: paddingXL,
        left: paddingXL,
        bottom: paddingXL,
        right: paddingXL,
      ),
      null,
      null,
      null,
      null,
    );

    return _map.flyTo(camera, MapAnimationOptions());
  }

  @override
  Future<void> setAllowSymbolOverlap(bool allowOverlap) =>
      _pointManager.setIconAllowOverlap(allowOverlap);

  @override
  Future<void> setAttributionBottomPadding(double bottom) => _map.attribution
      .updateSettings(AttributionSettings(marginBottom: bottom));

  @override
  Future<void> setLogoBottomPadding(double bottom) =>
      _map.logo.updateSettings(LogoSettings(marginBottom: bottom));

  @override
  Future<void> redraw() =>
      // Note that triggerRepaint() doesn't seem to work in this case.
      _map.moveBy(ScreenCoordinate(x: 0, y: 0), MapAnimationOptions());

  void _onMapMove(MapContentGestureContext context) {
    if (context.gestureState == .started) {
      _isCameraMoving = true;
      _log.d("Camera is moving");
    } else if (context.gestureState == .ended) {
      _isCameraMoving = false;
      _log.d("Camera is not moving");
    }
    _onMapMoveCallback?.call();
  }

  Future<void> _syncAnnotations() async {
    _annotations.clear();
    _annotations.addAll(await _pointManager.getAnnotations());
  }

  Point _point(Symbol symbol) => latLngToPoint(symbol.latLng);

  String _iconImage(Symbol symbol) {
    switch (symbol.options.pin) {
      case SymbolOptions_PinType.active:
        return _pinActive;
      case SymbolOptions_PinType.direction_arrow:
        return _pinDirectionArrow;
      default:
        return _pinInactive;
    }
  }

  Map<String, Object>? _customData(Symbol symbol) => {
    _keyCustomData: jsonEncode(symbol.toProto3Json()),
  };

  PointAnnotationOptions _symbolToPointAnnotationOptions(Symbol symbol) {
    return PointAnnotationOptions(
      geometry: _point(symbol),
      iconImage: _iconImage(symbol),
      iconSize: symbol.options.iconSize,
      iconRotate: symbol.options.iconRotate,
      isDraggable: symbol.options.isDraggable,
      customData: _customData(symbol),
    );
  }

  Symbol _pointAnnotationToSymbol(PointAnnotation annotation) {
    return Symbol()
      ..mergeFromProto3Json(
        jsonDecode(annotation.customData![_keyCustomData] as String),
      )
      ..id = annotation.id;
  }

  /// Gets the latest version of [symbol] after being synced with Mapbox.
  /// [Symbol.options] is used here as the equals qualifier because the lat/lng
  /// combination is unique for each symbol.
  Symbol _latestVersionOfSymbol(Symbol symbol) =>
      symbols.firstWhere((s) => s.latLng == symbol.latLng);

  CameraPosition _cameraStateToPosition(CameraState state) {
    return CameraPosition(
      latLng: LatLng(
        lat: state.center.coordinates.lat.toDouble(),
        lng: state.center.coordinates.lng.toDouble(),
      ),
      zoom: state.zoom,
      left: state.padding.left,
      right: state.padding.right,
      top: state.padding.top,
      bottom: state.padding.bottom,
    );
  }

  CameraOptions _positionToCameraOptions(CameraPosition position) {
    return CameraOptions(
      center: latLngToPoint(position.latLng),
      zoom: position.zoom,
      padding: MbxEdgeInsets(
        top: position.top,
        left: position.left,
        bottom: position.bottom,
        right: position.right,
      ),
    );
  }
}
