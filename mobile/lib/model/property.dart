import 'package:flutter/foundation.dart';
import 'package:mobile/widgets/input.dart';
import 'package:quiver/core.dart';
import 'package:quiver/strings.dart';

abstract class Mappable {
  Map<String, dynamic> toMap();
}

/// A [Property] represents a single element of an [Entity]. A [Property] is
/// saved to the database and is restricted to the following types:
///   - int
///   - double
///   - String
///   - bool
///   - [InputType]
@immutable
class Property<T> {
  /// The column name in the local database.
  final String key;
  final T value;

  Property({
    @required this.key,
    @required this.value,
  }) : assert(isNotEmpty(key)),
       assert(value == null || value is int || value is double
           || value is String || value is bool || value is InputType);

  @override
  bool operator ==(other) => other is Property<T>
      && key == other.key
      && value == other.value;

  @override
  int get hashCode => hash2(key.hashCode, value.hashCode);
}

Map<String, Property> propertyListToMap(List<Property> list) =>
    Map.fromIterable(list,
      key: (p) => (p as Property).key,
      value: (p) => p,
    );