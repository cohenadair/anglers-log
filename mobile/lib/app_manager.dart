import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/custom_field_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/trip_manager.dart';

class AppManager {
  BaitManager get baitManager => BaitManager.get();
  CatchManager get catchManager => CatchManager.get();
  CustomFieldManager get customFieldManager => CustomFieldManager.get();
  FishingSpotManager get fishingSpotManager => FishingSpotManager.get();
  TripManager get tripManager => TripManager.get();
}