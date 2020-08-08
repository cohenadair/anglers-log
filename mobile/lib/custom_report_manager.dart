import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/model/custom_report_bait.dart';
import 'package:mobile/model/custom_report_fishing_spot.dart';
import 'package:mobile/model/custom_report_species.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/one-to-many-row.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:mobile/species_manager.dart';
import 'package:quiver/strings.dart';
import 'package:sqflite/sqflite.dart';

/// Manages all reports created by the user.
abstract class CustomReportManager<T extends CustomReport>
    extends NamedEntityManager<T>
{
  final BaitManager _baitManager;
  final FishingSpotManager _fishingSpotManager;
  final SpeciesManager _speciesManager;

  final _baits = _CustomReportBaitList<T>();
  final _fishingSpots = _CustomReportFishingSpotList<T>();
  final _species = _CustomReportSpeciesList<T>();

  CustomReportManager(AppManager app)
      : _baitManager = app.baitManager,
        _fishingSpotManager = app.fishingSpotManager,
        _speciesManager = app.speciesManager,
        super(app)
  {
    _baitManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteBait,
    ));
    _fishingSpotManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteFishingSpot,
    ));
    _speciesManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteSpecies,
    ));
  }

  @override
  Future<void> initialize() async {
    await _baits.load(dataManager);
    await _fishingSpots.load(dataManager);
    await _species.load(dataManager);
    await super.initialize();
  }

  @override
  Future<void> clear() async {
    _baits.clear();
    _fishingSpots.clear();
    _species.clear();
    await super.clear();
  }

  @override
  Future<bool> addOrUpdate(T report, {
    Set<Bait> baits,
    Set<FishingSpot> fishingSpots,
    Set<Species> species,
    bool notify = true,
  }) async {
    // Update dependencies first, so when listeners are notified, all data is
    // available.
    await dataManager.commitBatch((batch) {
      _baits.update(report, batch, baits);
      _fishingSpots.update(report, batch, fishingSpots);
      _species.update(report, batch, species);
    });

    return super.addOrUpdate(report, notify: true);
  }

  Set<String> baitIds(String reportId) =>
      _baits.ids(reportId: reportId).toSet();
  List<Bait> baits(String reportId) =>
      _baits.ids(reportId: reportId).map((baitId) =>
          _baitManager.entity(id: baitId)).toList();

  Set<String> fishingSpotIds(String reportId) =>
      _fishingSpots.ids(reportId: reportId).toSet();
  List<FishingSpot> fishingSpots(String reportId) =>
      _fishingSpots.ids(reportId: reportId).map((fishingSpotId) =>
          _fishingSpotManager.entity(id: fishingSpotId)).toList();

  Set<String> speciesIds(String reportId) =>
      _species.ids(reportId: reportId).toSet();
  List<Species> species(String reportId) =>
      _species.ids(reportId: reportId).map((speciesId) =>
          _speciesManager.entity(id: speciesId)).toList();

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

  void _onDeleteSpecies(Species species) async {
    if (await _species.onEntityDeleted(species, dataManager)) {
      notifyOnAddOrUpdate();
    }
  }
}

abstract class _CustomReportEntityList<E extends Entity, M extends OneToManyRow,
    R extends CustomReport> 
{
  String get tableName;
  String get customReportIdKey;
  String get entityIdKey;
  Map<String, dynamic> itemToMap(String reportId, String valueId);
  M mapToItem(Map<String, dynamic> map);
  String customReportId(M item);
  String entityId(M item);

  Map<String, Set<String>> _mapping = {};
  
  Future<void> load(DataManager dataManager) async {
    _mapping.clear();

    (await dataManager.fetchAll(tableName))
        .map((map) => mapToItem(map))
        .forEach((item) {
          String reportId = customReportId(item);
          if (_mapping[reportId] == null) {
            _mapping[reportId] = {};
          }
          _mapping[reportId].add(entityId(item));
        });
  }

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
        batch.insert(tableName, itemToMap(report.id, value.id));
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
      isEmpty(reportId) ? {} : _mapping[reportId] ?? {};
}

class _CustomReportBaitList<T extends CustomReport>
    extends _CustomReportEntityList<Bait, CustomReportBait, T>
{
  @override
  String get tableName => "custom_report_bait";

  @override
  String get customReportIdKey => CustomReportBait.keyCustomReportId;

  @override
  String get entityIdKey => CustomReportBait.keyBaitId;

  @override
  Map<String, dynamic> itemToMap(String reportId, String valueId) {
    return CustomReportBait(
      customReportId: reportId,
      baitId: valueId,
    ).toMap();
  }

  @override
  CustomReportBait mapToItem(Map<String, dynamic> map) =>
      CustomReportBait.fromMap(map);

  @override
  String customReportId(CustomReportBait reportBait) =>
      reportBait.customReportId;

  @override
  String entityId(CustomReportBait reportBait) => reportBait.baitId;
}

class _CustomReportFishingSpotList<T extends CustomReport>
    extends _CustomReportEntityList<FishingSpot, CustomReportFishingSpot, T>
{
  @override
  String get tableName => "custom_report_fishing_spot";

  @override
  String get customReportIdKey => CustomReportFishingSpot.keyCustomReportId;

  @override
  String get entityIdKey => CustomReportFishingSpot.keyFishingSpotId;

  @override
  Map<String, dynamic> itemToMap(String reportId, String valueId) {
    return CustomReportFishingSpot(
      customReportId: reportId,
      fishingSpotId: valueId,
    ).toMap();
  }

  @override
  CustomReportFishingSpot mapToItem(Map<String, dynamic> map) =>
      CustomReportFishingSpot.fromMap(map);

  @override
  String customReportId(CustomReportFishingSpot reportFishingSpot) =>
      reportFishingSpot.customReportId;

  @override
  String entityId(CustomReportFishingSpot reportFishingSpot) =>
      reportFishingSpot.fishingSpotId;
}

class _CustomReportSpeciesList<T extends CustomReport>
    extends _CustomReportEntityList<Species, CustomReportSpecies, T>
{
  @override
  String get tableName => "custom_report_species";

  @override
  String get customReportIdKey => CustomReportSpecies.keyCustomReportId;

  @override
  String get entityIdKey => CustomReportSpecies.keySpeciesId;

  @override
  Map<String, dynamic> itemToMap(String reportId, String valueId) {
    return CustomReportSpecies(
      customReportId: reportId,
      speciesId: valueId,
    ).toMap();
  }

  @override
  CustomReportSpecies mapToItem(Map<String, dynamic> map) =>
      CustomReportSpecies.fromMap(map);

  @override
  String customReportId(CustomReportSpecies reportSpecies) =>
      reportSpecies.customReportId;

  @override
  String entityId(CustomReportSpecies reportSpecies) => reportSpecies.speciesId;
}