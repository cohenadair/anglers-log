import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/custom_field_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/trip_manager.dart';

class AppManager {
  BaitManager get baitManager => BaitManager.get(this);
  DataManager get dataManager => DataManager.get();
  CatchManager get catchManager => CatchManager.get();
  CustomFieldManager get customFieldManager => CustomFieldManager.get();
  FishingSpotManager get fishingSpotManager => FishingSpotManager.get(this);
  LocationMonitor get locationMonitor => LocationMonitor.get();
  TripManager get tripManager => TripManager.get();
}