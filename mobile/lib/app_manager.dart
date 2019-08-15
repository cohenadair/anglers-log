import 'auth_manager.dart';
import 'custom_field_manager.dart';

class AppManager {
  CustomFieldManager _customFieldManager;
  AuthManager _authManager;

  CustomFieldManager get customFieldManager {
    if (_customFieldManager == null) {
      _customFieldManager = CustomFieldManager();
    }
    return _customFieldManager;
  }

  AuthManager get authManager {
    if (_authManager == null) {
      _authManager = AuthManager();
    }
    return _authManager;
  }
}