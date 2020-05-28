import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:provider/provider.dart';
import 'package:quiver/core.dart';
import 'package:quiver/strings.dart';

class CatchManager extends EntityManager<Catch> {
  static CatchManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).catchManager;

  CatchManager(AppManager app) : super(app) {
    app.baitManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteBait,
    ));
    app.fishingSpotManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteFishingSpot,
    ));
  }

  BaitManager get _baitManager => appManager.baitManager;
  FishingSpotManager get _fishingSpotManager => appManager.fishingSpotManager;
  ImageManager get _imageManager => appManager.imageManager;
  SpeciesManager get _speciesManager => appManager.speciesManager;

  /// Returns all catches, sorted from newest to oldest.
  List<Catch> catchesSortedByTimestamp(BuildContext context, {
    String filter,
  }) {
    List<Catch> result = List.of(filteredCatches(context, filter));
    result.sort((lhs, rhs) => rhs.timestamp.compareTo(lhs.timestamp));
    return result;
  }

  List<Catch> filteredCatches(BuildContext context, String filter) {
    if (isEmpty(filter)) {
      return entities.values.toList();
    }

    return entities.values.where((cat) => cat.matchesFilter(filter)
        || _speciesManager.entity(id: cat.speciesId).matchesFilter(filter)
        || (cat.hasFishingSpot && _fishingSpotManager
            .entity(id: cat.fishingSpotId).matchesFilter(filter))
        || (cat.hasBait && _baitManager.matchesFilter(cat.baitId, filter))
        || formatDateTime(context, cat.dateTime).toLowerCase()
            .contains(filter.toLowerCase())).toList();
  }

  @override
  Future<bool> addOrUpdate(Catch cat, {
    FishingSpot fishingSpot,
    List<File> imageFiles,
  }) async {
    // Update any catch dependencies first, so when catch listeners are
    // notified, all dependent data is updated as well.
    if (fishingSpot != null) {
      await _fishingSpotManager.addOrUpdate(fishingSpot);
    }

    await _imageManager.save(cat.id, imageFiles);
    return super.addOrUpdate(cat);
  }

  @override
  Catch entityFromMap(Map<String, dynamic> map) => Catch.fromMap(map);

  @override
  String get tableName => "catch";

  /// Returns true if a [Catch] with the given properties exists.
  bool existsWith({
    String speciesId,
  }) {
    return entityList.firstWhere((cat) => cat.speciesId == speciesId,
        orElse: () => null) != null;
  }

  String deleteMessage(BuildContext context, Catch cat) {
    if (cat == null) {
      return null;
    }

    Species species = _speciesManager.entity(id: cat.speciesId);
    String name = "${species.name} (${formatDateTime(context, cat.dateTime)})";
    return format(Strings.of(context).catchPageDeleteMessage, [name]);
  }

  void _onDeleteBait(Bait bait) async {
    // First, update database. If there are no affected catches, exit early.
    if (!await dataManager.rawUpdate(
        "UPDATE catch SET bait_id = null WHERE bait_id = ?",
        [bait.id]))
    {
      return;
    }

    // Then, update memory cache.
    List<Catch>.from(entityList
        .where((cat) => bait.id == cat.baitId))
        .forEach((cat) {
          entities[cat.id] = cat.copyWith(baitId: Optional.absent());
        });

    notifyOnAddOrUpdate();
  }

  void _onDeleteFishingSpot(FishingSpot fishingSpot) async {
    // First, update database. If there are no affected catches, exit early.
    if (!await dataManager.rawUpdate(
        "UPDATE catch SET fishing_spot_id = null WHERE fishing_spot_id = ?",
        [fishingSpot.id]))
    {
      return;
    }

    // Then, update memory cache.
    List<Catch>.from(entityList
        .where((cat) => fishingSpot.id == cat.fishingSpotId))
        .forEach((cat) {
          entities[cat.id] = cat.copyWith(fishingSpotId: Optional.absent());
        });

    notifyOnAddOrUpdate();
  }
}