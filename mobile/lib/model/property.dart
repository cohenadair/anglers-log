import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';
import 'package:quiver/strings.dart';

abstract class Mappable {
  Map<String, dynamic> toMap();
}

/// A [Property] represents a single element of an [Entity].
@immutable
abstract class Property {
  /// The column name in the local database.
  final String key;

  Property({
    @required this.key,
  }) : assert(isNotEmpty(key));

  @override
  bool operator ==(other) => other is Property && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

/// A [Property] subclass that stores a single value.
@immutable
class SingleProperty<T> extends Property {
  final T value;

  SingleProperty({
    @required String key,
    @required this.value,
  }) : super(key: key);

  @override
  bool operator ==(other) => super == other
      && other is SingleProperty<T>
      && value == other.value;

  @override
  int get hashCode => hash2(super.hashCode, value.hashCode);
}

/// A special [SingleProperty] subclass that represents a custom property
/// added by the user. The [key] property of this class represents the unique
/// ID of the [CustomEntity] associated with this property.
@immutable
class CustomProperty<T> extends SingleProperty<T> implements Mappable {
  CustomProperty({
    @required String key,
    @required T value,
  }) : super(key: key, value: value);

  Map<String, dynamic> toMap() => {
    key : value,
  };
}