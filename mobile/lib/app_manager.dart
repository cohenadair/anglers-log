import 'package:flutter/material.dart';
import 'package:mobile/wrappers/google_mobile_ads_wrapper.dart';
import 'package:mobile/wrappers/google_sign_in_wrapper.dart';
import 'package:provider/provider.dart';

import 'angler_manager.dart';
import 'backup_restore_manager.dart';
import 'bait_category_manager.dart';
import 'bait_manager.dart';
import 'body_of_water_manager.dart';
import 'catch_manager.dart';
import 'custom_entity_manager.dart';
import 'fishing_spot_manager.dart';
import 'image_manager.dart';
import 'local_database_manager.dart';
import 'location_monitor.dart';
import 'method_manager.dart';
import 'properties_manager.dart';
import 'report_manager.dart';
import 'species_manager.dart';
import 'subscription_manager.dart';
import 'time_manager.dart';
import 'trip_manager.dart';
import 'user_preference_manager.dart';
import 'water_clarity_manager.dart';
import 'wrappers/device_info_wrapper.dart';
import 'wrappers/drive_api_wrapper.dart';
import 'wrappers/file_picker_wrapper.dart';
import 'wrappers/http_wrapper.dart';
import 'wrappers/image_compress_wrapper.dart';
import 'wrappers/image_picker_wrapper.dart';
import 'wrappers/io_wrapper.dart';
import 'wrappers/native_time_zone_wrapper.dart';
import 'wrappers/package_info_wrapper.dart';
import 'wrappers/path_provider_wrapper.dart';
import 'wrappers/permission_handler_wrapper.dart';
import 'wrappers/photo_manager_wrapper.dart';
import 'wrappers/purchases_wrapper.dart';
import 'wrappers/services_wrapper.dart';
import 'wrappers/share_plus_wrapper.dart';
import 'wrappers/shared_preferences_wrapper.dart';
import 'wrappers/url_launcher_wrapper.dart';

