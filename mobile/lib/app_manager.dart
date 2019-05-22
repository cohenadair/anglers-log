import 'package:mobile/auth_manager.dart';

class AppManager {
  AuthManager _authManager;

  AuthManager get authManager {
    if (_authManager == null) {
      _authManager = AuthManager();
    }
    return _authManager;
  }
}