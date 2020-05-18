import 'package:flutter/material.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/property.dart';
import 'package:quiver/strings.dart';

/// A [NamedEntity] is an [Entity] subclass that includes a [name] property.
@immutable
class NamedEntity extends Entity {
  static const keyName = "name";

  static List<Property> _propertyList(String name, {
    List<Property> properties
  }) => (properties ?? [])..addAll([
    Property<String>(key: keyName, value: name),
  ]);

  NamedEntity({
    List<Property> properties,
    String name,
    String id,
  }) : super(
    properties: _propertyList(name, properties: properties),
    id: id,
  );

  NamedEntity.fromMap(Map<String, dynamic> map, {
    List<Property> properties,
  }) : super.fromMap(map, properties: _propertyList(map[keyName],
      properties: properties));

  String get name => (propertyWithName(keyName) as Property<String>)?.value;

  bool get hasName => isNotEmpty(name);

  int compareNameTo(NamedEntity other) {
    if (other == null) {
      return -1;
    }

    if (isNotEmpty(name) && isNotEmpty(other.name)) {
      return name.compareTo(other.name);
    } else if (isNotEmpty(name)) {
      return -1;
    } else if (isNotEmpty(other.name)) {
      return 1;
    } else {
      return 0;
    }
  }
}