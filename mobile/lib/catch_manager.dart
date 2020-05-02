import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:provider/provider.dart';
import 'package:quiver/core.dart';

class CatchManager extends EntityManager<Catch> {
  static CatchManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).catchManager;

  CatchManager(AppManager app)
      : _fishingSpotManager = app.fishingSpotManager,
        _imageManager = app.imageManager,
        super(app)
  {
    app.baitManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteBait,
    ));
    _fishingSpotManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteFishingSpot,
    ));
  }

  final FishingSpotManager _fishingSpotManager;
  final ImageManager _imageManager;

  /// Returns all catches, sorted from newest to oldest.
  List<Catch> get entityListSortedByTimestamp {
    List<Catch> result = List.of(entities.values);
    result.sort((lhs, rhs) => rhs.timestamp.compareTo(lhs.timestamp));
    return result;
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

    if (imageFiles != null && imageFiles.isNotEmpty) {
      await _imageManager.save(entityId: cat.id, files: imageFiles);
    }

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