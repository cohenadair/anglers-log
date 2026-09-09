import 'dart:math';

import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/map/map_controller.dart';
import 'package:mobile/utils/protobuf_utils.dart';

import '../model/gen/anglers_log.pb.dart';
import '../utils/map_utils.dart';

/// True if [error] indicates the native Mapbox platform view (and its
/// pigeon channels) has already been torn down - for example, when the user
/// navigates away from a map before it finishes loading. These are expected
/// whenever a Mapbox call races the map's disposal, and are safe to ignore.
bool isMapDisposalError(Object error) =>
    error is MissingPluginException ||
    (error is PlatformException && error.code == "channel-error");

class MapboxMapController extends MapController {
  static const _animCameraEaseInMs = 1000;

  final MapboxMap _map;

  // Manually track (instead of using PointAnnotation's customData field)
  // annotation-to-symbol pairs for more control.
  final _annotationSymbolMap = <PointAnnotation, Symbol>{};

  final _tapEventMap = <OnSymbolTappedCallback, Cancelable>{};
  final _log = const Log("MapboxMapController");

  late final PointAnnotationManager _pointManager;

  VoidCallback? _onMapMoveCallback;
  var _isCameraMoving = false;

  /// Returns null if the map was disposed (see [isMapDisposalError]) before
  /// initialization finished.
  static Future<MapboxMapController?> create(
    MapboxMap map, {
    bool myLocationEnabled = true,
  }) async {
    final result = MapboxMapController._(map);

    await Future.wait([
      result._guard(() => map.setDebugOptions([])),
      result._guard(
        () => map.compass.updateSettings(CompassSettings(enabled: false)),
      ),
      result._guard(
        () => map.scaleBar.updateSettings(ScaleBarSettings(enabled: false)),
      ),
      result._guard(
        () => map.location.updateSettings(
          LocationComponentSettings(enabled: myLocationEnabled),
        ),
      ),
    ]);

    if (!await result._init()) {
      return null;
    }

    await result.updateLogoAndAttributionMarginBottom(0);

    return result;
  }

  MapboxMapController._(this._map);

  /// Returns false if the map was disposed (see [isMapDisposalError]) while
  /// initializing, leaving [_pointManager] unset.
  Future<bool> _init() async {
    final pointManager = await _guard(
      () => _map.annotations.createPointAnnotationManager(),
    );
    if (pointManager == null) {
      return false;
    }
    _pointManager = pointManager;

    await _guard(() => _pointManager.setSymbolZOrder(.SOURCE));
    _map.setOnMapMoveListener(_onMapMove);

    return true;
  }

