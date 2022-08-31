import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'custom_entity_manager.dart';
import 'fishing_spot_manager.dart';
import 'i18n/strings.dart';
import 'image_manager.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';
import 'species_manager.dart';
import 'time_manager.dart';
import 'utils/catch_utils.dart';
import 'utils/protobuf_utils.dart';
import 'utils/string_utils.dart';

class TripManager extends NamedEntityManager<Trip> {
  static TripManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).tripManager;

  final _log = const Log("TripManager");

  TripManager(AppManager app) : super(app);

  AnglerManager get _anglerManager => appManager.anglerManager;

  BaitManager get _baitManager => appManager.baitManager;

  CatchManager get _catchManager => appManager.catchManager;

  CustomEntityManager get _customEntityManager =>
      appManager.customEntityManager;

  FishingSpotManager get _fishingSpotManager => appManager.fishingSpotManager;

  ImageManager get _imageManager => appManager.imageManager;

  SpeciesManager get _speciesManager => appManager.speciesManager;

  TimeManager get _timeManager => appManager.timeManager;

  UserPreferenceManager get _userPreferenceManager =>
      appManager.userPreferenceManager;

  @override
  Future<void> initialize() async {
    await super.initialize();

    // TODO: Remove (#683)
    var numberOfChanges = await updateAll(
      where: (trip) => !trip.hasTimeZone(),
      apply: (trip) => addOrUpdate(
        trip..timeZone = _timeManager.currentTimeZone,
        setImages: false,
        notify: false,
      ),
    );
    _log.d("Added time zones to $numberOfChanges trips");

    // TODO: Remove (#696)
    numberOfChanges = await updateAll(
      where: (trip) =>
          trip.hasAtmosphere() && trip.atmosphere.hasDeprecations(),
      apply: (trip) async => await addOrUpdate(
        trip..atmosphere.clearDeprecations(_userPreferenceManager),
        setImages: false,
        notify: false,
      ),
    );
    _log.d("Updated $numberOfChanges deprecated atmosphere objects");
  }

  @override
  Trip entityFromBytes(List<int> bytes) => Trip.fromBuffer(bytes);

  @override
  Id id(Trip entity) => entity.id;

  @override
  String name(Trip entity) => entity.name;

  @override
  String displayName(BuildContext context, Trip entity) {
    if (isNotEmpty(name(entity))) {
      return name(entity);
    }
    return entity.elapsedDisplayValue(context);
  }

  @override
  String get tableName => "trip";

  List<Trip> trips({
    BuildContext? context,
    String? filter,
    DateRange? dateRange,
    Iterable<Id> tripIds = const {},
  }) {
    List<Trip> trips;
    if (isEmpty(filter) && dateRange == null && tripIds.isEmpty) {
      trips = entities.values.toList();
    } else {
      if (dateRange != null && !dateRange.hasTimeZone()) {
        dateRange.timeZone = _timeManager.currentTimeZone;
      }

      trips = list(tripIds).where((trip) {
        if (dateRange != null &&
            context != null &&
            !dateRange.contains(trip.startTimestamp.toInt(),
                TimeManager.of(context).now(trip.timeZone))) {
          return false;
        }

        var matches = matchesFilter(trip.id, filter, context);
        return matches;
      }).toList();
    }

    trips.sort((lhs, rhs) => rhs.startTimestamp.compareTo(lhs.startTimestamp));
    return trips;
  }

  @override
  Future<bool> addOrUpdate(
    Trip entity, {
    List<File> imageFiles = const [],
    bool notify = true,
    bool setImages = true,
  }) async {
    if (setImages) {
      entity.imageNames.clear();
      entity.imageNames
          .addAll(await _imageManager.save(imageFiles, compress: true));
    }

    return super.addOrUpdate(entity, notify: notify);
  }

  @override
  bool matchesFilter(Id id, String? filter, [BuildContext? context]) {
    var trip = entity(id);
    if (trip == null) {
      return false;
    }

    if (super.matchesFilter(trip.id, filter) ||
        _catchManager.idsMatchesFilter(trip.catchIds, filter) ||
        _speciesManager.idsMatchesFilter(
            trip.catchesPerSpecies.map((e) => e.entityId).toList(), filter) ||
        _fishingSpotManager.idsMatchesFilter(
            trip.catchesPerFishingSpot.map((e) => e.entityId).toList(),
            filter) ||
        _anglerManager.idsMatchesFilter(
            trip.catchesPerAngler.map((e) => e.entityId).toList(), filter)) {
      return true;
    }

    if (context != null) {
      return _baitManager.attachmentsMatchesFilter(
              trip.catchesPerBait.map((e) => e.attachment).toList(),
              filter,
              context) ||
          (trip.hasNotes() && containsTrimmedLowerCase(trip.notes, filter!)) ||
          (trip.hasAtmosphere() &&
              trip.atmosphere.matchesFilter(context, filter)) ||
          filterMatchesEntityValues(
              trip.customEntityValues, filter, _customEntityManager);
    }

    return false;
  }

  String deleteMessage(BuildContext context, Trip trip) {
    return format(Strings.of(context).tripListPageDeleteMessage,
        [displayName(context, trip)]);
  }

  int numberOfCatches(Trip trip) {
    if (trip.catchesPerSpecies.isEmpty) {
      // If catchesPerSpecies is not set, add up attached catch quantities.
      return trip.catchIds.fold<int>(0, (prev, e) {
        var cat = _catchManager.entity(e);
        return prev + (cat == null ? 0 : catchQuantity(cat));
      });
    } else {
      // Don't need to include attached catch quantities here because they are
      // automatically added to catchesPerSpecies when the trip is created.
      return trip.catchesPerSpecies.fold<int>(0, (prev, e) => prev + e.value);
    }
  }

  bool isCatchIdInTrip(Id id) =>
      list().where((e) => e.catchIds.contains(id)).isNotEmpty;
}
