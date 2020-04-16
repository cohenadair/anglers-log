import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/property.dart';

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
}