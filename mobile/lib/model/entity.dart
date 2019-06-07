import 'package:meta/meta.dart';

/// An [Entity] stores a collection of manageable properties.
@immutable
abstract class Entity {
  final Map<String, dynamic> _properties;

  Entity() : _properties = Map();
  Entity.fromMap(Map<String, dynamic> map) : _properties = map;

  Map<String, dynamic> get properties => Map.from(_properties);
  Map<String, dynamic> get toMap => properties;

  /// Sets the property with the given [key], or overrides the value at [key]
  /// if it already exists.
  void setProperty({String key, dynamic value}) {
    _properties[key] = value;
  }

  void removeProperty({String key}) {
    if (!_properties.remove(key)) {
      print("Property with key $key does not exist in $_properties");
    }
  }

  dynamic getProperty({String key}) => _properties[key];
}