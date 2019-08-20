import 'custom_field_manager.dart';

class AppManager {
  CustomFieldManager _customFieldManager;

  CustomFieldManager get customFieldManager {
    if (_customFieldManager == null) {
      _customFieldManager = CustomFieldManager();
    }
    return _customFieldManager;
  }
}