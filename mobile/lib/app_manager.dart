import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/custom_field_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/properties_manager.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/trip_manager.dart';

class AppManager {
  BaitCategoryManager _baitCategoryManager;
  BaitManager _baitManager;
  DataManager _dataManager;
  CatchManager _catchManager;
  CustomFieldManager _customFieldManager;
  FishingSpotManager _fishingSpotManager;
  ImageManager _imageManager;
  LocationMonitor _locationMonitor;
  PropertiesManager _propertiesManager;
  SpeciesManager _speciesManager;
  TripManager _tripManager;

  BaitCategoryManager get baitCategoryManager {
    if (_baitCategoryManager == null) {
      _baitCategoryManager = BaitCategoryManager(this);
    }
    return _baitCategoryManager;
  }

  BaitManager get baitManager {
    if (_baitManager == null) {
      _baitManager = BaitManager(this);
    }
    return _baitManager;
  }

  DataManager get dataManager {
    if (_dataManager == null) {
      _dataManager = DataManager();
    }
    return _dataManager;
  }

  CatchManager get catchManager {
    if (_catchManager == null) {
      _catchManager = CatchManager(this);
    }
    return _catchManager;
  }

  CustomFieldManager get customFieldManager {
    if (_customFieldManager == null) {
      _customFieldManager = CustomFieldManager(this);
    }
    return _customFieldManager;
  }

  FishingSpotManager get fishingSpotManager {
    if (_fishingSpotManager == null) {
      _fishingSpotManager = FishingSpotManager(this);
    }
    return _fishingSpotManager;
  }

  ImageManager get imageManager {
    if (_imageManager == null) {
      _imageManager = ImageManager(this);
    }
    return _imageManager;
  }

  LocationMonitor get locationMonitor {
    if (_locationMonitor == null) {
      _locationMonitor = LocationMonitor();
    }
    return _locationMonitor;
  }

  PropertiesManager get propertiesManager {
    if (_propertiesManager == null) {
      _propertiesManager = PropertiesManager();
    }
    return _propertiesManager;
  }

  SpeciesManager get speciesManager {
    if (_speciesManager == null) {
      _speciesManager = SpeciesManager(this);
    }
    return _speciesManager;
  }

  TripManager get tripManager {
    if (_tripManager == null) {
      _tripManager = TripManager();
    }
    return _tripManager;
  }
}