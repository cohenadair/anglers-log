import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bait_category_manager.dart';
import 'bait_manager.dart';
import 'catch_manager.dart';
import 'comparison_report_manager.dart';
import 'custom_entity_manager.dart';
import 'data_manager.dart';
import 'fishing_spot_manager.dart';
import 'image_manager.dart';
import 'location_monitor.dart';
import 'preferences_manager.dart';
import 'properties_manager.dart';
import 'species_manager.dart';
import 'summary_report_manager.dart';
import 'time_manager.dart';
import 'trip_manager.dart';
import 'wrappers/file_picker_wrapper.dart';
import 'wrappers/image_compress_wrapper.dart';
import 'wrappers/image_picker_wrapper.dart';
import 'wrappers/io_wrapper.dart';
import 'wrappers/mail_sender_wrapper.dart';
import 'wrappers/package_info_wrapper.dart';
import 'wrappers/path_provider_wrapper.dart';
import 'wrappers/permission_handler_wrapper.dart';
import 'wrappers/photo_manager_wrapper.dart';
import 'wrappers/url_launcher_wrapper.dart';

class AppManager {
  static AppManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false);

  // Internal dependencies.
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
  TimeManager _timeManager;
  TripManager _tripManager;

  // External dependency wrappers.
  FilePickerWrapper _filePickerWrapper;
  ImageCompressWrapper _imageCompressWrapper;
  ImagePickerWrapper _imagePickerWrapper;
  IoWrapper _ioWrapper;
  MailSenderWrapper _mailSenderWrapper;
  PackageInfoWrapper _packageInfoWrapper;
  PathProviderWrapper _pathProviderWrapper;
  PermissionHandlerWrapper _permissionHandlerWrapper;
  PhotoManagerWrapper _photoManagerWrapper;
  UrlLauncherWrapper _urlLauncherWrapper;

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

  ComparisonReportManager get comparisonReportManager {
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
      _locationMonitor = LocationMonitor(this);
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

  SummaryReportManager get summaryReportManager {
    if (_summaryReportManager == null) {
      _summaryReportManager = SummaryReportManager(this);
    }
    return _summaryReportManager;
  }

  TimeManager get timeManager {
    if (_timeManager == null) {
      _timeManager = TimeManager();
    }
    return _timeManager;
  }

  TripManager get tripManager {
    if (_tripManager == null) {
      _tripManager = TripManager();
    }
    return _tripManager;
  }

  IoWrapper get ioWrapper {
    if (_ioWrapper == null) {
      _ioWrapper = IoWrapper();
    }
    return _ioWrapper;
  }

  FilePickerWrapper get filePickerWrapper {
    if (_filePickerWrapper == null) {
      _filePickerWrapper = FilePickerWrapper();
    }
    return _filePickerWrapper;
  }

  ImageCompressWrapper get imageCompressWrapper {
    if (_imageCompressWrapper == null) {
      _imageCompressWrapper = ImageCompressWrapper();
    }
    return _imageCompressWrapper;
  }

  ImagePickerWrapper get imagePickerWrapper {
    if (_imagePickerWrapper == null) {
      _imagePickerWrapper = ImagePickerWrapper();
    }
    return _imagePickerWrapper;
  }

  MailSenderWrapper get mailSenderWrapper {
    if (_mailSenderWrapper == null) {
      _mailSenderWrapper = MailSenderWrapper();
    }
    return _mailSenderWrapper;
  }

  PackageInfoWrapper get packageInfoWrapper {
    if (_packageInfoWrapper == null) {
      _packageInfoWrapper = PackageInfoWrapper();
    }
    return _packageInfoWrapper;
  }

  PathProviderWrapper get pathProviderWrapper {
    if (_pathProviderWrapper == null) {
      _pathProviderWrapper = PathProviderWrapper();
    }
    return _pathProviderWrapper;
  }

  PermissionHandlerWrapper get permissionHandlerWrapper {
    if (_permissionHandlerWrapper == null) {
      _permissionHandlerWrapper = PermissionHandlerWrapper();
    }
    return _permissionHandlerWrapper;
  }

  PhotoManagerWrapper get photoManagerWrapper {
    if (_photoManagerWrapper == null) {
      _photoManagerWrapper = PhotoManagerWrapper();
    }
    return _photoManagerWrapper;
  }

  UrlLauncherWrapper get urlLauncherWrapper {
    if (_urlLauncherWrapper == null) {
      _urlLauncherWrapper = UrlLauncherWrapper();
    }
    return _urlLauncherWrapper;
  }
}
