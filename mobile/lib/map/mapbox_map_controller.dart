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
      result._init(),
    ]);

    return result;
  }

  MapboxMapController._(this._map);

  Future<void> _init() async {
    _pointManager = await _map.annotations.createPointAnnotationManager();
    _pointManager.setSymbolZOrder(.SOURCE);

    _map.setOnMapMoveListener(_onMapMove);
  }

  @override
  set onMapMoveCallback(VoidCallback? callback) =>
      _onMapMoveCallback = callback;

  @override
  List<Symbol> get symbols => _annotations.map((a) => a.symbol).toList();

  @override
  bool get isCameraMoving => _isCameraMoving;

  /// Note that [onSymbolTapped] is used as a key in a map so this controller
  /// can manage listeners and cancel them as needed. As such, an instance
  /// or global method reference should be used rather than a closure.
  @override
  void addOnSymbolTapped(OnSymbolTappedCallback onSymbolTapped) {
    _tapEventMap[onSymbolTapped] = _pointManager.tapEvents(
      onTap: (a) => onSymbolTapped(a.symbol),
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
    // TODO: https://github.com/cohenadair/anglers-log/issues/1090
    print(
      "NOT IMPLEMENTED: isTelemetryEnabled (https://github.com/cohenadair/anglers-log/issues/1090)",
    );
    return Future.value(false);
  }

  @override
  Future<void> setTelemetryEnabled(bool enabled) {
    // TODO: https://github.com/cohenadair/anglers-log/issues/1090
    print(
      "NOT IMPLEMENTED: setTelemetryEnabled (https://github.com/cohenadair/anglers-log/issues/1090)",
    );
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
    final annotations = await _pointManager.createMulti(
      symbols.map((s) => s.pointAnnotationOptions).toList(),
    );
    await _syncAnnotations();

    _log.d(
      "Added ${annotations.length} annotations; total: ${_annotations.length}",
    );

    return annotations.where((a) => a != null).map((a) => a!.symbol);
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
  Future<void> clearSymbols() async {
    await _pointManager.deleteAll();
    await _syncAnnotations();
  }

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
      (await _map.getCameraState()).cameraPosition;

  @override
  Future<void> moveCamera(CameraPosition position) =>
      _map.setCamera(position.cameraOptions);

  @override
  Future<void> animateCamera(CameraPosition position, {bool easeIn = false}) {
    return easeIn
        ? _map.easeTo(
            position.cameraOptions,
            MapAnimationOptions(duration: _animCameraEaseInMs),
          )
        : _map.flyTo(position.cameraOptions, null);
  }

  @override
  Future<void> animateToBounds(LatLngBounds? bounds) async {
    if (bounds == null) {
      return;
    }

    final mapBounds = CoordinateBounds(
      southwest: bounds.southwest.point,
      northeast: bounds.northeast.point,
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

  /// Gets the latest version of [symbol] after being synced with Mapbox.
  Symbol _latestVersionOfSymbol(Symbol symbol) =>
      symbols.firstWhere((s) => s.latLng == symbol.latLng);
}

extension MapboxLatLngs on LatLng {
  Point get point => Point(coordinates: Position(lng, lat));
}

extension MapboxSymbols on Symbol {
  static const _pinActive = "active-pin";
  static const _pinInactive = "inactive-pin";
  static const _pinDirectionArrow = "direction-arrow";

  String get iconImage {
    switch (options.pin) {
      case SymbolOptions_PinType.active:
        return _pinActive;
      case SymbolOptions_PinType.direction_arrow:
        return _pinDirectionArrow;
      default:
        return _pinInactive;
    }
  }

  Map<String, Object>? get mapboxCustomData => {
    _PointAnnotations.keyCustomData: jsonEncode(toProto3Json()),
  };

  PointAnnotationOptions get pointAnnotationOptions => PointAnnotationOptions(
    geometry: latLng.point,
    iconImage: iconImage,
    iconSize: options.iconSize,
    iconRotate: options.iconRotate,
    isDraggable: options.isDraggable,
    customData: mapboxCustomData,
  );
}

extension MapboxCamaeraPositions on CameraPosition {
  CameraOptions get cameraOptions => CameraOptions(
    center: latLng.point,
    zoom: zoom,
    padding: MbxEdgeInsets(top: top, left: left, bottom: bottom, right: right),
  );
}

extension _PointAnnotations on PointAnnotation {
  static const keyCustomData = "symbol";

  Symbol get symbol => Symbol()
    ..mergeFromProto3Json(jsonDecode(customData![keyCustomData] as String))
    ..id = id;
}

extension _CameraStates on CameraState {
  CameraPosition get cameraPosition => CameraPosition(
    latLng: LatLng(
      lat: center.coordinates.lat.toDouble(),
      lng: center.coordinates.lng.toDouble(),
    ),
    zoom: zoom,
    left: padding.left,
    right: padding.right,
    top: padding.top,
    bottom: padding.bottom,
  );
}
