import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:provider/provider.dart';
import 'package:protobuf/protobuf.dart';

import 'entity_manager.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';

extension GpsTrailEventType on EntityEventType {
  static const startTracking = EntityEventType("start_tracking");
  static const endTracking = EntityEventType("end_tracking");
}

class GpsTrailManager extends EntityManager<GpsTrail> {
  static GpsTrailManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).gpsTrailManager;

  final _log = const Log("GpsTrailManager");

  GpsTrail? _activeTrail;

  LocationMonitor get _locationMonitor => appManager.locationMonitor;

  TimeManager get _timeManager => appManager.timeManager;

  GpsTrailManager(AppManager appManager) : super(appManager);

  @override
  Future<void> initialize() async {
    await super.initialize();

    _activeTrail = list().firstWhereOrNull((e) => !e.isFinished);
    _locationMonitor.stream.listen(_onLocationUpdate);
  }

  @override
  String displayName(BuildContext context, GpsTrail entity) {
    throw UnimplementedError();
  }

  @override
  GpsTrail entityFromBytes(List<int> bytes) => GpsTrail.fromBuffer(bytes);

  @override
  Id id(GpsTrail entity) => entity.id;

  @override
  bool matchesFilter(Id id, String? filter) {
    throw UnimplementedError();
  }

  @override
  String get tableName => "gps_trail";

  GpsTrail? get activeTrial => _activeTrail?.deepCopy();

  bool get hasActiveTrail => _activeTrail != null;

  List<GpsTrail> sortedTrails() {
    return list()
      ..sort((lhs, rhs) => rhs.startTimestamp.compareTo(lhs.endTimestamp));
  }

  Future<void> startTracking(BuildContext context) async {
    if (hasActiveTrail) {
      _log.w("Already tracking a gps trail");
      return;
    }

    var currentTimestamp = Int64(_timeManager.currentTimestamp);

    _activeTrail = GpsTrail(
      id: randomId(),
      startTimestamp: currentTimestamp,
      timeZone: _timeManager.currentTimeZone,
    );

    var currentLatLng = _locationMonitor.currentLocation;
    if (currentLatLng != null) {
      _activeTrail!.points.add(GpsTrailPoint(
        timestamp: currentTimestamp,
        lat: currentLatLng.latitude,
        lng: currentLatLng.longitude,
      ));
    }

    await addOrUpdate(_activeTrail!);
    await _locationMonitor.enableBackgroundMode(context);
    _notifyOnStartTracking();
  }

  Future<void> stopTracking() async {
    if (!hasActiveTrail) {
      _log.w("Not tracking a gps trail");
      return;
    }

    _activeTrail!.endTimestamp = Int64(_timeManager.currentTimestamp);
    await addOrUpdate(_activeTrail!);

    _activeTrail = null;
    await _locationMonitor.disableBackgroundMode();
    _notifyOnStopTracking();
  }

  void _onLocationUpdate(LatLng? latLng) {
    if (latLng == null || !hasActiveTrail) {
      return;
    }

    _activeTrail!.points.add(GpsTrailPoint(
      timestamp: Int64(_timeManager.currentTimestamp),
      lat: latLng.latitude,
      lng: latLng.longitude,
    ));
    addOrUpdate(_activeTrail!);

    _log.d("Added to GPS trail: ${latLng.latitude}, ${latLng.latitude}");
  }

  void _notifyOnStartTracking() {
    controller
        .add(EntityEvent<GpsTrail>(GpsTrailEventType.startTracking, null));
  }

  void _notifyOnStopTracking() {
    controller.add(EntityEvent<GpsTrail>(GpsTrailEventType.endTracking, null));
  }
}
