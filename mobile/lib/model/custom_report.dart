import 'package:flutter/material.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/named_entity.dart';
import 'package:mobile/model/property.dart';
import 'package:mobile/model/report.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:quiver/strings.dart';

enum CustomReportType {
  summary, comparison,
}

abstract class CustomReport extends NamedEntity implements Report {
  static const keyDescription = "description";
  static const keyEntityType = "entity_type";

  static List<Property> _propertyList({
    @required String description,
    @required EntityType entityType,
    List<Property> properties,
  }) => (properties ?? [])..addAll([
    Property<String>(key: keyDescription, value: description),
    Property<EntityType>(key: keyEntityType, value: entityType,
        searchable: false),
  ]);

  CustomReportType get type;

  CustomReport({
    List<Property> properties,
    @required String name,
    String id,
    String description,
    @required EntityType entityType,
  }) : assert(isNotEmpty(name)),
       assert(entityType != null),
       super(
         properties: _propertyList(
           description: description,
           entityType: entityType,
           properties: properties,
         ),
         id: id,
         name: name,
       );

  CustomReport.fromMap(Map<String, dynamic> map, {
    List<Property> properties,
  }) : super.fromMap(map, properties: _propertyList(
    description: map[keyDescription],
    entityType: valueOf<EntityType>(EntityType.values, map[keyEntityType]),
    properties: properties,
  ));

  @override
  String title(BuildContext context) => super.name;

  @override
  bool get custom => true;

  bool get hasDescription => isNotEmpty(description);

  String get description =>
      (propertyWithName(keyDescription) as Property<String>).value;

  EntityType get entityType =>
      (propertyWithName(keyEntityType) as Property<EntityType>).value;
}