  /// Runs [call], returning null if it fails because the map was disposed
  /// while [call] was in flight (see [isMapDisposalError]). Any other error
  /// is rethrown as usual.
  Future<T?> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (e) {
      if (isMapDisposalError(e)) {
        _log.d("Ignoring Mapbox call after map was disposed");
        return null;
      }
      rethrow;
    }
  }

  @override
  set onMapMoveCallback(VoidCallback? callback) =>
      _onMapMoveCallback = callback;

  @override
  List<Symbol> get symbols => _annotationSymbolMap.values.toList();

  @override
  List<OnSymbolTappedCallback> get onSymbolTappedCallbacks =>
      _tapEventMap.keys.toList();

  @override
  bool get isCameraMoving => _isCameraMoving;

  /// Note that [onSymbolTapped] is used as a key in a map so this controller
  /// can manage listeners and cancel them as needed. As such, an instance
  /// or global method reference should be used rather than a closure.
  @override
  void addOnSymbolTapped(OnSymbolTappedCallback onSymbolTapped) {
    _tapEventMap[onSymbolTapped] = _pointManager.tapEvents(
      onTap: (a) {
        final tappedId = a.id;
        final annotation = _annotationSymbolMap.keys.firstWhereOrNull(
          (a) => a.id == tappedId,
        );
        if (annotation == null) {
          _log.w("Tapped annotation with no associated symbol");
        } else {
          onSymbolTapped(_annotationSymbolMap[annotation]!);
        }
      },
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
    // TODO: https://github.com/cohenadair/anglers-log/issues/1101
    print(
      "NOT IMPLEMENTED: isTelemetryEnabled (https://github.com/cohenadair/anglers-log/issues/1101)",
    );
    return Future.value(false);
  }

  @override
  Future<void> setTelemetryEnabled(bool enabled) {
    // TODO: https://github.com/cohenadair/anglers-log/issues/1101
    print(
      "NOT IMPLEMENTED: setTelemetryEnabled (https://github.com/cohenadair/anglers-log/issues/1101)",
    );
    return Future.value();
  }

  @override
  Future<void> updateLogoAndAttributionMarginBottom(double marginBottom) async {
    await Future.wait([
      _guard(
        () => _map.attribution.updateSettings(
          AttributionSettings(
            position: OrnamentPosition.BOTTOM_RIGHT,
            marginRight: IoWrapper.get.isAndroid
                ? paddingDefault
                : paddingSmall,
            marginBottom: max(marginBottom, paddingDefault),
          ),
        ),
      ),
      _guard(
        () => _map.logo.updateSettings(
          LogoSettings(
            marginLeft: paddingDefault,
            marginBottom: max(marginBottom, paddingDefault),
          ),
        ),
      ),
    ]);
  }

  @override
  Future<void> setMapType(MapType type) async {
    await _guard(() => _map.loadStyleURI(type.url));
  }

  @override
  Future<void> addSymbol(Symbol symbol) => addSymbols([symbol]);

  @override
  Future<void> addSymbols(Iterable<Symbol> symbols) async {
    if (symbols.isEmpty) {
      return;
    }

    final createdAnnotations = await _guard(
      () => _pointManager.createMulti(
        symbols.map((s) => s.pointAnnotationOptions).toList(),
      ),
    );
    if (createdAnnotations == null) {
      return;
    }

    final annotations = List.of(createdAnnotations);
    annotations.removeWhere((a) => a == null);
    assert(annotations.length == symbols.length);

    for (var i = 0; i < annotations.length; i++) {
      final annotation = annotations[i]!;
      final symbol = symbols.elementAt(i);

      // Can't guarantee the order of annotations returned by Mapbox, so let's
      // check here.
      assert(annotation.geometry.coordinates.lat == symbol.latLng.lat);
      assert(annotation.geometry.coordinates.lng == symbol.latLng.lng);

      _annotationSymbolMap[annotation] = symbol..id = annotation.id;
    }

    _log.d(
      "Added ${annotations.length} annotations; total: ${_annotationSymbolMap.length}",
    );
  }

  @override
  Future<void> removeSymbol(Symbol symbol) async => removeSymbols([symbol]);

  @override
  Future<void> removeSymbols(Iterable<Symbol> symbols) async {
    if (symbols.isEmpty) {
      return;
    }

    final ids = symbols.map((s) => s.id);
    final annotations = _annotationSymbolMap.keys
        .where((a) => ids.contains(a.id))
        .toList();
    final didDelete = await _guard(() async {
      await _pointManager.deleteMulti(annotations);
      return true;
    });
    if (didDelete == null) {
      return;
    }

    for (var annotation in annotations) {
      _annotationSymbolMap.remove(annotation);
    }

    _log.d(
      "Deleted ${symbols.length} annotations; total: ${_annotationSymbolMap.length}",
    );
  }

  @override
  Future<void> clearSymbols() async {
    final didDelete = await _guard(() async {
      await _pointManager.deleteAll();
      return true;
    });
    if (didDelete == null) {
      return;
    }
    _annotationSymbolMap.clear();
  }

  @override
  Future<void> updateSymbol(Symbol symbol) async {
    final didUpdate = await _guard(() async {
      await _pointManager.update(symbol.pointAnnotation);
      return true;
    });
    if (didUpdate == null) {
      return;
    }
    final annotation = _annotationSymbolMap.keys.firstWhere(
      (a) => a.id == symbol.id,
    );
    _annotationSymbolMap[annotation] = symbol;
  }

  @override
  Future<CameraPosition?> cameraPosition() async =>
      (await _guard(() => _map.getCameraState()))?.cameraPosition;

  @override
  Future<void> moveCamera(CameraPosition position) async {
    await _guard(() => _map.setCamera(position.cameraOptions));
  }

  @override
  Future<void> animateCamera(
    CameraPosition position, {
    bool easeIn = false,
  }) async {
    await _guard(
      () => easeIn
          ? _map.easeTo(
              position.cameraOptions,
              MapAnimationOptions(duration: _animCameraEaseInMs),
            )
          : _map.flyTo(position.cameraOptions, null),
    );
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

    final camera = await _guard(
      () => _map.cameraForCoordinateBounds(
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
      ),
    );
    if (camera == null) {
      return;
    }

    await _guard(() => _map.flyTo(camera, MapAnimationOptions()));
  }

  @override
  Future<void> setAllowSymbolOverlap(bool allowOverlap) async {
    await _guard(() => _pointManager.setIconAllowOverlap(allowOverlap));
  }

  @override
  Future<void> redraw() async {
    // Note that triggerRepaint() doesn't seem to work in this case.
    await _guard(
      () => _map.moveBy(ScreenCoordinate(x: 0, y: 0), MapAnimationOptions()),
    );
  }

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

  PointAnnotationOptions get pointAnnotationOptions => PointAnnotationOptions(
    geometry: latLng.point,
    iconImage: iconImage,
    iconSize: options.iconSize,
    iconRotate: options.iconRotate,
    isDraggable: options.isDraggable,
  );

  PointAnnotation get pointAnnotation => PointAnnotation(
    id: id,
    geometry: latLng.point,
    iconImage: iconImage,
    iconSize: options.iconSize,
    iconRotate: options.iconRotate,
    isDraggable: options.isDraggable,
  );
}

extension MapboxCamaeraPositions on CameraPosition {
  CameraOptions get cameraOptions => CameraOptions(
    center: latLng.point,
    zoom: zoom,
    padding: MbxEdgeInsets(top: top, left: left, bottom: bottom, right: right),
  );
}

extension CameraStates on CameraState {
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
