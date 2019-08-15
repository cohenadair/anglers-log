/// An [Entity] stores a collection of manageable properties. An [Entity] is
/// designed to store business logic data only; nothing UI related.
///
/// This class should only be subclassed when a dynamic object is desired,
/// such as a Catch, or Bait.
abstract class Entity {
  // Map keys outside dynamic properties.
  static const keyCustomFields = "customFields";

  final Map<String, dynamic> _properties;

  Entity() : _properties = Map();
  Entity.fromMap(Map<String, dynamic> map) : _properties = map;

  Map<String, dynamic> get properties => Map.from(_properties);
  Map<String, dynamic> get toMap => properties;

  /// Sets the property with the given [key], or overrides the value at [key]
  /// if it already exists. If `value` is `null`, this method does nothing.
  ///
  /// To clear a property, call [removeProperty].
  void setProperty({String key, dynamic value}) {
    if (value == null) {
      return;
    }
    _properties[key] = value;
  }

  void removeProperty({String key}) {
    if (!_properties.remove(key)) {
      print("Property with key $key does not exist in $_properties");
    }
  }

  /// Returns `null` if the property at `key` doesn't exist.
  dynamic property({String key}) => _properties[key];
  bool hasProperty({String key}) => _properties.containsKey(key);
}