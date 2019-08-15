import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

import 'field_type.dart';

/// A [Field] stores data backing [Input] widgets.
@immutable
class Field {
  static const String _keyId = "id";
  static const String _keyType = "type";

  final String id;
  final FieldType type;

  Field({
    @required this.id,
    @required this.type,
  }) : assert(id != null && id.isNotEmpty),
       assert(type != null);

  Field.fromMap(Map<String, dynamic> map)
      : id = map[_keyId],
        type = map[_keyType];

  @override
  bool operator ==(other) {
    return other is Field && other.id == id && other.type == type;
  }

  @override
  int get hashCode => hash2(id.hashCode, type.hashCode);

  Map<String, dynamic> get toMap => {
    _keyId: id,
    _keyType: type,
  };
}