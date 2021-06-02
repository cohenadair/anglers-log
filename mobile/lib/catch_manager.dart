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

  CatchManager(AppManager app) : super(app) {
    app.baitManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteBait,
    ));
    app.fishingSpotManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteFishingSpot,
    ));
  }

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
        _baitManager.matchesFilter(cat.baitId, filter) ||
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
    NumberFilter? waterDepthFilter,
    NumberFilter? waterTemperatureFilter,
    NumberFilter? lengthFilter,
    NumberFilter? weightFilter,
    NumberFilter? quantityFilter,
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
      waterDepthFilter: waterDepthFilter,
      waterTemperatureFilter: waterTemperatureFilter,
      lengthFilter: lengthFilter,
      weightFilter: weightFilter,
      quantityFilter: quantityFilter,
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
    NumberFilter? waterDepthFilter,
    NumberFilter? waterTemperatureFilter,
    NumberFilter? lengthFilter,
    NumberFilter? weightFilter,
    NumberFilter? quantityFilter,
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
        waterDepthFilter == null &&
        waterTemperatureFilter == null &&
        lengthFilter == null &&
        weightFilter == null &&
        quantityFilter == null) {
      return entities.values.toList();
    }

    return entities.values.where((cat) {
      var valid = true;
      valid &= dateRange == null ||
          dateRange.contains(
              cat.timestamp.toInt(), _timeManager.currentDateTime);
      valid &= anglerIds.isEmpty || anglerIds.contains(cat.anglerId);
      valid &= baitIds.isEmpty || baitIds.contains(cat.baitId);
      valid &= catchIds.isEmpty || catchIds.contains(cat.id);
      valid &=
          fishingSpotIds.isEmpty || fishingSpotIds.contains(cat.fishingSpotId);
      valid &= methodIds.isEmpty ||
          methodIds.intersection(cat.methodIds.toSet()).isNotEmpty;
      valid &= speciesIds.isEmpty || speciesIds.contains(cat.speciesId);
      valid &= waterClarityIds.isEmpty ||
          waterClarityIds.contains(cat.waterClarityId);
      valid &=
          periods.isEmpty || (cat.hasPeriod() && periods.contains(cat.period));
      valid &=
          seasons.isEmpty || (cat.hasSeason() && seasons.contains(cat.season));
      valid &= !isFavoritesOnly || cat.isFavorite;
      valid &= !isCatchAndReleaseOnly || cat.wasCatchAndRelease;
      valid &= waterDepthFilter == null ||
          (cat.hasWaterDepth() &&
              waterDepthFilter.containsMultiMeasurement(cat.waterDepth));
      valid &= waterTemperatureFilter == null ||
          (cat.hasWaterTemperature() &&
              waterTemperatureFilter
                  .containsMultiMeasurement(cat.waterTemperature));
      valid &= lengthFilter == null ||
          (cat.hasLength() &&
              lengthFilter.containsMultiMeasurement(cat.length));
      valid &= weightFilter == null ||
          (cat.hasWeight() &&
              weightFilter.containsMultiMeasurement(cat.weight));
      valid &= quantityFilter == null ||
          (cat.hasQuantity() && quantityFilter.containsInt(cat.quantity));
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

  void _onDeleteBait(Bait bait) {
    for (var cat
        in List<Catch>.from(list().where((cat) => bait.id == cat.baitId))) {
      addOrUpdate(cat..clearBaitId());
    }
  }

  void _onDeleteFishingSpot(FishingSpot fishingSpot) {
    for (var cat in List<Catch>.from(
        list().where((cat) => fishingSpot.id == cat.fishingSpotId))) {
      addOrUpdate(cat..clearFishingSpotId());
    }
  }
}
