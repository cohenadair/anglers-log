import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:provider/provider.dart';

class CatchManager extends EntityManager<Catch> {
  static CatchManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).catchManager;

  static CatchManager _instance;
  factory CatchManager.get(AppManager app) {
    if (_instance == null) {
      _instance = CatchManager._internal(app);
    }
    return _instance;
  }
  CatchManager._internal(AppManager app)
      : _fishingSpotManager = app.fishingSpotManager,
        _imageManager = app.imageManager,
        super(app);

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
}