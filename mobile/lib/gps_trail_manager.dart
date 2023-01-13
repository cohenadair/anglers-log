import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:provider/provider.dart';
import 'package:protobuf/protobuf.dart';
import 'package:quiver/strings.dart';

import 'body_of_water_manager.dart';
import 'entity_manager.dart';
import 'i18n/strings.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/string_utils.dart';

extension GpsTrailEventType on EntityEventType {
  static const startTracking = EntityEventType("start_tracking");
  static const endTracking = EntityEventType("end_tracking");
}

class GpsTrailManager extends EntityManager<GpsTrail> {
  static GpsTrailManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).gpsTrailManager;

  final _log = const Log("GpsTrailManager");

  GpsTrail? _activeTrail;

  BodyOfWaterManager get _bodyOfWaterManager => appManager.bodyOfWaterManager;

  LocationMonitor get _locationMonitor => appManager.locationMonitor;

  TimeManager get _timeManager => appManager.timeManager;

  TripManager get _tripManager => appManager.tripManager;

  UserPreferenceManager get _userPreferenceManager =>
      appManager.userPreferenceManager;

  GpsTrailManager(AppManager appManager) : super(appManager);

  @override
  Future<void> initialize() async {
    await super.initialize();

    _activeTrail = list().firstWhereOrNull((e) => !e.isFinished);
    _locationMonitor.stream.listen(_onLocationUpdate);
  }

  @override
  String displayName(BuildContext context, GpsTrail entity) =>
      entity.displayTimestamp(context);

  @override
  GpsTrail entityFromBytes(List<int> bytes) => GpsTrail.fromBuffer(bytes);

  @override
  Id id(GpsTrail entity) => entity.id;

  @override
  bool matchesFilter(Id id, String? filter) {
    var trail = entity(id);
    if (trail == null) {
      return false;
    }
    return _bodyOfWaterManager.idsMatchesFilter([trail.bodyOfWaterId], filter);
  }

  @override
  String get tableName => "gps_trail";

  double get _minPointDist => _userPreferenceManager.minGpsTrailDistance
      .convertToSystem(MeasurementSystem.metric, Unit.meters)
      .mainValue
      .value;

  GpsTrail? get activeTrial => _activeTrail?.deepCopy();

  bool get hasActiveTrail => _activeTrail != null;

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

    var finishedTrail = _activeTrail;
    _activeTrail = null;
    await _locationMonitor.disableBackgroundMode();
    _notifyOnStopTracking(finishedTrail!);
  }

  List<GpsTrail> gpsTrails({
    String? filter,
  }) {
    List<GpsTrail> trails;

    if (isEmpty(filter)) {
      trails = entities.values.toList();
    } else {
      trails =
          list().where((trail) => matchesFilter(trail.id, filter)).toList();
    }

    trails.sort((lhs, rhs) => rhs.startTimestamp.compareTo(lhs.startTimestamp));
    return trails;
  }

  int numberOfTrips(Id? trailId) => numberOf<Trip>(trailId, _tripManager.list(),
      (trip) => trip.gpsTrailIds.contains(trailId));

  String deleteMessage(BuildContext context, GpsTrail trail) {
    var numOfTrips = numberOfTrips(trail.id);
    var string = numOfTrips == 1
        ? Strings.of(context).gpsTrailListPageDeleteMessageSingular
        : Strings.of(context).gpsTrailListPageDeleteMessage;
    return format(string, [numOfTrips]);
  }

  void _onLocationUpdate(LatLng latLng) {
    if (!hasActiveTrail ||
        distanceBetween(latLng, _activeTrail!.points.last.latLng) <
            _minPointDist) {
      return;
    }

    _activeTrail!.points.add(GpsTrailPoint(
      timestamp: Int64(_timeManager.currentTimestamp),
      lat: latLng.latitude,
      lng: latLng.longitude,
    ));
    addOrUpdate(_activeTrail!);

    _log.d("Added to GPS trail: ${latLng.latitude}, ${latLng.longitude}");
  }

  void _notifyOnStartTracking() {
    controller
        .add(EntityEvent<GpsTrail>(GpsTrailEventType.startTracking, null));
  }

  void _notifyOnStopTracking(GpsTrail trail) {
    controller.add(EntityEvent<GpsTrail>(GpsTrailEventType.endTracking, trail));
  }
}
