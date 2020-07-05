import 'package:flutter/foundation.dart';
import 'package:mobile/model/property.dart';
import 'package:quiver/core.dart';
import 'package:quiver/strings.dart';
import 'package:uuid/uuid.dart';

/// An [Entity] stores a collection of manageable properties. An [Entity] is
/// designed to store business logic data only; nothing UI related.
@immutable
class Entity {
  static const keyId = "id";

  static List<Property> _propertyList(String id) => [
    Property<String>(key: keyId, value: id, searchable: false),
  ];

  final Map<String, Property> _properties;

  Entity({
    List<Property> properties = const [],
    String id,
  }) : _properties = propertyListToMap(List<Property>.from(properties)
         ..addAll(_propertyList(id ?? Uuid().v1()))
       );

  Entity.fromMap(Map<String, dynamic> map, {
    List<Property> properties = const [],
  }) : assert(isNotEmpty(map[keyId])),
       _properties = propertyListToMap(List<Property>.from(properties)
         ..addAll(_propertyList(map[keyId])),
       );

  List<Property> get propertyList => List.unmodifiable(_properties.values);
  Property propertyWithName(String name) => _properties[name];

  String get id => (propertyWithName(keyId) as Property<String>).value;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {};
    for (Property property in propertyList) {
      result[property.key] = property.dbValue;
    }
    return result;
  }

  /// Returns true if any of the entity's properties contain the given
  /// [filter].
  bool matchesFilter(String filter) {
    if (isEmpty(filter)) {
      return true;
    }

    for (Property property in _properties.values) {
      // Don't include random ID in "searchable" properties.
      if (!property.searchable) {
        continue;
      }

      if (property.value.toString().toLowerCase()
          .contains(filter.toLowerCase()))
      {
        return true;
      }
    }
    return false;
  }

  @override
  bool operator ==(other) => other is Entity
      && listEquals(propertyList, other.propertyList);

  @override
  int get hashCode => hashObjects(propertyList);

  @override
  String toString() => toMap().toString();
}