import 'package:meta/meta.dart';
import 'package:quiver/core.dart';
import 'package:uuid/uuid.dart';

import 'field.dart';
import 'field_type.dart';

/// A [CustomField] is a [Field] subclass used to store data for input fields
/// created by the user.
@immutable
class CustomField extends Field {
  static const String _keyName = "name";
  static const String _keyDescription = "description";

  final String name;
  final String description;

  CustomField({
    this.name,
    this.description,
    FieldType type,
  }) : super(
    id: Uuid().v1(),
    type: type,
  );

  CustomField.fromMap(Map<String, dynamic> map)
      : name = map[_keyName],
        description = map[_keyDescription],
        super.fromMap(map);

  @override
  bool operator ==(other) {
    return super == other
        && other.name == name
        && other.description == description;
  }

  @override
  int get hashCode =>
      hash3(super.hashCode, name.hashCode, description.hashCode);

  @override
  Map<String, dynamic> get toMap => super.toMap..addAll({
    _keyName: name,
    _keyDescription: description,
  });
}