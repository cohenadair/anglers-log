import 'package:adair_flutter_lib/adair_flutter_lib.dart';
import 'package:flutter/material.dart';
import 'package:mobile/gps_trail_manager.dart';
import 'package:mobile/poll_manager.dart';
import 'package:mobile/region_manager.dart';
import 'package:mobile/wrappers/csv_wrapper.dart';
import 'package:mobile/wrappers/exif_wrapper.dart';
import 'package:mobile/wrappers/geolocator_wrapper.dart';
import 'package:mobile/wrappers/google_sign_in_wrapper.dart';

import 'angler_manager.dart';
import 'backup_restore_manager.dart';
import 'bait_category_manager.dart';
import 'bait_manager.dart';
import 'body_of_water_manager.dart';
import 'catch_manager.dart';
import 'custom_entity_manager.dart';
import 'fishing_spot_manager.dart';
import 'gear_manager.dart';
import 'image_manager.dart';
import 'local_database_manager.dart';
import 'location_monitor.dart';
import 'method_manager.dart';
import 'notification_manager.dart';
import 'report_manager.dart';
import 'species_manager.dart';
import 'trip_manager.dart';
import 'user_preference_manager.dart';
import 'water_clarity_manager.dart';
import 'wrappers/drive_api_wrapper.dart';
import 'wrappers/file_picker_wrapper.dart';
import 'wrappers/http_wrapper.dart';
import 'wrappers/image_compress_wrapper.dart';
import 'wrappers/image_picker_wrapper.dart';
import 'wrappers/in_app_review_wrapper.dart';
import 'wrappers/isolates_wrapper.dart';
import 'wrappers/package_info_wrapper.dart';
import 'wrappers/path_provider_wrapper.dart';
import 'wrappers/photo_manager_wrapper.dart';
import 'wrappers/services_wrapper.dart';
import 'wrappers/share_plus_wrapper.dart';
import 'wrappers/shared_preferences_wrapper.dart';
import 'wrappers/url_launcher_wrapper.dart';

class AppManager {
  static var _instance = AppManager._();

  static AppManager get get => _instance;

