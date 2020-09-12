import 'package:collection/collection.dart';
import 'package:quiver/strings.dart';
import 'package:uuid/uuid.dart';

/// A class representing a unique ID. An [Id] is a wrapper for [Uuid] byte
/// representation of [List<int>] that can be used as keys in a [Map], since
/// [List==] does not do a deep comparison of its elements.
class Id {
  static Set<Id> fromByteList(List<List<int>> byteList) =>
      byteList.map((bytes) => Id(bytes)).toSet();

  static List<List<int>> toByteList(Set<Id> ids) =>
      ids.map((id) => id.bytes).toList();

  List<int> _bytes;

  Id(this._bytes) {
    // Uuid.unparse will throw range exceptions if trying to decode an invalid
    // UUID.
    try {
      Uuid().unparse(bytes);
    } catch (e) {
      throw ArgumentError("Id must be created with valid UUID bytes");
    }
  }

  Id.random() : this(Uuid().parse(Uuid().v1()).toList());

  Id.parse(String id) : assert(isNotEmpty(id)) {
    // Uuid.parse will return NAMESPACE_NIL for invalid UUID strings.
    _bytes = Uuid().parse(id);
    if (toString() == Uuid.NAMESPACE_NIL) {
      throw ArgumentError("Input must be valid UUID string");
    }
  }

  List<int> get bytes => _bytes;

  @override
  String toString() => Uuid().unparse(bytes).toString();

  @override
  bool operator ==(Object other) =>
      other is Id && ListEquality().equals(bytes, other.bytes);

  @override
  int get hashCode => ListEquality().hash(bytes);
}