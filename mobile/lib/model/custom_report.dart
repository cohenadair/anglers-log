import 'package:flutter/material.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/named_entity.dart';
import 'package:mobile/model/property.dart';
import 'package:mobile/model/report.dart';
import 'package:quiver/strings.dart';

// Do not change order of enum values as their ordinal number is recorded in the
// database.
enum CustomReportType {
  summary, comparison,
}

class CustomReport extends NamedEntity implements Report {
  static const _keyDescription = "description";
  static const _keyType = "type";
  static const _keyEntityType = "entity_type";

  static List<Property> _propertyList({
    @required String description,
    @required CustomReportType type,
    @required EntityType entityType,
  }) => [
    Property<String>(key: _keyDescription, value: description),
    Property<CustomReportType>(key: _keyType, value: type, searchable: false),
    Property<EntityType>(key: _keyEntityType, value: entityType,
        searchable: false),
  ];

  CustomReport({
    @required String name,
    String id,
    String description,
    @required CustomReportType type,
    @required EntityType entityType,
  }) : assert(isNotEmpty(name)),
       assert(type != null),
       assert(entityType != null),
       super(
         properties: _propertyList(
           description: description,
           type: type,
           entityType: entityType,
         ),
         id: id,
         name: name,
       );

  CustomReport.fromMap(Map<String, dynamic> map) : super.fromMap(map,
      properties: _propertyList(
        description: map[_keyDescription],
        type: map[_keyType],
        entityType: map[_keyEntityType],
      ));

  @override
  String title(BuildContext context) => super.name;

  String get description =>
      (propertyWithName(_keyDescription) as Property<String>).value;

  CustomReportType get type =>
      (propertyWithName(_keyType) as Property<CustomReportType>).value;

  EntityType get entityType =>
      (propertyWithName(_keyEntityType) as Property<EntityType>).value;
}