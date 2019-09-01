import 'package:flutter/foundation.dart';
import 'package:mobile/model/property.dart';
import 'package:quiver/core.dart';
import 'package:uuid/uuid.dart';

/// An [Entity] stores a collection of manageable properties. An [Entity] is
/// designed to store business logic data only; nothing UI related.
///
/// This class should only be subclassed when a dynamic object is desired,
/// such as a Catch, or Bait.
@immutable
class Entity implements Mappable {
  static const _keyId = "id";
  static const _keyCustomProperties = "custom_properties";

  final String id;
  final Map<String, Property> _properties;

  Entity(List<Property> properties, {String id})
      : id = id ?? Uuid().v1(),
        _properties = Map.fromIterable(properties,
          key: (p) => (p as Property).key,
          value: (p) => p,
        );

  List<Property> get propertyList => List.unmodifiable(_properties.values);
  Property propertyWithName(String name) => _properties[name];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {};
    result[_keyId] = id;

    List<Property> customProperties = [];

    for (Property property in propertyList) {
      if (property is CustomProperty) {
        customProperties.add(property);
      } else if (property is Mappable) {
        result[property.key] = (property as Mappable).toMap();
      } else if (property is SingleProperty) {
        result[property.key] = property.value;
      }
    }

    result[_keyCustomProperties] = customProperties;
    return result;
  }

  @override
  bool operator ==(other) => other is Entity
      && id == other.id
      && listEquals(propertyList, other.propertyList);

  @override
  int get hashCode => hash2(id.hashCode, hashObjects(propertyList));
}