class AppManager {
  static AppManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false);

  // Internal dependencies.
  AnglerManager? _anglerManager;
  BackupRestoreManager? _backupRestoreManager;
  BaitCategoryManager? _baitCategoryManager;
  BaitManager? _baitManager;
  BodyOfWaterManager? _bodyOfWaterManager;
  CatchManager? _catchManager;
  CustomEntityManager? _customEntityManager;
  FishingSpotManager? _fishingSpotManager;
  ImageManager? _imageManager;
  LocalDatabaseManager? _localDatabaseManager;
  LocationMonitor? _locationMonitor;
  MethodManager? _methodManager;
  PropertiesManager? _propertiesManager;
  ReportManager? _reportManager;
  SpeciesManager? _speciesManager;
  SubscriptionManager? _subscriptionManager;
  TimeManager? _timeManager;
  TripManager? _tripManager;
  UserPreferenceManager? _userPreferenceManager;
  WaterClarityManager? _waterClarityManager;

  // External dependency wrappers.
  DeviceInfoWrapper? _deviceInfoWrapper;
  DriveApiWrapper? _driveApiWrapper;
  FilePickerWrapper? _filePickerWrapper;
  GoogleMobileAdsWrapper? _googleMobileAdsWrapper;
  GoogleSignInWrapper? _googleSignInWrapper;
  HttpWrapper? _httpWrapper;
  ImageCompressWrapper? _imageCompressWrapper;
  ImagePickerWrapper? _imagePickerWrapper;
  IoWrapper? _ioWrapper;
  NativeTimeZoneWrapper? _nativeTimeZoneWrapper;
  PackageInfoWrapper? _packageInfoWrapper;
  PathProviderWrapper? _pathProviderWrapper;
  PermissionHandlerWrapper? _permissionHandlerWrapper;
  PhotoManagerWrapper? _photoManagerWrapper;
  PurchasesWrapper? _purchasesWrapper;
  ServicesWrapper? _servicesWrapper;
  SharedPreferencesWrapper? _sharedPreferencesWrapper;
  SharePlusWrapper? _sharePlusWrapper;
  UrlLauncherWrapper? _urlLauncherWrapper;

  AnglerManager get anglerManager {
    _anglerManager ??= AnglerManager(this);
    return _anglerManager!;
  }

  BackupRestoreManager get backupRestoreManager {
    _backupRestoreManager ??= BackupRestoreManager(this);
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

  ImageManager get imageManager {
    _imageManager ??= ImageManager(this);
    return _imageManager!;
  }

  LocalDatabaseManager get localDatabaseManager {
    _localDatabaseManager ??= LocalDatabaseManager(this);
    return _localDatabaseManager!;
  }

  LocationMonitor get locationMonitor {
    _locationMonitor ??= LocationMonitor(this);
    return _locationMonitor!;
  }

  MethodManager get methodManager {
    _methodManager ??= MethodManager(this);
    return _methodManager!;
  }

  PropertiesManager get propertiesManager {
    _propertiesManager ??= PropertiesManager();
    return _propertiesManager!;
  }

  ReportManager get reportManager {
    _reportManager ??= ReportManager(this);
    return _reportManager!;
  }

  SpeciesManager get speciesManager {
    _speciesManager ??= SpeciesManager(this);
    return _speciesManager!;
  }

  SubscriptionManager get subscriptionManager {
    _subscriptionManager ??= SubscriptionManager(this);
    return _subscriptionManager!;
  }

  TimeManager get timeManager {
    _timeManager ??= TimeManager(this);
    return _timeManager!;
  }

  TripManager get tripManager {
    _tripManager ??= TripManager(this);
    return _tripManager!;
  }

  UserPreferenceManager get userPreferenceManager {
    _userPreferenceManager ??= UserPreferenceManager(this);
    return _userPreferenceManager!;
  }

  WaterClarityManager get waterClarityManager {
    _waterClarityManager ??= WaterClarityManager(this);
    return _waterClarityManager!;
  }

  DeviceInfoWrapper get deviceInfoWrapper {
    _deviceInfoWrapper ??= DeviceInfoWrapper();
    return _deviceInfoWrapper!;
  }

  DriveApiWrapper get driveApiWrapper {
    _driveApiWrapper ??= DriveApiWrapper();
    return _driveApiWrapper!;
  }

  FilePickerWrapper get filePickerWrapper {
    _filePickerWrapper ??= FilePickerWrapper();
    return _filePickerWrapper!;
  }

  GoogleMobileAdsWrapper get googleMobileAdsWrapper {
    _googleMobileAdsWrapper ??= GoogleMobileAdsWrapper();
    return _googleMobileAdsWrapper!;
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

  IoWrapper get ioWrapper {
    _ioWrapper ??= IoWrapper();
    return _ioWrapper!;
  }

  NativeTimeZoneWrapper get nativeTimeZoneWrapper {
    _nativeTimeZoneWrapper ??= NativeTimeZoneWrapper();
    return _nativeTimeZoneWrapper!;
  }

  PackageInfoWrapper get packageInfoWrapper {
    _packageInfoWrapper ??= PackageInfoWrapper();
    return _packageInfoWrapper!;
  }

  PathProviderWrapper get pathProviderWrapper {
    _pathProviderWrapper ??= PathProviderWrapper();
    return _pathProviderWrapper!;
  }

  PermissionHandlerWrapper get permissionHandlerWrapper {
    _permissionHandlerWrapper ??= PermissionHandlerWrapper();
    return _permissionHandlerWrapper!;
  }

  PhotoManagerWrapper get photoManagerWrapper {
    _photoManagerWrapper ??= PhotoManagerWrapper();
    return _photoManagerWrapper!;
  }

  PurchasesWrapper get purchasesWrapper {
    _purchasesWrapper ??= PurchasesWrapper();
    return _purchasesWrapper!;
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
  Future<void> initialize({bool isStartup = true}) async {
    // Managers that don't depend on anything.
    if (isStartup) {
      await timeManager.initialize();
      await locationMonitor.initialize();
      await propertiesManager.initialize();
      await subscriptionManager.initialize();
    }

    // Need to initialize the local database before anything else, since all
    // entity managers depend on the local database.
    await localDatabaseManager.initialize();

    // UserPreferenceManager includes "pro" override and needs to be initialized
    // before managers that upload data to Firebase.
    await userPreferenceManager.initialize();

    await anglerManager.initialize();
    await baitCategoryManager.initialize();
    await baitManager.initialize();
    await bodyOfWaterManager.initialize();
    await catchManager.initialize();
    await customEntityManager.initialize();
    await fishingSpotManager.initialize();
    await methodManager.initialize();
    await reportManager.initialize();
    await speciesManager.initialize();
    await tripManager.initialize();
    await waterClarityManager.initialize();

    // Managers that depend on other managers.
    if (isStartup) {
      await backupRestoreManager.initialize();
      await imageManager.initialize();
    }
  }
}
