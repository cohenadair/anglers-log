import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/custom_field_manager.dart';
import 'package:mobile/trip_manager.dart';

class AppManager {
  BaitManager _baitManager;
  CatchManager _catchManager;
  CustomFieldManager _customFieldManager;
  TripManager _tripManager;

  BaitManager get baitManager {
    if (_baitManager == null) {
      _baitManager = BaitManager();
    }
    return _baitManager;
  }

  CatchManager get catchManager {
    if (_catchManager == null) {
      _catchManager = CatchManager();
    }
    return _catchManager;
  }

  CustomFieldManager get customFieldManager {
    if (_customFieldManager == null) {
      _customFieldManager = CustomFieldManager();
    }
    return _customFieldManager;
  }

  TripManager get tripManager {
    if (_tripManager == null) {
      _tripManager = TripManager();
    }
    return _tripManager;
  }
}