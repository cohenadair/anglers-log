import 'dart:async';

import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:quiver/strings.dart';

import 'body_of_water_manager.dart';
import 'entity_manager.dart';
import 'model/gen/anglers_log.pb.dart';
import 'utils/string_utils.dart';

extension GpsTrailEventType on EntityEventType {
  static const startTracking = EntityEventType("start_tracking");
  static const endTracking = EntityEventType("end_tracking");
}

class GpsTrailManager extends EntityManager<GpsTrail> {
  static GpsTrailManager of(BuildContext context) =>
      AppManager.get.gpsTrailManager;

  final _log = const Log("GpsTrailManager");

  GpsTrail? _activeTrail;

  BodyOfWaterManager get _bodyOfWaterManager => appManager.bodyOfWaterManager;

  LocationMonitor get _locationMonitor => appManager.locationMonitor;

  TripManager get _tripManager => appManager.tripManager;

  GpsTrailManager(super.app);

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
  bool matchesFilter(Id id, BuildContext context, String? filter) {
    var trail = entity(id);
    if (trail == null) {
      return false;
    }
    return _bodyOfWaterManager.idsMatchFilter(
      [trail.bodyOfWaterId],
      context,
      filter,
    );
  }

  @override
  String get tableName => "gps_trail";

  double get _minPointDist => UserPreferenceManager.get.minGpsTrailDistance
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

    var currentTimestamp = TimeManager.get.currentTimestamp;
    var notificationDescription = Strings.of(
      context,
    ).permissionLocationNotificationDescription;

    _activeTrail = GpsTrail(
      id: randomId(),
      startTimestamp: Int64(currentTimestamp),
      timeZone: TimeManager.get.currentTimeZone,
    );

    var currentLoc = _locationMonitor.currentLocation;
    if (currentLoc != null) {
      _activeTrail!.points.add(currentLoc.toGpsTrailPoint(currentTimestamp));
    }

    await addOrUpdate(_activeTrail!);
    await _locationMonitor.enableBackgroundMode(notificationDescription);
    _notifyOnStartTracking();
  }

  Future<void> stopTracking() async {
    if (!hasActiveTrail) {
      _log.w("Not tracking a gps trail");
      return;
    }

    _activeTrail!.endTimestamp = Int64(TimeManager.get.currentTimestamp);
    await addOrUpdate(_activeTrail!);

    var finishedTrail = _activeTrail;
    _activeTrail = null;
    _locationMonitor.disableBackgroundMode();
    _notifyOnStopTracking(finishedTrail!);
  }

  List<GpsTrail> gpsTrails(BuildContext context, {String? filter}) {
    List<GpsTrail> trails;

    if (isEmpty(filter)) {
      trails = entities.values.toList();
    } else {
      trails = list()
          .where((trail) => matchesFilter(trail.id, context, filter))
          .toList();
    }

    trails.sort((lhs, rhs) => rhs.startTimestamp.compareTo(lhs.startTimestamp));
    return trails;
  }

  int numberOfTrips(Id? trailId) => numberOf<Trip>(
    trailId,
    _tripManager.list(),
    (trip) => trip.gpsTrailIds.contains(trailId),
  );

  String deleteMessage(BuildContext context, GpsTrail trail) {
    var numOfTrips = numberOfTrips(trail.id);
    return numOfTrips == 1
        ? Strings.of(context).gpsTrailListPageDeleteMessageSingular
        : Strings.of(context).gpsTrailListPageDeleteMessage(numOfTrips);
  }

  void _onLocationUpdate(LocationPoint loc) {
    if (!hasActiveTrail ||
        distanceBetween(loc.latLng, _activeTrail!.points.last.latLng) <
            _minPointDist) {
      return;
    }

    _activeTrail!.points.add(
      loc.toGpsTrailPoint(TimeManager.get.currentTimestamp),
    );
    addOrUpdate(_activeTrail!);

    _log.d("Added to GPS trail: $loc");
  }

  void _notifyOnStartTracking() {
    controller.add(
      EntityEvent<GpsTrail>(GpsTrailEventType.startTracking, null),
    );
  }

  void _notifyOnStopTracking(GpsTrail trail) {
    controller.add(EntityEvent<GpsTrail>(GpsTrailEventType.endTracking, trail));
  }
}
