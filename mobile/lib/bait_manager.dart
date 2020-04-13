import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/utils/future_stream_builder.dart';
import 'package:mobile/utils/void_stream_controller.dart';
import 'package:provider/provider.dart';

class BaitManager {
  static BaitManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).baitManager;

  static BaitManager _instance;
  factory BaitManager.get(AppManager app) {
    if (_instance == null) {
      _instance = BaitManager._internal(app);
    }
    return _instance;
  }
  BaitManager._internal(AppManager app) : _app = app;

  final String _baitTableName = "bait";
  final String _categoryTableName = "bait_category";

  final AppManager _app;
  final VoidStreamController onCategoryUpdate = VoidStreamController();
  final VoidStreamController onBaitUpdate = VoidStreamController();

  Future<int> get numberOfBaits => _app.dataManager.count(_baitTableName);

  Future<bool> categoryNameExists(String name) {
    return _app.dataManager.exists(_categoryTableName, "name", name);
  }

  void createOrUpdateCategory(BaitCategory baitCategory) async {
    _app.dataManager.insertOrUpdateEntity(baitCategory, _categoryTableName,
        controller: onCategoryUpdate);
  }

  void deleteCategory(BaitCategory baitCategory) async {
    List<dynamic> resultList = await _app.dataManager.commitBatch((batch) {
      batch.rawDelete("DELETE FROM $_categoryTableName WHERE id = ?",
          [baitCategory.id]);
      batch.rawUpdate(
          "UPDATE bait SET category_id = null WHERE category_id = ?",
          [baitCategory.id]);
    });

    if (resultList[0] > 0) {
      onCategoryUpdate.notify();
      if (resultList[1] > 0) {
        onBaitUpdate.notify();
      }
    }
  }

  Future<List<BaitCategory>> _fetchAllCategories() async {
    var results = await _app.dataManager.fetchAllEntities(_categoryTableName);
    return results.map((map) => BaitCategory.fromMap(map)).toList();
  }

  Future<BaitCategory> fetchCategory(String id) async {
    var result = await _app.dataManager.fetchEntity(_categoryTableName, id);
    return BaitCategory.fromMap(result);
  }

  Future<bool> baitExists(Bait bait) {
    return _app.dataManager.rawExists(
      "SELECT COUNT(*) FROM $_baitTableName "
          "WHERE category_id "
              + (bait.categoryId == null ? "IS NULL " : "= ? ")
          + "AND name = ? "
          + "AND color " + (bait.color == null ? "IS NULL " : "= ? ")
          + "AND model " + (bait.model == null ? "IS NULL " : "= ? ")
          + "AND type " + (bait.type == null ? "IS NULL " : "= ? ")
          + "AND min_dive_depth "
              + (bait.minDiveDepth == null ? "IS NULL " : "= ? ")
          + "AND max_dive_depth "
              + (bait.maxDiveDepth == null ? "IS NULL " : "= ? ")
          + "AND id != ?", []
      ..addAll(bait.categoryId == null ? [] : [bait.categoryId])
      ..add(bait.name)
      ..addAll(bait.color == null ? [] : [bait.color])
      ..addAll(bait.model == null ? [] : [bait.model])
      ..addAll(bait.type == null ? [] : [bait.type])
      ..addAll(bait.minDiveDepth == null ? [] : [bait.minDiveDepth])
      ..addAll(bait.maxDiveDepth == null ? [] : [bait.maxDiveDepth])
      ..add(bait.id),
    );
  }

  void createOrUpdateBait(Bait bait) async {
    _app.dataManager.insertOrUpdateEntity(bait, _baitTableName,
        controller: onBaitUpdate);
  }

  void deleteBait(Bait bait) async {
    _app.dataManager.deleteEntity(bait, _baitTableName,
        controller: onBaitUpdate);
  }

  Future<List<Bait>> _fetchAllBaits() async {
    var results = await _app.dataManager.fetchAllEntities(_baitTableName);
    return results.map((map) => Bait.fromMap(map)).toList();
  }

  Future<Bait> fetchBait(String id) async {
    var result = await _app.dataManager.fetchEntity(_baitTableName, id);
    return Bait.fromMap(result);
  }
}

/// A [FutureStreamHolder] subclass for [BaitCategory] objects meant to be used
/// with a [PickerPage].
class BaitCategoriesPickerFutureStreamHolder extends FutureStreamHolder {
  BaitCategoriesPickerFutureStreamHolder(BuildContext context, {
    BaitCategory Function() currentValue,
    void Function(List<BaitCategory>, BaitCategory) onUpdate,
  }) : super.entityPicker(
    futureCallback: BaitManager.of(context)._fetchAllCategories,
    stream: BaitManager.of(context).onCategoryUpdate.stream,
    currentValue: currentValue,
    onUpdate: (species, updatedSpecies) =>
        onUpdate(species as List<BaitCategory>, updatedSpecies as BaitCategory),
  );
}

/// A [FutureStreamBuilder] wrapper for listening for [BaitCategory] updates.
class BaitCategoriesBuilder extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  final void Function(List<BaitCategory>) onUpdate;

  BaitCategoriesBuilder({
    @required this.builder,
    @required this.onUpdate,
  }) : assert(builder != null);

  @override
  Widget build(BuildContext context) {
    return FutureStreamBuilder(
      holder: FutureStreamHolder.single(
        futureCallback: BaitManager.of(context)._fetchAllCategories,
        stream: BaitManager.of(context).onCategoryUpdate.stream,
        onUpdate: (result) => onUpdate(result as List<BaitCategory>),
      ),
      builder: (context) => builder(context),
    );
  }
}

class BaitsFutureStreamHolder extends FutureStreamHolder {
  BaitsFutureStreamHolder(BuildContext context, {
    void Function(List<Bait>, List<BaitCategory>) onUpdate,
  }) : super(
    futureCallbacks: [
      BaitManager.of(context)._fetchAllBaits,
      BaitManager.of(context)._fetchAllCategories,
    ],
    streams: [
      BaitManager.of(context).onBaitUpdate.stream,
      BaitManager.of(context).onCategoryUpdate.stream,
    ],
    onUpdate: (result) =>
        onUpdate(result[0] as List<Bait>, result[1] as List<BaitCategory>),
  );
}
/// A [FutureStreamBuilder] wrapper for listening for [Bait] updates.
class BaitsBuilder extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  final void Function(List<Bait>, List<BaitCategory>) onUpdate;

  BaitsBuilder({
    @required this.builder,
    @required this.onUpdate,
  }) : assert(builder != null);

  @override
  Widget build(BuildContext context) {
    return FutureStreamBuilder(
      holder: BaitsFutureStreamHolder(context, onUpdate: onUpdate),
      builder: (context) => builder(context),
    );
  }
}