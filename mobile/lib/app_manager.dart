import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'angler_manager.dart';
import 'app_preference_manager.dart';
import 'auth_manager.dart';
import 'bait_category_manager.dart';
import 'bait_manager.dart';
import 'catch_manager.dart';
import 'comparison_report_manager.dart';
import 'custom_entity_manager.dart';
import 'fishing_spot_manager.dart';
import 'image_manager.dart';
import 'local_database_manager.dart';
import 'location_monitor.dart';
import 'method_manager.dart';
import 'properties_manager.dart';
import 'species_manager.dart';
import 'subscription_manager.dart';
import 'summary_report_manager.dart';
import 'time_manager.dart';
import 'trip_manager.dart';
import 'user_preference_manager.dart';
import 'wrappers/file_picker_wrapper.dart';
import 'wrappers/firebase_auth_wrapper.dart';
import 'wrappers/firebase_storage_wrapper.dart';
import 'wrappers/firebase_wrapper.dart';
import 'wrappers/firestore_wrapper.dart';
import 'wrappers/http_wrapper.dart';
import 'wrappers/image_compress_wrapper.dart';
import 'wrappers/image_picker_wrapper.dart';
import 'wrappers/io_wrapper.dart';
import 'wrappers/package_info_wrapper.dart';
import 'wrappers/path_provider_wrapper.dart';
import 'wrappers/permission_handler_wrapper.dart';
import 'wrappers/photo_manager_wrapper.dart';
import 'wrappers/purchases_wrapper.dart';
import 'wrappers/services_wrapper.dart';
import 'wrappers/shared_preferences_wrapper.dart';
import 'wrappers/url_launcher_wrapper.dart';

