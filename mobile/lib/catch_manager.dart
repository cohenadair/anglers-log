import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'bait_manager.dart';
import 'custom_entity_manager.dart';
import 'entity_manager.dart';
import 'fishing_spot_manager.dart';
import 'i18n/strings.dart';
import 'image_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'species_manager.dart';
import 'utils/date_time_utils.dart';
import 'utils/protobuf_utils.dart';
import 'utils/string_utils.dart';

class CatchManager extends EntityManager<Catch> {
  static CatchManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).catchManager;

  BaitManager get _baitManager => appManager.baitManager;
  CustomEntityManager get _customEntityManager =>
      appManager.customEntityManager;
  FishingSpotManager get _fishingSpotManager => appManager.fishingSpotManager;
  ImageManager get _imageManager => appManager.imageManager;
  SpeciesManager get _speciesManager => appManager.speciesManager;

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
  bool matchesFilter(Id id, String filter, [BuildContext context]) {
    var cat = entity(id);

    if (cat == null ||
        isEmpty(filter) ||
        _speciesManager.matchesFilter(cat.speciesId, filter) ||
        _fishingSpotManager.matchesFilter(cat.fishingSpotId, filter) ||
        _baitManager.matchesFilter(cat.baitId, filter) ||
        context == null ||
        timestampToSearchString(context, cat.timestamp.toInt())
            .toLowerCase()
            .contains(filter.toLowerCase()) ||
        entityValuesMatchesFilter(
            cat.customEntityValues, filter, _customEntityManager)) {
      return true;
    }

    return false;
  }

  @override
  String get tableName => "catch";

  /// Returns all catches, sorted from newest to oldest.
  List<Catch> catchesSortedByTimestamp(
    BuildContext context, {
    String filter,
    DateRange dateRange,
    Set<Id> catchIds = const {},
    Set<Id> baitIds = const {},
    Set<Id> fishingSpotIds = const {},
    Set<Id> speciesIds = const {},
  }) {
    assert(catchIds != null);
    assert(baitIds != null);
    assert(fishingSpotIds != null);
    assert(speciesIds != null);

    var result = List.of(filteredCatches(
      context,
      filter: filter,
      dateRange: dateRange,
      catchIds: catchIds,
      fishingSpotIds: fishingSpotIds,
      baitIds: baitIds,
      speciesIds: speciesIds,
    ));

    result.sort((lhs, rhs) => rhs.timestamp.compareTo(lhs.timestamp));
    return result;
  }

  List<Catch> filteredCatches(
    BuildContext context, {
    String filter,
    DateRange dateRange,
    Set<Id> catchIds = const {},
    Set<Id> baitIds = const {},
    Set<Id> fishingSpotIds = const {},
    Set<Id> speciesIds = const {},
  }) {
    assert(catchIds != null);
    assert(baitIds != null);
    assert(fishingSpotIds != null);
    assert(speciesIds != null);

    if (isEmpty(filter) &&
        dateRange == null &&
        catchIds.isEmpty &&
        baitIds.isEmpty &&
        fishingSpotIds.isEmpty &&
        speciesIds.isEmpty) {
      return entities.values.toList();
    }

    return entities.values.where((cat) {
      var valid = true;
      valid &= dateRange == null || dateRange.contains(cat.timestamp.toInt());
      valid &= catchIds.isEmpty || catchIds.contains(cat.id);
      valid &= baitIds.isEmpty || baitIds.contains(cat.baitId);
      valid &=
          fishingSpotIds.isEmpty || fishingSpotIds.contains(cat.fishingSpotId);
      valid &= speciesIds.isEmpty || speciesIds.contains(cat.speciesId);
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
    List<File> imageFiles,
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
    Id speciesId,
  }) {
    return list().firstWhere(
            (cat) => cat.hasSpeciesId() && cat.speciesId == speciesId,
            orElse: () => null) !=
        null;
  }

  String deleteMessage(BuildContext context, Catch cat) {
    assert(context != null);
    assert(cat != null);

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
