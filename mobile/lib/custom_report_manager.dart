import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/model/custom_report_bait.dart';
import 'package:mobile/model/custom_report_fishing_spot.dart';
import 'package:mobile/model/custom_report_species.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:quiver/strings.dart';
import 'package:sqflite/sqflite.dart';

/// Manages all reports created by the user.
abstract class CustomReportManager<T extends CustomReport>
    extends NamedEntityManager<T>
{
  static const _tableCustomReportSpecies = "custom_report_species";
  static const _tableCustomReportBait = "custom_report_bait";
  static const _tableCustomReportFishingSpot = "custom_report_fishing_spot";

  final _species = _CustomReportEntityList<Species, T>(
    tableName: _tableCustomReportSpecies,
    customReportIdKey: CustomReportSpecies.keyCustomReportId,
    entityIdKey: CustomReportSpecies.keySpeciesId,
    mapBuilder: (reportId, valueId) => CustomReportSpecies(
      customReportId: reportId,
      speciesId: valueId,
    ).toMap(),
  );

  final _baits = _CustomReportEntityList<Bait, T>(
    tableName: _tableCustomReportBait,
    customReportIdKey: CustomReportBait.keyCustomReportId,
    entityIdKey: CustomReportBait.keyBaitId,
    mapBuilder: (reportId, valueId) => CustomReportBait(
      customReportId: reportId,
      baitId: valueId,
    ).toMap(),
  );

  final _fishingSpots = _CustomReportEntityList<FishingSpot, T>(
    tableName: _tableCustomReportFishingSpot,
    customReportIdKey: CustomReportFishingSpot.keyCustomReportId,
    entityIdKey: CustomReportFishingSpot.keyFishingSpotId,
    mapBuilder: (reportId, valueId) => CustomReportFishingSpot(
      customReportId: reportId,
      fishingSpotId: valueId,
    ).toMap(),
  );

  CustomReportManager(AppManager app) : super(app) {
    appManager.speciesManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteSpecies,
    ));
    appManager.baitManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteBait,
    ));
    appManager.fishingSpotManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteFishingSpot,
    ));
  }

  @override
  Future<void> clear() async {
    _species.clear();
    _baits.clear();
    _fishingSpots.clear();
    await super.clear();
  }

  @override
  Future<bool> addOrUpdate(T report, {
    Set<Species> species,
    Set<Bait> baits,
    Set<FishingSpot> fishingSpots,
    bool notify = true,
  }) async {
    // Update dependencies first, so when listeners are notified, all data is
    // available.
    await dataManager.commitBatch((batch) {
      _species.update(report, batch, species);
      _baits.update(report, batch, baits);
      _fishingSpots.update(report, batch, fishingSpots);
    });

    return super.addOrUpdate(report, notify: true);
  }

  Set<String> species({String id}) => _species.ids(reportId: id);
  Set<String> baits({String id}) => _baits.ids(reportId: id);
  Set<String> fishingSpots({String id}) => _fishingSpots.ids(reportId: id);

  void _onDeleteSpecies(Species species) async {
    if (await _species.onEntityDeleted(species, dataManager)) {
      notifyOnAddOrUpdate();
    }
  }

  void _onDeleteBait(Bait bait) async {
    if (await _baits.onEntityDeleted(bait, dataManager)) {
      notifyOnAddOrUpdate();
    }
  }

  void _onDeleteFishingSpot(FishingSpot fishingSpot) async {
    if (await _fishingSpots.onEntityDeleted(fishingSpot, dataManager)) {
      notifyOnAddOrUpdate();
    }
  }
}

class _CustomReportEntityList<E extends Entity, R extends CustomReport> {
  final String tableName;
  final String customReportIdKey;
  final String entityIdKey;
  final Map<String, dynamic>
      Function(String reportId, String valueId) mapBuilder;

  Map<String, Set<String>> _mapping = {};

  _CustomReportEntityList({
    @required this.tableName,
    @required this.customReportIdKey,
    @required this.entityIdKey,
    @required this.mapBuilder,
  });

  void update(R report, Batch batch, Set<E> values) {
    // First, remove old mappings.
    batch.delete(tableName,
      where: "$customReportIdKey = ?",
      whereArgs: [report.id],
    );
    _mapping[report.id] = {};

    // Then, add new mappings.
    if (values != null) {
      for (var value in values) {
        _mapping[report.id].add(value.id);
        batch.insert(tableName, mapBuilder(report.id, value.id));
      }
    }
  }

  /// Returns true of one or more mappings are deleted.
  Future<bool> onEntityDeleted(E entity, DataManager dataManager) async {
    return dataManager.delete(tableName,
      where: "$entityIdKey = ?",
      whereArgs: [entity.id],
    );
  }

  void clear() {
    _mapping.clear();
  }

  Set<String> ids({String reportId}) =>
      isEmpty(reportId) ? {} : _mapping[reportId];
}