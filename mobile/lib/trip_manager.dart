import 'dart:io';

import 'package:fixnum/fixnum.dart';
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
import 'utils/date_time_utils.dart';
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

  List<Trip> trips(
    BuildContext context, {
    String? filter,
    TripFilterOptions? opt,
  }) {
    opt ??= TripFilterOptions();

    if (!opt.hasCurrentTimeZone()) {
      opt.currentTimeZone = _timeManager.currentTimeZone;
    }

    if (!opt.hasCurrentTimestamp()) {
      opt.currentTimestamp = Int64(_timeManager.currentTimestamp);
    }

    // There are some "all" fields required by isolatedFilteredCatches. Set
    // them here if they aren't already set.
    if (opt.allTrips.isEmpty) {
      opt.allTrips.addAll(uuidMap());
    } else {
      _log.d("Trip filter options already includes allTrips");
    }

    return isolatedFilteredTrips(opt)
        .where((trip) => matchesFilter(trip.id, context, filter))
        .toList();
  }

  /// A method that filters a list of given trips. This method is static, and
  /// cannot depend on [BuildContext] so it can be run inside [compute] (Isolate).
  /// It is not, however, _required_ to be run in an isolate.
  ///
  /// Note that at this time, this method _does not_ support localized text
  /// filtering. For searching, use [trips].
  static List<Trip> isolatedFilteredTrips(TripFilterOptions opt) {
    assert(isNotEmpty(opt.currentTimeZone));
    assert(opt.hasCurrentTimestamp());

    List<Trip> trips = opt.allTrips.values.toList();

    if (opt.hasDateRange() || opt.allTrips.isNotEmpty) {
      if (opt.hasDateRange() && !opt.dateRange.hasTimeZone()) {
        opt.dateRange.timeZone = opt.currentTimeZone;
      }

      trips = trips.where((trip) {
        var tz = trip.hasTimeZone() ? trip.timeZone : opt.currentTimeZone;
        if (opt.hasDateRange() &&
            !opt.dateRange.contains(trip.startTimestamp.toInt(),
                dateTime(opt.currentTimestamp.toInt(), tz))) {
          return false;
        }
        return true;
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
  bool matchesFilter(Id id, BuildContext context, String? filter) {
    var trip = entity(id);
    if (trip == null) {
      return false;
    }

    return super.matchesFilter(trip.id, context, filter) ||
        _catchManager.idsMatchFilter(trip.catchIds, context, filter) ||
        _speciesManager.idsMatchFilter(
            trip.catchesPerSpecies.map((e) => e.entityId).toList(),
            context,
            filter) ||
        _fishingSpotManager.idsMatchFilter(
            trip.catchesPerFishingSpot.map((e) => e.entityId).toList(),
            context,
            filter) ||
        _anglerManager.idsMatchFilter(
            trip.catchesPerAngler.map((e) => e.entityId).toList(),
            context,
            filter) ||
        _baitManager.attachmentsMatchesFilter(
            trip.catchesPerBait.map((e) => e.attachment).toList(),
            filter,
            context) ||
        (trip.hasNotes() && containsTrimmedLowerCase(trip.notes, filter!)) ||
        (trip.hasAtmosphere() &&
            trip.atmosphere.matchesFilter(context, filter)) ||
        filterMatchesEntityValues(
            trip.customEntityValues, context, filter, _customEntityManager);
  }

  String deleteMessage(BuildContext context, Trip trip) {
    return format(Strings.of(context).tripListPageDeleteMessage,
        [displayName(context, trip)]);
  }

  int numberOfCatches(Trip trip) {
    return isolatedNumberOfCatches(trip, (id) => _catchManager.entity(id));
  }

  /// A method that returns the number of catches associated with a given [Trip].
  /// This method is static, and cannot depend on [BuildContext] so it can be run
  /// inside [compute] (Isolate). It is not, however, _required_ to be run in an
  /// isolate.
  static int isolatedNumberOfCatches(
      Trip trip, Catch? Function(Id) fetchCatch) {
    if (trip.catchesPerSpecies.isEmpty) {
      // If catchesPerSpecies is not set, add up attached catch quantities.
      return trip.catchIds.fold<int>(0, (prev, e) {
        var cat = fetchCatch(e);
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
