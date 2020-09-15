import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/comparison_report_manager.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/summary_report_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/properties_manager.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:provider/provider.dart';

class AppManager {
  static AppManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false);

  BaitCategoryManager _baitCategoryManager;
  BaitManager _baitManager;
  DataManager _dataManager;
  CatchManager _catchManager;
  ComparisonReportManager _comparisonReportManager;
  CustomEntityManager _customEntityManager;
  SummaryReportManager _summaryReportManager;
  FishingSpotManager _fishingSpotManager;
  ImageManager _imageManager;
  LocationMonitor _locationMonitor;
  PreferencesManager _preferencesManager;
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

  ComparisonReportManager get customComparisonReportManager {
    if (_comparisonReportManager == null) {
      _comparisonReportManager = ComparisonReportManager(this);
    }
    return _comparisonReportManager;
  }

  CustomEntityManager get customEntityManager {
    if (_customEntityManager == null) {
      _customEntityManager = CustomEntityManager(this);
    }
    return _customEntityManager;
  }

  SummaryReportManager get customSummaryReportManager {
    if (_summaryReportManager == null) {
      _summaryReportManager = SummaryReportManager(this);
    }
    return _summaryReportManager;
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

  PreferencesManager get preferencesManager {
    if (_preferencesManager == null) {
      _preferencesManager = PreferencesManager(this);
    }
    return _preferencesManager;
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