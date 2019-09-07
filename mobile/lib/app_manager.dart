import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/custom_field_manager.dart';
import 'package:mobile/trip_manager.dart';

class AppManager {
  BaitManager _baitManager;
  CatchManager _catchManager;
  CustomFieldManager _customFieldManager;
  TripManager _tripManager;

  BaitManager get baitManager => _baitManager ?? BaitManager();
  CatchManager get catchManager => _catchManager ?? CatchManager();
  CustomFieldManager get customFieldManager => _customFieldManager ?? CustomFieldManager();
  TripManager get tripManager => _tripManager ?? TripManager();
}