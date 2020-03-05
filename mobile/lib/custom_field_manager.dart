import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:provider/provider.dart';

import 'model/custom_entity.dart';

class CustomFieldManager {
  static CustomFieldManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).customFieldManager;

  static final CustomFieldManager _instance = CustomFieldManager._internal();
  factory CustomFieldManager.get() => _instance;
  CustomFieldManager._internal();

  final Map<String, CustomEntity> _customFieldMap = {};

  List<CustomEntity> get customFields => 
      List.unmodifiable(_customFieldMap.values);

  Future<bool> nameExists(String name) {
    return Future.value(customFields.firstWhere((field) =>
        isEqualTrimmedLowercase(name, field.name), orElse: () => null) != null);
  }

  /// Returns the [CustomEntity] with the given ID, or `null` if none is found.
  CustomEntity customField(String id) {
    return _customFieldMap[id];
  }

  /// Returns the [CustomEntity] that was successfully added; or the
  /// [CustomEntity] instance if one already existed.
  CustomEntity addField(CustomEntity field) {
    return _customFieldMap.putIfAbsent(field.id, () => field);
  }
}