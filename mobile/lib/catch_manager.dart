import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/user_preference_manager.dart';
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

  final _log = const Log("CatchManager");

  CatchManager(AppManager app) : super(app);

  AnglerManager get _anglerManager => appManager.anglerManager;

  BaitManager get _baitManager => appManager.baitManager;

  CustomEntityManager get _customEntityManager =>
      appManager.customEntityManager;

  FishingSpotManager get _fishingSpotManager => appManager.fishingSpotManager;

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
  bool matchesFilter(Id id, String? filter, [BuildContext? context]) {
    var cat = entity(id);
    if (cat == null) {
      return false;
    }

    if (filter == null ||
        isEmpty(filter) ||
        _speciesManager.matchesFilter(cat.speciesId, filter) ||
        _fishingSpotManager.matchesFilter(cat.fishingSpotId, filter) ||
        _anglerManager.matchesFilter(cat.anglerId, filter) ||
        _methodManager.idsMatchFilter(cat.methodIds, filter) ||
        _waterClarityManager.matchesFilter(cat.waterClarityId, filter)) {
      return true;
    }

    if (context != null) {
      return _baitManager.attachmentsMatchesFilter(
              cat.baits, filter, context) ||
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
              cat.customEntityValues, filter, _customEntityManager);
    }

    return false;
  }

  @override
  String get tableName => "catch";

  List<Catch> catches(
    BuildContext context, {
    String? filter,
    CatchFilterOptions? opt,
  }) {
    var catches = opt == null ? entities.values : isolatedFilteredCatches(opt);
    return catches
        .where((cat) => matchesFilter(cat.id, filter, context))
        .toList();
  }

  /// A method that filters a list of given catches. This method is static, and
  /// cannot depend on [BuildContext] so it can be run inside [compute] (Isolate).
  ///
  /// Note that at this time, this method _does not_ support localized text
  /// filtering. For searching, use [catches].
  // TODO: Move to catch_utils.dart
  static Iterable<Catch> isolatedFilteredCatches(CatchFilterOptions opt) {
    assert(isNotEmpty(opt.currentTimeZone));

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
      return opt.allCatches.values;
    }

    bool isSetValid<T>(
      List<T> items,
      T? value, {
      required bool hasValue,
    }) {
      return items.isEmpty || (hasValue && items.contains(value));
    }

    bool isNumberFilterMultiMeasurementValid(
      NumberFilter? filter,
      MultiMeasurement measurement, {
      required bool hasValue,
    }) {
      return filter == null ||
          (hasValue && filter.containsMultiMeasurement(measurement));
    }

    bool isNumberFilterIntValid(
      NumberFilter? filter,
      int value, {
      required bool hasValue,
    }) {
      return filter == null || (hasValue && filter.containsInt(value));
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
          dateRange.contains(cat.timestamp.toInt(), now(timeZone));
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
          opt.waterDepthFilter, cat.waterDepth,
          hasValue: cat.hasWaterDepth());
      valid &= isNumberFilterMultiMeasurementValid(
          opt.waterTemperatureFilter, cat.waterTemperature,
          hasValue: cat.hasWaterTemperature());
      valid &= isNumberFilterMultiMeasurementValid(opt.lengthFilter, cat.length,
          hasValue: cat.hasLength());
      valid &= isNumberFilterMultiMeasurementValid(opt.weightFilter, cat.weight,
          hasValue: cat.hasWeight());
      valid &= isNumberFilterIntValid(opt.quantityFilter, cat.quantity,
          hasValue: cat.hasQuantity());
      valid &= isNumberFilterMultiMeasurementValid(
          opt.airTemperatureFilter, cat.atmosphere.temperature,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasTemperature());
      valid &= isNumberFilterMultiMeasurementValid(
          opt.airPressureFilter, cat.atmosphere.pressure,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasPressure());
      valid &= isNumberFilterMultiMeasurementValid(
          opt.airHumidityFilter, cat.atmosphere.humidity,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasHumidity());
      valid &= isNumberFilterMultiMeasurementValid(
          opt.airVisibilityFilter, cat.atmosphere.visibility,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasVisibility());
      valid &= isNumberFilterMultiMeasurementValid(
          opt.windSpeedFilter, cat.atmosphere.windSpeed,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasWindSpeed());

      var dt = dateTime(cat.timestamp.toInt(), timeZone);
      valid &= !opt.hasHour() || dt.hour == opt.hour;
      valid &= !opt.hasMonth() || dt.month == opt.month;

      return valid;
    }).toList();

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
