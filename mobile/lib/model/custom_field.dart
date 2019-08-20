import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:quiver/core.dart';
import 'package:uuid/uuid.dart';

import 'package:mobile/widgets/field_type.dart';

/// A [CustomField] is used to store data for input fields created by the user.
@immutable
class CustomField {
  static const String _keyId = "id";
  static const String _keyName = "name";
  static const String _keyDescription = "description";
  static const String _keyType = "type";

  final String id;
  final String name;
  final String description;
  final FieldType type;

  CustomField({
    this.name,
    this.description,
    this.type,
  }) : id = Uuid().v1();

  CustomField.fromMap(Map<String, dynamic> map)
      : id = map[_keyId],
        name = map[_keyName],
        description = map[_keyDescription],
        type = map[_keyType];

  @override
  bool operator ==(other) {
    return other is CustomField
        && other.id == id
        && other.name == name
        && other.description == description
        && other.type == type;
  }

  @override
  int get hashCode =>
      hash4(id.hashCode, name.hashCode, description.hashCode, type.hashCode);

  Map<String, dynamic> get toMap => {
    _keyId: id,
    _keyName: name,
    _keyDescription: description,
    _keyType: type,
  };
}