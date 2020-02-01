import 'package:flutter/foundation.dart';
import 'package:mobile/model/property.dart';
import 'package:quiver/core.dart';
import 'package:quiver/strings.dart';
import 'package:uuid/uuid.dart';

/// An [Entity] stores a collection of manageable properties. An [Entity] is
/// designed to store business logic data only; nothing UI related.
@immutable
class Entity implements Mappable {
  static const keyId = "id";
  static const keyName = "name";

  static List<Property> _propertyList(String id, String name) => [
    Property<String>(key: keyId, value: id),
    Property<String>(key: keyName, value: name),
  ];

  final Map<String, Property> _properties;

  Entity({
    List<Property> properties = const [],
    String id,
    String name,
  }) : _properties = propertyListToMap(List<Property>.from(properties)
         ..addAll(_propertyList(id ?? Uuid().v1(), name))
       );

  Entity.fromMap(Map<String, dynamic> map, {
    List<Property> properties = const [],
  }) : assert(isNotEmpty(map[keyId])),
       _properties = propertyListToMap(List<Property>.from(properties)
         ..addAll(_propertyList(map[keyId], map[keyName])),
       );

  List<Property> get propertyList => List.unmodifiable(_properties.values);
  Property propertyWithName(String name) => _properties[name];

  String get id => (propertyWithName(keyId) as Property<String>).value;
  String get name => (propertyWithName(keyName) as Property<String>)?.value;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {};
    for (Property property in propertyList) {
      result[property.key] = property.value;
    }
    return result;
  }

  @override
  bool operator ==(other) => other is Entity
      && listEquals(propertyList, other.propertyList);

  @override
  int get hashCode => hashObjects(propertyList);

  @override
  String toString() => toMap().toString();
}