  @visibleForTesting
  static void set(AppManager manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = AppManager._();

  AppManager._();

  // TODO: Remove when all managers have been converted to singletons.
  @visibleForTesting
  AppManager();

  // Internal dependencies.
  AnglerManager? _anglerManager;
  BackupRestoreManager? _backupRestoreManager;
  BaitCategoryManager? _baitCategoryManager;
  BaitManager? _baitManager;
  BodyOfWaterManager? _bodyOfWaterManager;
  CatchManager? _catchManager;
  CustomEntityManager? _customEntityManager;
  FishingSpotManager? _fishingSpotManager;
  GearManager? _gearManager;
  GpsTrailManager? _gpsTrailManager;
  ImageManager? _imageManager;
  LocationMonitor? _locationMonitor;
  MethodManager? _methodManager;
  NotificationManager? _notificationManager;
  ReportManager? _reportManager;
  SpeciesManager? _speciesManager;
  TripManager? _tripManager;
  WaterClarityManager? _waterClarityManager;

  // External dependency wrappers.
  CsvWrapper? _csvWrapper;
  DriveApiWrapper? _driveApiWrapper;
  ExifWrapper? _exifWrapper;
  FilePickerWrapper? _filePickerWrapper;
  GeolocatorWrapper? _geolocatorWrapper;
  GoogleSignInWrapper? _googleSignInWrapper;
  HttpWrapper? _httpWrapper;
  ImageCompressWrapper? _imageCompressWrapper;
  ImagePickerWrapper? _imagePickerWrapper;
  InAppReviewWrapper? _inAppReviewWrapper;
  IsolatesWrapper? _isolatesWrapper;
  PackageInfoWrapper? _packageInfoWrapper;
  PathProviderWrapper? _pathProviderWrapper;
  PhotoManagerWrapper? _photoManagerWrapper;
  ServicesWrapper? _servicesWrapper;
  SharedPreferencesWrapper? _sharedPreferencesWrapper;
  SharePlusWrapper? _sharePlusWrapper;
  UrlLauncherWrapper? _urlLauncherWrapper;

  AnglerManager get anglerManager {
    _anglerManager ??= AnglerManager(this);
    return _anglerManager!;
  }

  BackupRestoreManager get backupRestoreManager {
    _backupRestoreManager ??= BackupRestoreManager();
    return _backupRestoreManager!;
  }

  BaitCategoryManager get baitCategoryManager {
    _baitCategoryManager ??= BaitCategoryManager(this);
    return _baitCategoryManager!;
  }

  BaitManager get baitManager {
    _baitManager ??= BaitManager(this);
    return _baitManager!;
  }

  BodyOfWaterManager get bodyOfWaterManager {
    _bodyOfWaterManager ??= BodyOfWaterManager(this);
    return _bodyOfWaterManager!;
  }

  CatchManager get catchManager {
    _catchManager ??= CatchManager(this);
    return _catchManager!;
  }

  CustomEntityManager get customEntityManager {
    _customEntityManager ??= CustomEntityManager(this);
    return _customEntityManager!;
  }

  FishingSpotManager get fishingSpotManager {
    _fishingSpotManager ??= FishingSpotManager(this);
    return _fishingSpotManager!;
  }

  GearManager get gearManager {
    _gearManager ??= GearManager(this);
    return _gearManager!;
  }

  GpsTrailManager get gpsTrailManager {
    _gpsTrailManager ??= GpsTrailManager(this);
    return _gpsTrailManager!;
  }

  ImageManager get imageManager {
    _imageManager ??= ImageManager(this);
    return _imageManager!;
  }

  LocationMonitor get locationMonitor {
    _locationMonitor ??= LocationMonitor(this);
    return _locationMonitor!;
  }

  MethodManager get methodManager {
    _methodManager ??= MethodManager(this);
    return _methodManager!;
  }

  NotificationManager get notificationManager {
    _notificationManager ??= NotificationManager(this);
    return _notificationManager!;
  }

  ReportManager get reportManager {
    _reportManager ??= ReportManager(this);
    return _reportManager!;
  }

  SpeciesManager get speciesManager {
    _speciesManager ??= SpeciesManager(this);
    return _speciesManager!;
  }

  TripManager get tripManager {
    _tripManager ??= TripManager(this);
    return _tripManager!;
  }

  WaterClarityManager get waterClarityManager {
    _waterClarityManager ??= WaterClarityManager(this);
    return _waterClarityManager!;
  }

  CsvWrapper get csvWrapper {
    _csvWrapper ??= const CsvWrapper();
    return _csvWrapper!;
  }

  DriveApiWrapper get driveApiWrapper {
    _driveApiWrapper ??= DriveApiWrapper();
    return _driveApiWrapper!;
  }

  ExifWrapper get exifWrapper {
    _exifWrapper ??= ExifWrapper();
    return _exifWrapper!;
  }

  GeolocatorWrapper get geolocatorWrapper {
    _geolocatorWrapper ??= GeolocatorWrapper();
    return _geolocatorWrapper!;
  }

  FilePickerWrapper get filePickerWrapper {
    _filePickerWrapper ??= FilePickerWrapper();
    return _filePickerWrapper!;
  }

  GoogleSignInWrapper get googleSignInWrapper {
    _googleSignInWrapper ??= GoogleSignInWrapper();
    return _googleSignInWrapper!;
  }

  HttpWrapper get httpWrapper {
    _httpWrapper ??= HttpWrapper();
    return _httpWrapper!;
  }

  ImageCompressWrapper get imageCompressWrapper {
    _imageCompressWrapper ??= ImageCompressWrapper();
    return _imageCompressWrapper!;
  }

  ImagePickerWrapper get imagePickerWrapper {
    _imagePickerWrapper ??= ImagePickerWrapper();
    return _imagePickerWrapper!;
  }

  InAppReviewWrapper get inAppReviewWrapper {
    _inAppReviewWrapper ??= InAppReviewWrapper();
    return _inAppReviewWrapper!;
  }

  IsolatesWrapper get isolatesWrapper {
    _isolatesWrapper ??= IsolatesWrapper();
    return _isolatesWrapper!;
  }

  PackageInfoWrapper get packageInfoWrapper {
    _packageInfoWrapper ??= PackageInfoWrapper();
    return _packageInfoWrapper!;
  }

  PathProviderWrapper get pathProviderWrapper {
    _pathProviderWrapper ??= PathProviderWrapper();
    return _pathProviderWrapper!;
  }

  PhotoManagerWrapper get photoManagerWrapper {
    _photoManagerWrapper ??= PhotoManagerWrapper();
    return _photoManagerWrapper!;
  }

  ServicesWrapper get servicesWrapper {
    _servicesWrapper ??= ServicesWrapper();
    return _servicesWrapper!;
  }

  SharedPreferencesWrapper get sharedPreferencesWrapper {
    _sharedPreferencesWrapper ??= SharedPreferencesWrapper();
    return _sharedPreferencesWrapper!;
  }

  SharePlusWrapper get sharePlusWrapper {
    _sharePlusWrapper ??= SharePlusWrapper();
    return _sharePlusWrapper!;
  }

  UrlLauncherWrapper get urlLauncherWrapper {
    _urlLauncherWrapper ??= UrlLauncherWrapper();
    return _urlLauncherWrapper!;
  }

  /// Initializes this [AppManager] instance. If [isStartup] is true, all
  /// managers and monitors are initialized; otherwise, only database dependent
  /// managers and monitors are initialized.
  Future<void> init({bool isStartup = true}) async {
    await AdairFlutterLib.get.init();

    // Managers that don't need to refresh after startup.
    if (isStartup) {
      await RegionManager.get.init();
      await locationMonitor.initialize();
      await PollManager.get.initialize();
    }

    // Need to initialize the local database before anything else, since all
    // entity managers depend on the local database.
    await LocalDatabaseManager.get.init();
    await UserPreferenceManager.get.init();
    await anglerManager.initialize();
    await baitCategoryManager.initialize();
    await baitManager.initialize();
    await bodyOfWaterManager.initialize();
    await catchManager.initialize();
    await customEntityManager.initialize();
    await fishingSpotManager.initialize();
    await gearManager.initialize();
    await gpsTrailManager.initialize();
    await methodManager.initialize();
    await reportManager.initialize();
    await speciesManager.initialize();
    await tripManager.initialize();
    await waterClarityManager.initialize();

    // Managers that depend on other managers.
    if (isStartup) {
      // Must be done before BackupRestoreManager so subscriptions are fired on
      // startup if needed.
      await notificationManager.initialize();

      await backupRestoreManager.initialize();
      await imageManager.initialize();
    }
  }
}
