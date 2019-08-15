import 'model/custom_field.dart';

class CustomFieldManager {
  final Map<String, CustomField> _customFieldMap = {};

  List<CustomField> get customFields => 
      List.unmodifiable(_customFieldMap.values);

  CustomFieldManager();

  /// Returns the [CustomField] with the given ID, or `null` if none is found.
  CustomField customField(String id) {
    return _customFieldMap[id];
  }

  /// Returns the [CustomField] was successfully added; or the [CustomField]
  /// instance if one already existed.
  CustomField addField(CustomField field) {
    return _customFieldMap.putIfAbsent(field.id, () => field);
  }
}