import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

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
  Id id(Catch cat) => Id(cat.id);

  @override
  bool matchesFilter(Id id, String filter, [BuildContext context]) {
    Catch cat = entity(id);

    if (isEmpty(filter)
        || (cat.speciesId.isNotEmpty
            && _speciesManager.matchesFilter(Id(cat.speciesId), filter))
        || (cat.fishingSpotId.isNotEmpty
            && _fishingSpotManager.matchesFilter(Id(cat.fishingSpotId), filter))
        || (cat.baitId.isNotEmpty
            && _baitManager.matchesFilter(Id(cat.baitId), filter))
        || context == null
        || timestampToSearchString(context, cat.timestamp).toLowerCase()
            .contains(filter.toLowerCase())
        || entityValuesMatchesFilter(cat.customEntityValues, filter,
            _customEntityManager))
    {
      return true;
    }

    return false;
  }

  @override
  String get tableName => "catch";

  /// Returns all catches, sorted from newest to oldest.
  List<Catch> catchesSortedByTimestamp(BuildContext context, {
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

    List<Catch> result = List.of(filteredCatches(
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

  List<Catch> filteredCatches(BuildContext context, {
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

    if (isEmpty(filter) && dateRange == null && catchIds.isEmpty
        && baitIds.isEmpty && fishingSpotIds.isEmpty && speciesIds.isEmpty)
    {
      return entities.values.toList();
    }

    return entities.values.where((cat) {
      bool valid = true;
      valid &= dateRange == null || dateRange.contains(cat.timestamp);
      valid &= catchIds.isEmpty || catchIds.contains(Id(cat.id));
      valid &= baitIds.isEmpty || baitIds.contains(Id(cat.baitId));
      valid &= fishingSpotIds.isEmpty
          || fishingSpotIds.contains(Id(cat.fishingSpotId));
      valid &= speciesIds.isEmpty || speciesIds.contains(Id(cat.speciesId));
      if (!valid) {
        return false;
      }

      return matchesFilter(Id(cat.id), filter, context);
    }).toList();
  }

  @override
  Future<bool> addOrUpdate(Catch cat, {
    FishingSpot fishingSpot,
    List<File> imageFiles,
    bool compressImages = true,
    bool notify = true,
  }) async {
    // Update dependencies first, so when listeners are notified, all data is
    // available.
    if (fishingSpot != null) {
      await _fishingSpotManager.addOrUpdate(fishingSpot);
    }

    await _imageManager.save(imageFiles, compress: compressImages);
    return super.addOrUpdate(cat, notify: notify);
  }

  /// Returns true if a [Catch] with the given properties exists.
  bool existsWith({
    Id speciesId,
  }) {
    return list().firstWhere((cat) => Id(cat.speciesId) == speciesId,
        orElse: () => null) != null;
  }

  String deleteMessage(BuildContext context, Catch cat) {
    if (cat == null) {
      return null;
    }

    Species species = _speciesManager.entity(Id(cat.speciesId));
    String name = "${species.name} (${formatTimestamp(context,
        cat.timestamp)})";
    return format(Strings.of(context).catchPageDeleteMessage, [name]);
  }

  /// Returns the total number of [CustomEntityValue] objects associated with
  /// [Catch] objects and [customEntityId].
  int numberOfCustomEntityValues(Id customEntityId) {
    return entityValuesCount<Catch>(list(), customEntityId,
        (cat) => cat.customEntityValues);
  }

  void _onDeleteBait(Bait bait) async {
    List<Catch>.from(list()
        .where((cat) => bait.id == cat.baitId))
        .forEach((cat) {
          entities[Id(cat.id)] =
              cat.copyWith((updates) => updates.baitId = []);
        });

    replaceDatabaseWithCache();
    notifyOnAddOrUpdate();
  }

  void _onDeleteFishingSpot(FishingSpot fishingSpot) async {
    List<Catch>.from(list()
        .where((cat) => fishingSpot.id == cat.fishingSpotId))
        .forEach((cat) {
          entities[Id(cat.id)] =
              cat.copyWith((updates) => updates.fishingSpotId = []);
        });

    replaceDatabaseWithCache();
    notifyOnAddOrUpdate();
  }
}