class AppManager {
  static AppManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false);

  // Internal dependencies.
  AnglerManager? _anglerManager;
  AppPreferenceManager? _appPreferenceManager;
  AuthManager? _authManager;
  BaitCategoryManager? _baitCategoryManager;
  BaitManager? _baitManager;
  CatchManager? _catchManager;
  ComparisonReportManager? _comparisonReportManager;
  CustomEntityManager? _customEntityManager;
  FishingSpotManager? _fishingSpotManager;
  ImageManager? _imageManager;
  LocalDatabaseManager? _localDatabaseManager;
  LocationMonitor? _locationMonitor;
  MethodManager? _methodManager;
  PropertiesManager? _propertiesManager;
  SpeciesManager? _speciesManager;
  SubscriptionManager? _subscriptionManager;
  SummaryReportManager? _summaryReportManager;
  TimeManager? _timeManager;
  TripManager? _tripManager;
  UserPreferenceManager? _userPreferenceManager;

  // External dependency wrappers.
  FilePickerWrapper? _filePickerWrapper;
  FirebaseAuthWrapper? _firebaseAuthWrapper;
  FirebaseStorageWrapper? _firebaseStorageWrapper;
  FirebaseWrapper? _firebaseWrapper;
  FirestoreWrapper? _firestoreWrapper;
  HttpWrapper? _httpWrapper;
  ImageCompressWrapper? _imageCompressWrapper;
  ImagePickerWrapper? _imagePickerWrapper;
  IoWrapper? _ioWrapper;
  PackageInfoWrapper? _packageInfoWrapper;
  PathProviderWrapper? _pathProviderWrapper;
  PermissionHandlerWrapper? _permissionHandlerWrapper;
  PhotoManagerWrapper? _photoManagerWrapper;
  PurchasesWrapper? _purchasesWrapper;
  ServicesWrapper? _servicesWrapper;
  SharedPreferencesWrapper? _sharedPreferencesWrapper;
  UrlLauncherWrapper? _urlLauncherWrapper;

  AnglerManager get anglerManager {
    if (_anglerManager == null) {
      _anglerManager = AnglerManager(this);
    }
    return _anglerManager!;
  }

  AppPreferenceManager get appPreferenceManager {
    if (_appPreferenceManager == null) {
      _appPreferenceManager = AppPreferenceManager(this);
    }
    return _appPreferenceManager!;
  }

  AuthManager get authManager {
    if (_authManager == null) {
      _authManager = AuthManager(this);
    }
    return _authManager!;
  }

  BaitCategoryManager get baitCategoryManager {
    if (_baitCategoryManager == null) {
      _baitCategoryManager = BaitCategoryManager(this);
    }
    return _baitCategoryManager!;
  }

  BaitManager get baitManager {
    if (_baitManager == null) {
      _baitManager = BaitManager(this);
    }
    return _baitManager!;
  }

  CatchManager get catchManager {
    if (_catchManager == null) {
      _catchManager = CatchManager(this);
    }
    return _catchManager!;
  }

  ComparisonReportManager get comparisonReportManager {
    if (_comparisonReportManager == null) {
      _comparisonReportManager = ComparisonReportManager(this);
    }
    return _comparisonReportManager!;
  }

  CustomEntityManager get customEntityManager {
    if (_customEntityManager == null) {
      _customEntityManager = CustomEntityManager(this);
    }
    return _customEntityManager!;
  }

  FishingSpotManager get fishingSpotManager {
    if (_fishingSpotManager == null) {
      _fishingSpotManager = FishingSpotManager(this);
    }
    return _fishingSpotManager!;
  }

  ImageManager get imageManager {
    if (_imageManager == null) {
      _imageManager = ImageManager(this);
    }
    return _imageManager!;
  }

  LocalDatabaseManager get localDatabaseManager {
    if (_localDatabaseManager == null) {
      _localDatabaseManager = LocalDatabaseManager(this);
    }
    return _localDatabaseManager!;
  }

  LocationMonitor get locationMonitor {
    if (_locationMonitor == null) {
      _locationMonitor = LocationMonitor(this);
    }
    return _locationMonitor!;
  }

  MethodManager get methodManager {
    if (_methodManager == null) {
      _methodManager = MethodManager(this);
    }
    return _methodManager!;
  }

  PropertiesManager get propertiesManager {
    if (_propertiesManager == null) {
      _propertiesManager = PropertiesManager();
    }
    return _propertiesManager!;
  }

  SpeciesManager get speciesManager {
    if (_speciesManager == null) {
      _speciesManager = SpeciesManager(this);
    }
    return _speciesManager!;
  }

  SubscriptionManager get subscriptionManager {
    if (_subscriptionManager == null) {
      _subscriptionManager = SubscriptionManager(this);
    }
    return _subscriptionManager!;
  }

  SummaryReportManager get summaryReportManager {
    if (_summaryReportManager == null) {
      _summaryReportManager = SummaryReportManager(this);
    }
    return _summaryReportManager!;
  }

  TimeManager get timeManager {
    if (_timeManager == null) {
      _timeManager = TimeManager();
    }
    return _timeManager!;
  }

  TripManager get tripManager {
    if (_tripManager == null) {
      _tripManager = TripManager();
    }
    return _tripManager!;
  }

  UserPreferenceManager get userPreferenceManager {
    if (_userPreferenceManager == null) {
      _userPreferenceManager = UserPreferenceManager(this);
    }
    return _userPreferenceManager!;
  }

  FilePickerWrapper get filePickerWrapper {
    if (_filePickerWrapper == null) {
      _filePickerWrapper = FilePickerWrapper();
    }
    return _filePickerWrapper!;
  }

  FirebaseAuthWrapper get firebaseAuthWrapper {
    if (_firebaseAuthWrapper == null) {
      _firebaseAuthWrapper = FirebaseAuthWrapper();
    }
    return _firebaseAuthWrapper!;
  }

  FirebaseStorageWrapper get firebaseStorageWrapper {
    if (_firebaseStorageWrapper == null) {
      _firebaseStorageWrapper = FirebaseStorageWrapper();
    }
    return _firebaseStorageWrapper!;
  }

  FirebaseWrapper get firebaseWrapper {
    if (_firebaseWrapper == null) {
      _firebaseWrapper = FirebaseWrapper();
    }
    return _firebaseWrapper!;
  }

  FirestoreWrapper get firestoreWrapper {
    if (_firestoreWrapper == null) {
      _firestoreWrapper = FirestoreWrapper();
    }
    return _firestoreWrapper!;
  }

  HttpWrapper get httpWrapper {
    if (_httpWrapper == null) {
      _httpWrapper = HttpWrapper();
    }
    return _httpWrapper!;
  }

  ImageCompressWrapper get imageCompressWrapper {
    if (_imageCompressWrapper == null) {
      _imageCompressWrapper = ImageCompressWrapper();
    }
    return _imageCompressWrapper!;
  }

  ImagePickerWrapper get imagePickerWrapper {
    if (_imagePickerWrapper == null) {
      _imagePickerWrapper = ImagePickerWrapper();
    }
    return _imagePickerWrapper!;
  }

  IoWrapper get ioWrapper {
    if (_ioWrapper == null) {
      _ioWrapper = IoWrapper();
    }
    return _ioWrapper!;
  }

  PackageInfoWrapper get packageInfoWrapper {
    if (_packageInfoWrapper == null) {
      _packageInfoWrapper = PackageInfoWrapper();
    }
    return _packageInfoWrapper!;
  }

  PathProviderWrapper get pathProviderWrapper {
    if (_pathProviderWrapper == null) {
      _pathProviderWrapper = PathProviderWrapper();
    }
    return _pathProviderWrapper!;
  }

  PermissionHandlerWrapper get permissionHandlerWrapper {
    if (_permissionHandlerWrapper == null) {
      _permissionHandlerWrapper = PermissionHandlerWrapper();
    }
    return _permissionHandlerWrapper!;
  }

  PhotoManagerWrapper get photoManagerWrapper {
    if (_photoManagerWrapper == null) {
      _photoManagerWrapper = PhotoManagerWrapper();
    }
    return _photoManagerWrapper!;
  }

  PurchasesWrapper get purchasesWrapper {
    if (_purchasesWrapper == null) {
      _purchasesWrapper = PurchasesWrapper();
    }
    return _purchasesWrapper!;
  }

  ServicesWrapper get servicesWrapper {
    if (_servicesWrapper == null) {
      _servicesWrapper = ServicesWrapper();
    }
    return _servicesWrapper!;
  }

  SharedPreferencesWrapper get sharedPreferencesWrapper {
    if (_sharedPreferencesWrapper == null) {
      _sharedPreferencesWrapper = SharedPreferencesWrapper();
    }
    return _sharedPreferencesWrapper!;
  }

  UrlLauncherWrapper get urlLauncherWrapper {
    if (_urlLauncherWrapper == null) {
      _urlLauncherWrapper = UrlLauncherWrapper();
    }
    return _urlLauncherWrapper!;
  }
}
