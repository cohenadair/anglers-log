import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/model/custom_entity_value.dart';
import 'package:mobile/model/entity.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

/// Manages the values of [CustomEntity] objects, such as when included in a
/// [Catch] or [Bait].
class CustomEntityValueManager {
  static CustomEntityValueManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).customEntityValueManager;

  static const _tableName = "custom_entity_value";

  final AppManager _appManager;

  /// A map of [Entity] ID to [CustomEntityValue] objects.
  final Map<String, List<CustomEntityValue>> _customEntityMap = {};

  CustomEntityValueManager(this._appManager) {
    _appManager.baitManager.addListener(SimpleEntityListener(
      onDelete: (bait) => _deleteEntityValues(bait, EntityType.bait),
    ));
    _appManager.catchManager.addListener(SimpleEntityListener(
      onDelete: (cat) => _deleteEntityValues(cat, EntityType.fishCatch),
    ));
    _appManager.customEntityManager.addListener(SimpleEntityListener(
      onDelete: _deleteCustomEntityValues,
    ));
    _dataManager.addListener(DataListener(
      onReset: _clear,
    ));
  }

  DataManager get _dataManager => _appManager.dataManager;

  Future<void> initialize() async {
    (await _dataManager.fetchAll(_tableName)).forEach((row) {
      var value = CustomEntityValue.fromMap(row);
      if (!_customEntityMap.containsKey(value.entityId)) {
        _customEntityMap.putIfAbsent(value.entityId, () => []);
      }
      _customEntityMap[value.entityId].add(value);
    });
  }

  /// Clears the [Entity] memory collection. This method assumes the database
  /// has already been cleared.
  Future<void> _clear() async {
    _customEntityMap.clear();
    await initialize();
  }

  /// Replaces all [CustomEntityValue] rows for the [Entity] with [entityId],
  /// with [values].
  Future<void> setValues(String entityId, List<CustomEntityValue> values)
      async
  {
    await _dataManager.commitBatch((batch) {
      // Delete all old rows.
      batch.delete(_tableName,
        where: "${CustomEntityValue.keyEntityId} = ?",
        whereArgs: [entityId],
      );

      // Insert new rows.
      values.forEach((value) => batch.insert(_tableName, value.toMap()));
    });

    _customEntityMap[entityId] = values;
  }

  List<CustomEntityValue> values({
    @required String entityId,
  }) {
    if (isEmpty(entityId)) {
      return [];
    }
    return _customEntityMap[entityId] ?? [];
  }

  /// Returns the total number of [CustomEntityValue] objects associated with
  /// [Bait] objects and [customEntityId].
  int baitValueCount(String customEntityId) =>
      _entityValueCount(customEntityId, (value) =>
          value.entityType == EntityType.bait);

  /// Returns the total number of [CustomEntityValue] objects associated with
  /// [Catch] objects and [customEntityId].
  int catchValueCount(String customEntityId) =>
      _entityValueCount(customEntityId, (value) =>
          value.entityType == EntityType.fishCatch);

  /// Returns the total number of [CustomEntityValue] objects associated with
  /// [customEntityId] where [counts] returns true.
  int _entityValueCount(String customEntityId,
      bool Function(CustomEntityValue) counts)
  {
    int result = 0;

    for (var values in _customEntityMap.values) {
      for (var value in values) {
        if (counts(value) && value.customEntityId == customEntityId) {
          result++;
        }
      }
    }

    return result;
  }

  /// Deletes all custom entity values from the database where the entity ID
  /// matches the given ID.
  void _deleteEntityValues(Entity entity, EntityType entityType) {
    _dataManager.delete(_tableName,
      where: "${CustomEntityValue.keyEntityId} = ? "
          "AND ${CustomEntityValue.keyEntityType} = ?",
      whereArgs: [entity.id, entityType.index],
    );

    _customEntityMap.remove(entity.id);
  }

  /// Deletes all custom entity values from the database where the custom entity
  /// ID matches the given ID.
  void _deleteCustomEntityValues(CustomEntity customEntity) {
    _dataManager.delete(_tableName,
      where: "${CustomEntityValue.keyCustomEntityId} = ?",
      whereArgs: [customEntity.id],
    );

    for (List<CustomEntityValue> values in _customEntityMap.values) {
      values.removeWhere((value) => value.customEntityId == customEntity.id);
    }
  }
}