import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import 'angler_manager.dart';
import 'app_manager.dart';
import 'bait_manager.dart';
import 'custom_entity_manager.dart';
import 'entity_manager.dart';
import 'fishing_spot_manager.dart';
import 'i18n/strings.dart';
import 'image_manager.dart';
import 'log.dart';
import 'method_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'species_manager.dart';
import 'utils/catch_utils.dart';
import 'utils/date_time_utils.dart';
import 'utils/protobuf_utils.dart';
import 'utils/string_utils.dart';
import 'water_clarity_manager.dart';

class CatchManager extends EntityManager<Catch> {
  static CatchManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).catchManager;

  /// The number of meters by which to increase a [GpsTrail] bounds when
  /// determining if a catch occurred with that [GpsTrail].
  static const _gpsTrailCatchTolerance = 200.0;

  final _log = const Log("CatchManager");

  CatchManager(AppManager app) : super(app);

  AnglerManager get _anglerManager => appManager.anglerManager;

  BaitManager get _baitManager => appManager.baitManager;

  CustomEntityManager get _customEntityManager =>
      appManager.customEntityManager;

  FishingSpotManager get _fishingSpotManager => appManager.fishingSpotManager;

  GearManager get _gearManager => appManager.gearManager;

  ImageManager get _imageManager => appManager.imageManager;

  MethodManager get _methodManager => appManager.methodManager;

  SpeciesManager get _speciesManager => appManager.speciesManager;

  TimeManager get _timeManager => appManager.timeManager;

  TripManager get _tripManager => appManager.tripManager;

  UserPreferenceManager get _userPreferenceManager =>
      appManager.userPreferenceManager;

  WaterClarityManager get _waterClarityManager =>
      appManager.waterClarityManager;

  @override
  Future<void> initialize() async {
    await super.initialize();

    // TODO: Remove (#683)
    var numberOfChanges = await updateAll(
      where: (cat) => !cat.hasTimeZone(),
      apply: (cat) async => await addOrUpdate(
        cat..timeZone = _timeManager.currentTimeZone,
        setImages: false,
        notify: false,
      ),
    );
    _log.d("Added time zones to $numberOfChanges catches");

    // TODO: Remove (#696)
    numberOfChanges = await updateAll(
      where: (cat) => cat.hasAtmosphere() && cat.atmosphere.hasDeprecations(),
      apply: (cat) async => await addOrUpdate(
        cat..atmosphere.clearDeprecations(_userPreferenceManager),
        setImages: false,
        notify: false,
      ),
    );
    _log.d("Updated $numberOfChanges deprecated atmosphere objects");
  }

  @override
  Catch entityFromBytes(List<int> bytes) => Catch.fromBuffer(bytes);

  @override
  Id id(Catch entity) => entity.id;

  @override
  String displayName(BuildContext context, Catch entity) {
    var species = _speciesManager.entity(entity.speciesId);
    var timeString = entity.displayTimestamp(context);

    if (species == null) {
      return timeString;
    } else {
      return "${_speciesManager.displayName(context, species)} ($timeString)";
    }
  }

  @override
  bool matchesFilter(Id id, BuildContext context, String? filter) {
    var cat = entity(id);
    if (cat == null) {
      return false;
    }

    return filter == null ||
        isEmpty(filter) ||
        _speciesManager.matchesFilter(cat.speciesId, context, filter) ||
        _fishingSpotManager.matchesFilter(cat.fishingSpotId, context, filter) ||
        _anglerManager.matchesFilter(cat.anglerId, context, filter) ||
        _methodManager.idsMatchFilter(cat.methodIds, context, filter) ||
        _waterClarityManager.matchesFilter(
            cat.waterClarityId, context, filter) ||
        _gearManager.idsMatchFilter(cat.gearIds, context, filter) ||
        _baitManager.attachmentsMatchesFilter(cat.baits, filter, context) ||
        catchFilterMatchesPeriod(context, filter, cat) ||
        catchFilterMatchesSeason(context, filter, cat) ||
        catchFilterMatchesFavorite(context, filter, cat) ||
        catchFilterMatchesCatchAndRelease(context, filter, cat) ||
        catchFilterMatchesTimestamp(context, filter, cat) ||
        catchFilterMatchesWaterDepth(context, filter, cat) ||
        catchFilterMatchesWaterTemperature(context, filter, cat) ||
        catchFilterMatchesLength(context, filter, cat) ||
        catchFilterMatchesWeight(context, filter, cat) ||
        catchFilterMatchesQuantity(context, filter, cat) ||
        catchFilterMatchesNotes(context, filter, cat) ||
        catchFilterMatchesAtmosphere(context, filter, cat) ||
        catchFilterMatchesTide(context, filter, cat) ||
        filterMatchesEntityValues(
            cat.customEntityValues, context, filter, _customEntityManager);
  }

  @override
  String get tableName => "catch";

  List<Catch> catches(
    BuildContext context, {
    String? filter,
    CatchFilterOptions? opt,
  }) {
    opt ??= CatchFilterOptions();

    if (!opt.hasCurrentTimeZone()) {
      opt.currentTimeZone = _timeManager.currentTimeZone;
    }

    if (!opt.hasCurrentTimestamp()) {
      opt.currentTimestamp = Int64(_timeManager.currentTimestamp);
    }

    // There are some "all" fields required by isolatedFilteredCatches. Set
    // them here if they aren't already set.
    if (opt.allFishingSpots.isEmpty) {
      opt.allFishingSpots.addAll(_fishingSpotManager.uuidMap());
    } else {
      _log.d("Catch filter options already includes allFishingSpots");
    }

    if (opt.allCatches.isEmpty) {
      opt.allCatches.addAll(uuidMap());
    } else {
      _log.d("Catch filter options already includes allCatches");
    }

    return isolatedFilteredCatches(opt)
        .where((cat) => matchesFilter(cat.id, context, filter))
        .toList();
  }

  /// Returns a list of catches that occurred within the given [GpsTrail].
  Iterable<Catch> catchesForGpsTrail(GpsTrail trail) {
    var trailBounds = mapBounds(trail.points.map((e) => e.latLng))
        ?.grow(_gpsTrailCatchTolerance);
    if (trailBounds == null) {
      return [];
    }

    return list().where((cat) {
      var fishingSpot = _fishingSpotManager.entity(cat.fishingSpotId);
      if (fishingSpot == null) {
        return false;
      }

      var endTimestamp = trail.hasEndTimestamp()
          ? trail.endTimestamp
          : _timeManager.currentTimestamp;

      return cat.timestamp >= trail.startTimestamp &&
          cat.timestamp < endTimestamp &&
          trailBounds.contains(fishingSpot.latLng);
    });
  }

  /// A method that filters a list of given catches. This method is static, and
  /// cannot depend on [BuildContext] so it can be run inside [compute] (Isolate).
  /// It is not, however, _required_ to be run in an isolate.
  ///
  /// Note that at this time, this method _does not_ support localized text
  /// filtering. For searching, use [catches].
  static Iterable<Catch> isolatedFilteredCatches(CatchFilterOptions opt) {
    assert(isNotEmpty(opt.currentTimeZone));
    assert(opt.hasCurrentTimestamp());

    // Set a default time zone for any date ranges that don't have one set.
    for (var dateRange in opt.dateRanges) {
      if (dateRange.hasTimeZone()) {
        continue;
      }
      dateRange.timeZone = opt.currentTimeZone;
    }

    if (opt.dateRanges.isEmpty &&
        !opt.hasIsCatchAndReleaseOnly() &&
        !opt.hasIsFavoritesOnly() &&
        opt.anglerIds.isEmpty &&
        opt.baits.isEmpty &&
        opt.catchIds.isEmpty &&
        opt.fishingSpotIds.isEmpty &&
        opt.bodyOfWaterIds.isEmpty &&
        opt.methodIds.isEmpty &&
        opt.speciesIds.isEmpty &&
        opt.waterClarityIds.isEmpty &&
        opt.gearIds.isEmpty &&
        opt.periods.isEmpty &&
        opt.seasons.isEmpty &&
        opt.windDirections.isEmpty &&
        opt.skyConditions.isEmpty &&
        opt.moonPhases.isEmpty &&
        opt.tideTypes.isEmpty &&
        !opt.hasWaterDepthFilter() &&
        !opt.hasWaterTemperatureFilter() &&
        !opt.hasLengthFilter() &&
        !opt.hasWeightFilter() &&
        !opt.hasQuantityFilter() &&
        !opt.hasAirTemperatureFilter() &&
        !opt.hasAirPressureFilter() &&
        !opt.hasAirHumidityFilter() &&
        !opt.hasAirVisibilityFilter() &&
        !opt.hasWindSpeedFilter() &&
        !opt.hasHour() &&
        !opt.hasMonth()) {
      return isolatedSortedCatches(opt.allCatches.values, opt);
    }

    bool isSetValid<T>(
      List<T> items,
      T? value, {
      required bool hasValue,
    }) {
      return items.isEmpty || (hasValue && items.contains(value));
    }

    bool isNumberFilterMultiMeasurementValid(
      bool hasFilter,
      NumberFilter filter,
      MultiMeasurement measurement, {
      required bool hasValue,
    }) {
      return !hasFilter ||
          (hasValue && filter.containsMultiMeasurement(measurement));
    }

    bool isNumberFilterIntValid(
      bool hasFilter,
      NumberFilter filter,
      int value, {
      required bool hasValue,
    }) {
      return !hasFilter || (hasValue && filter.containsInt(value));
    }

    // Returns true if the given catch has a bait attachment that intersects
    // with the input attachments. If the input attachments do not have a
    // variant (i.e. it represents a "parent" bait), this method will return
    // true if one of the catch's bait attachments have the same bait ID,
    // regardless of whether it also has a variant ID.
    bool areBaitsValid(Catch cat) {
      if (opt.baits.isEmpty) {
        return true;
      }

      for (var bait in opt.baits) {
        for (var attachment in cat.baits) {
          if (bait.baitId == attachment.baitId &&
              (!bait.hasVariantId() ||
                  bait.variantId == attachment.variantId)) {
            return true;
          }
        }
      }

      return false;
    }

    var result = opt.allCatches.values.where((cat) {
      var timeZone = isEmpty(cat.timeZone) ? opt.currentTimeZone : cat.timeZone;
      var fishingSpot = opt.allFishingSpots.values
          .firstWhereOrNull((spot) => spot.id == cat.fishingSpotId);
      var dateRange = opt.dateRanges.firstOrNull;

      var valid = true;
      valid &= dateRange == null ||
          dateRange.contains(cat.timestamp.toInt(),
              dateTime(opt.currentTimestamp.toInt(), timeZone));
      valid &= isSetValid<Id>(opt.anglerIds, cat.anglerId,
          hasValue: cat.hasAnglerId());
      valid &= areBaitsValid(cat);
      valid &= isSetValid<Id>(opt.catchIds, cat.id, hasValue: cat.hasId());
      valid &= isSetValid<Id>(opt.fishingSpotIds, cat.fishingSpotId,
          hasValue: cat.hasFishingSpotId());
      valid &= isSetValid<Id>(opt.bodyOfWaterIds, fishingSpot?.bodyOfWaterId,
          hasValue: fishingSpot != null);
      valid &= isSetValid<Id>(opt.speciesIds, cat.speciesId,
          hasValue: cat.hasSpeciesId());
      valid &= isSetValid<Id>(opt.waterClarityIds, cat.waterClarityId,
          hasValue: cat.hasWaterClarityId());

      var methodSet = opt.methodIds.toSet();
      valid &= methodSet.isEmpty ||
          methodSet.intersection(cat.methodIds.toSet()).isNotEmpty;

      var gearSet = opt.gearIds.toSet();
      valid &= gearSet.isEmpty ||
          gearSet.intersection(cat.gearIds.toSet()).isNotEmpty;

      valid &= isSetValid<Period>(opt.periods, cat.period,
          hasValue: cat.hasPeriod());
      valid &= isSetValid<Season>(opt.seasons, cat.season,
          hasValue: cat.hasSeason());
      valid &= isSetValid<Direction>(
          opt.windDirections, cat.atmosphere.windDirection,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasWindDirection());
      valid &= isSetValid<MoonPhase>(opt.moonPhases, cat.atmosphere.moonPhase,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasMoonPhase());
      valid &= isSetValid<TideType>(opt.tideTypes, cat.tide.type,
          hasValue: cat.hasTide() && cat.tide.hasType());
      var skyConditionsSet = opt.skyConditions.toSet();
      valid &= skyConditionsSet.isEmpty ||
          (cat.hasAtmosphere() &&
              skyConditionsSet
                  .intersection(cat.atmosphere.skyConditions.toSet())
                  .isNotEmpty);
      valid &= !opt.isFavoritesOnly || cat.isFavorite;
      valid &= !opt.isCatchAndReleaseOnly || cat.wasCatchAndRelease;
      valid &= isNumberFilterMultiMeasurementValid(
          opt.hasWaterDepthFilter(), opt.waterDepthFilter, cat.waterDepth,
          hasValue: cat.hasWaterDepth());
      valid &= isNumberFilterMultiMeasurementValid(
          opt.hasWaterTemperatureFilter(),
          opt.waterTemperatureFilter,
          cat.waterTemperature,
          hasValue: cat.hasWaterTemperature());
      valid &= isNumberFilterMultiMeasurementValid(
          opt.hasLengthFilter(), opt.lengthFilter, cat.length,
          hasValue: cat.hasLength());
      valid &= isNumberFilterMultiMeasurementValid(
          opt.hasWeightFilter(), opt.weightFilter, cat.weight,
          hasValue: cat.hasWeight());
      valid &= isNumberFilterIntValid(
          opt.hasQuantityFilter(), opt.quantityFilter, cat.quantity,
          hasValue: cat.hasQuantity());
      valid &= isNumberFilterMultiMeasurementValid(
          opt.hasAirTemperatureFilter(),
          opt.airTemperatureFilter,
          cat.atmosphere.temperature,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasTemperature());
      valid &= isNumberFilterMultiMeasurementValid(opt.hasAirPressureFilter(),
          opt.airPressureFilter, cat.atmosphere.pressure,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasPressure());
      valid &= isNumberFilterMultiMeasurementValid(opt.hasAirHumidityFilter(),
          opt.airHumidityFilter, cat.atmosphere.humidity,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasHumidity());
      valid &= isNumberFilterMultiMeasurementValid(opt.hasAirVisibilityFilter(),
          opt.airVisibilityFilter, cat.atmosphere.visibility,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasVisibility());
      valid &= isNumberFilterMultiMeasurementValid(opt.hasWindSpeedFilter(),
          opt.windSpeedFilter, cat.atmosphere.windSpeed,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasWindSpeed());

      var dt = dateTime(cat.timestamp.toInt(), timeZone);
      valid &= !opt.hasHour() || dt.hour == opt.hour;
      valid &= !opt.hasMonth() || dt.month == opt.month;

      return valid;
    }).toList();

    return isolatedSortedCatches(result, opt);
  }

  /// A method that sorts a list of given catches. This method is static, and
  /// cannot depend on [BuildContext] so it can be run inside [compute] (Isolate).
  /// It is not, however, _required_ to be run in an isolate.
  // TODO: Move to catch_utils.dart
  static Iterable<Catch> isolatedSortedCatches(
    Iterable<Catch> catches,
    CatchFilterOptions opt,
  ) {
    var result = List.of(catches);
    var sortOrder =
        opt.hasOrder() ? opt.order : CatchFilterOptions_Order.newest_to_oldest;

    switch (sortOrder) {
      case CatchFilterOptions_Order.heaviest_to_lightest:
        result.sort((lhs, rhs) => rhs.weight.compareTo(lhs.weight));
        break;
      case CatchFilterOptions_Order.longest_to_shortest:
        result.sort((lhs, rhs) => rhs.length.compareTo(lhs.length));
        break;
      case CatchFilterOptions_Order.newest_to_oldest:
        result.sort((lhs, rhs) => rhs.timestamp.compareTo(lhs.timestamp));
        break;
      case CatchFilterOptions_Order.unknown:
        // Can't happen.
        break;
    }

    return result;
  }

  /// Returns all image names from [Catch] objects, where the [Catch] objects
  /// are sorted by timestamp.
  List<String> imageNamesSortedByTimestamp(BuildContext context) {
    return catches(context).expand((cat) => cat.imageNames).toList();
  }

  @override
  Future<bool> addOrUpdate(
    Catch entity, {
    List<File> imageFiles = const [],
    bool compressImages = true,
    bool notify = true,
    bool setImages = true,
  }) async {
    if (setImages) {
      entity.imageNames.clear();
      entity.imageNames.addAll(
          await _imageManager.save(imageFiles, compress: compressImages));
    }

    return super.addOrUpdate(entity, notify: notify);
  }

  /// Returns true if a [Catch] with the given properties exists.
  bool existsWith({
    Id? speciesId,
  }) {
    return list()
        .where((cat) => cat.hasSpeciesId() && cat.speciesId == speciesId)
        .isNotEmpty;
  }

  String deleteMessage(BuildContext context, Catch cat) {
    return format(
      _tripManager.isCatchIdInTrip(cat.id)
          ? Strings.of(context).catchPageDeleteWithTripMessage
          : Strings.of(context).catchPageDeleteMessage,
      [displayName(context, cat)],
    );
  }

  /// Returns the total number of [CustomEntityValue] objects associated with
  /// [Catch] objects and [customEntityId].
  int numberOfCustomEntityValues(Id customEntityId) {
    return entityValuesCount<Catch>(
        list(), customEntityId, (cat) => cat.customEntityValues);
  }

  /// Returns the total number of catches (including the quantity field) in the
  /// given [Id] set.
  int totalQuantity(List<Id> catchIds) {
    return catchIds.fold<int>(0, (prevValue, id) {
      var cat = entity(id);
      return prevValue + ((cat?.hasQuantity() ?? false) ? cat!.quantity : 1);
    });
  }
}
