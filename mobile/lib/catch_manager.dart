import 'dart:io';

import 'package:flutter/material.dart';
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
import 'method_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'species_manager.dart';
import 'time_manager.dart';
import 'utils/catch_utils.dart';
import 'utils/date_time_utils.dart';
import 'utils/protobuf_utils.dart';
import 'utils/string_utils.dart';
import 'water_clarity_manager.dart';

class CatchManager extends EntityManager<Catch> {
  static CatchManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).catchManager;

  AnglerManager get _anglerManager => appManager.anglerManager;

  BaitManager get _baitManager => appManager.baitManager;

  CustomEntityManager get _customEntityManager =>
      appManager.customEntityManager;

  FishingSpotManager get _fishingSpotManager => appManager.fishingSpotManager;

  ImageManager get _imageManager => appManager.imageManager;

  MethodManager get _methodManager => appManager.methodManager;

  SpeciesManager get _speciesManager => appManager.speciesManager;

  TimeManager get _timeManager => appManager.timeManager;

  WaterClarityManager get _waterClarityManager =>
      appManager.waterClarityManager;

  CatchManager(AppManager app) : super(app);

  @override
  Catch entityFromBytes(List<int> bytes) => Catch.fromBuffer(bytes);

  @override
  Id id(Catch cat) => cat.id;

  @override
  bool matchesFilter(Id id, String? filter, [BuildContext? context]) {
    var cat = entity(id);

    return cat == null ||
        filter == null ||
        isEmpty(filter) ||
        _speciesManager.matchesFilter(cat.speciesId, filter) ||
        _fishingSpotManager.matchesFilter(cat.fishingSpotId, filter) ||
        _baitManager.idsMatchFilter(cat.baitIds, filter) ||
        _anglerManager.matchesFilter(cat.anglerId, filter) ||
        _methodManager.idsMatchFilter(cat.methodIds, filter) ||
        _waterClarityManager.matchesFilter(cat.waterClarityId, filter) ||
        context == null ||
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

  @override
  String get tableName => "catch";

  /// Returns all catches, sorted from newest to oldest.
  List<Catch> catchesSortedByTimestamp(
    BuildContext context, {
    String? filter,
    DateRange? dateRange,
    bool isCatchAndReleaseOnly = false,
    bool isFavoritesOnly = false,
    Set<Id> anglerIds = const {},
    Set<Id> baitIds = const {},
    Set<Id> catchIds = const {},
    Set<Id> fishingSpotIds = const {},
    Set<Id> methodIds = const {},
    Set<Id> speciesIds = const {},
    Set<Id> waterClarityIds = const {},
    Set<Period> periods = const {},
    Set<Season> seasons = const {},
    Set<Direction> windDirections = const {},
    Set<SkyCondition> skyConditions = const {},
    Set<MoonPhase> moonPhases = const {},
    Set<TideType> tideTypes = const {},
    NumberFilter? waterDepthFilter,
    NumberFilter? waterTemperatureFilter,
    NumberFilter? lengthFilter,
    NumberFilter? weightFilter,
    NumberFilter? quantityFilter,
    NumberFilter? airTemperatureFilter,
    NumberFilter? airPressureFilter,
    NumberFilter? airHumidityFilter,
    NumberFilter? airVisibilityFilter,
    NumberFilter? windSpeedFilter,
  }) {
    var result = List.of(filteredCatches(
      context,
      filter: filter,
      dateRange: dateRange,
      isCatchAndReleaseOnly: isCatchAndReleaseOnly,
      isFavoritesOnly: isFavoritesOnly,
      anglerIds: anglerIds,
      baitIds: baitIds,
      catchIds: catchIds,
      fishingSpotIds: fishingSpotIds,
      methodIds: methodIds,
      speciesIds: speciesIds,
      waterClarityIds: waterClarityIds,
      periods: periods,
      seasons: seasons,
      windDirections: windDirections,
      skyConditions: skyConditions,
      moonPhases: moonPhases,
      tideTypes: tideTypes,
      waterDepthFilter: waterDepthFilter,
      waterTemperatureFilter: waterTemperatureFilter,
      lengthFilter: lengthFilter,
      weightFilter: weightFilter,
      quantityFilter: quantityFilter,
      airTemperatureFilter: airTemperatureFilter,
      airPressureFilter: airPressureFilter,
      airHumidityFilter: airHumidityFilter,
      airVisibilityFilter: airVisibilityFilter,
      windSpeedFilter: windSpeedFilter,
    ));

    result.sort((lhs, rhs) => rhs.timestamp.compareTo(lhs.timestamp));
    return result;
  }

  List<Catch> filteredCatches(
    BuildContext context, {
    String? filter,
    DateRange? dateRange,
    bool isCatchAndReleaseOnly = false,
    bool isFavoritesOnly = false,
    Set<Id> anglerIds = const {},
    Set<Id> baitIds = const {},
    Set<Id> catchIds = const {},
    Set<Id> fishingSpotIds = const {},
    Set<Id> methodIds = const {},
    Set<Id> speciesIds = const {},
    Set<Id> waterClarityIds = const {},
    Set<Period> periods = const {},
    Set<Season> seasons = const {},
    Set<Direction> windDirections = const {},
    Set<SkyCondition> skyConditions = const {},
    Set<MoonPhase> moonPhases = const {},
    Set<TideType> tideTypes = const {},
    NumberFilter? waterDepthFilter,
    NumberFilter? waterTemperatureFilter,
    NumberFilter? lengthFilter,
    NumberFilter? weightFilter,
    NumberFilter? quantityFilter,
    NumberFilter? airTemperatureFilter,
    NumberFilter? airPressureFilter,
    NumberFilter? airHumidityFilter,
    NumberFilter? airVisibilityFilter,
    NumberFilter? windSpeedFilter,
  }) {
    if (isEmpty(filter) &&
        dateRange == null &&
        !isCatchAndReleaseOnly &&
        !isFavoritesOnly &&
        anglerIds.isEmpty &&
        baitIds.isEmpty &&
        catchIds.isEmpty &&
        fishingSpotIds.isEmpty &&
        methodIds.isEmpty &&
        speciesIds.isEmpty &&
        waterClarityIds.isEmpty &&
        periods.isEmpty &&
        seasons.isEmpty &&
        windDirections.isEmpty &&
        skyConditions.isEmpty &&
        moonPhases.isEmpty &&
        tideTypes.isEmpty &&
        waterDepthFilter == null &&
        waterTemperatureFilter == null &&
        lengthFilter == null &&
        weightFilter == null &&
        quantityFilter == null &&
        airTemperatureFilter == null &&
        airPressureFilter == null &&
        airHumidityFilter == null &&
        airVisibilityFilter == null &&
        windSpeedFilter == null) {
      return entities.values.toList();
    }

    bool isSetValid<T>(
      Set<T> items,
      T value, {
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

    bool isNumberFilterMeasurementValid(
      NumberFilter? filter,
      Measurement measurement, {
      required bool hasValue,
    }) {
      return filter == null ||
          (hasValue && filter.containsMeasurement(measurement));
    }

    bool isNumberFilterIntValid(
      NumberFilter? filter,
      int value, {
      required bool hasValue,
    }) {
      return filter == null || (hasValue && filter.containsInt(value));
    }

    return entities.values.where((cat) {
      var valid = true;
      valid &= dateRange == null ||
          dateRange.contains(
              cat.timestamp.toInt(), _timeManager.currentDateTime);
      valid &=
          isSetValid<Id>(anglerIds, cat.anglerId, hasValue: cat.hasAnglerId());
      valid &= baitIds.isEmpty ||
          baitIds.intersection(cat.baitIds.toSet()).isNotEmpty;
      valid &= isSetValid<Id>(catchIds, cat.id, hasValue: cat.hasId());
      valid &= isSetValid<Id>(fishingSpotIds, cat.fishingSpotId,
          hasValue: cat.hasFishingSpotId());
      valid &= isSetValid<Id>(speciesIds, cat.speciesId,
          hasValue: cat.hasSpeciesId());
      valid &= isSetValid<Id>(waterClarityIds, cat.waterClarityId,
          hasValue: cat.hasWaterClarityId());
      valid &= methodIds.isEmpty ||
          methodIds.intersection(cat.methodIds.toSet()).isNotEmpty;
      valid &=
          isSetValid<Period>(periods, cat.period, hasValue: cat.hasPeriod());
      valid &=
          isSetValid<Season>(seasons, cat.season, hasValue: cat.hasSeason());
      valid &= isSetValid<Direction>(
          windDirections, cat.atmosphere.windDirection,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasWindDirection());
      valid &= isSetValid<MoonPhase>(moonPhases, cat.atmosphere.moonPhase,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasMoonPhase());
      valid &= isSetValid<TideType>(tideTypes, cat.tide.type,
          hasValue: cat.hasTide() && cat.tide.hasType());
      valid &= skyConditions.isEmpty ||
          (cat.hasAtmosphere() &&
              skyConditions
                  .intersection(cat.atmosphere.skyConditions.toSet())
                  .isNotEmpty);
      valid &= !isFavoritesOnly || cat.isFavorite;
      valid &= !isCatchAndReleaseOnly || cat.wasCatchAndRelease;
      valid &= isNumberFilterMultiMeasurementValid(
          waterDepthFilter, cat.waterDepth,
          hasValue: cat.hasWaterDepth());
      valid &= isNumberFilterMultiMeasurementValid(
          waterTemperatureFilter, cat.waterTemperature,
          hasValue: cat.hasWaterTemperature());
      valid &= isNumberFilterMultiMeasurementValid(lengthFilter, cat.length,
          hasValue: cat.hasLength());
      valid &= isNumberFilterMultiMeasurementValid(weightFilter, cat.weight,
          hasValue: cat.hasWeight());
      valid &= isNumberFilterIntValid(quantityFilter, cat.quantity,
          hasValue: cat.hasQuantity());
      valid &= isNumberFilterMeasurementValid(
          airTemperatureFilter, cat.atmosphere.temperature,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasTemperature());
      valid &= isNumberFilterMeasurementValid(
          airPressureFilter, cat.atmosphere.pressure,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasPressure());
      valid &= isNumberFilterMeasurementValid(
          airHumidityFilter, cat.atmosphere.humidity,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasHumidity());
      valid &= isNumberFilterMeasurementValid(
          airVisibilityFilter, cat.atmosphere.visibility,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasVisibility());
      valid &= isNumberFilterMeasurementValid(
          windSpeedFilter, cat.atmosphere.windSpeed,
          hasValue: cat.hasAtmosphere() && cat.atmosphere.hasWindSpeed());

      if (!valid) {
        return false;
      }

      return matchesFilter(cat.id, filter, context);
    }).toList();
  }

  /// Returns all image names from [Catch] objects, where the [Catch] objects
  /// are sorted by timestamp.
  List<String> imageNamesSortedByTimestamp(BuildContext context) {
    return catchesSortedByTimestamp(context)
        .expand((cat) => cat.imageNames)
        .toList();
  }

  @override
  Future<bool> addOrUpdate(
    Catch cat, {
    List<File> imageFiles = const [],
    bool compressImages = true,
    bool notify = true,
  }) async {
    cat.imageNames.clear();
    cat.imageNames
        .addAll(await _imageManager.save(imageFiles, compress: compressImages));

    return super.addOrUpdate(cat, notify: notify);
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
    var species = _speciesManager.entity(cat.speciesId);
    var timeString = formatTimestamp(context, cat.timestamp.toInt());
    String name;
    if (species == null) {
      name = "($timeString)";
    } else {
      name = "${species.name} ($timeString)";
    }

    return format(Strings.of(context).catchPageDeleteMessage, [name]);
  }

  /// Returns the total number of [CustomEntityValue] objects associated with
  /// [Catch] objects and [customEntityId].
  int numberOfCustomEntityValues(Id customEntityId) {
    return entityValuesCount<Catch>(
        list(), customEntityId, (cat) => cat.customEntityValues);
  }
}
