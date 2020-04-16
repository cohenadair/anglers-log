import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mobile/model/named_entity.dart';
import 'package:mobile/model/property.dart';
import 'package:mobile/widgets/input_type.dart';
import 'package:quiver/strings.dart';

/// A [CustomEntity] is used to store data for input fields created by the user.
@immutable
class CustomEntity extends NamedEntity {
  static const String _keyDescription = "description";
  static const String _keyType = "type";

  CustomEntity({
    @required String name,
    String description,
    @required InputType type,
  }) : assert(isNotEmpty(name)),
       super(properties: [
         Property<String>(key: _keyDescription, value: description),
         Property<InputType>(key: _keyType, value: type),
       ], name: name);

  String get description =>
      (propertyWithName(_keyDescription) as Property<String>).value;

  InputType get type =>
      (propertyWithName(_keyType) as Property<InputType>).value;
}