import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/app_preference_manager.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/comparison_report_manager.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/summary_report_manager.dart';
import 'package:mobile/local_database_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/properties_manager.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/wrappers/file_picker_wrapper.dart';
import 'package:mobile/wrappers/firebase_auth_wrapper.dart';
import 'package:mobile/wrappers/firebase_wrapper.dart';
import 'package:mobile/wrappers/firestore_wrapper.dart';
import 'package:mobile/wrappers/http_wrapper.dart';
import 'package:mobile/wrappers/image_compress_wrapper.dart';
import 'package:mobile/wrappers/image_picker_wrapper.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:mobile/wrappers/package_info_wrapper.dart';
import 'package:mobile/wrappers/path_provider_wrapper.dart';
import 'package:mobile/wrappers/permission_handler_wrapper.dart';
import 'package:mobile/wrappers/photo_manager_wrapper.dart';
import 'package:mobile/wrappers/services_wrapper.dart';
import 'package:mobile/wrappers/url_launcher_wrapper.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

class MockAppPreferenceManager extends Mock implements AppPreferenceManager {}

class MockAuthManager extends Mock implements AuthManager {}

class MockBaitCategoryManager extends Mock implements BaitCategoryManager {}

class MockBaitManager extends Mock implements BaitManager {}

class MockDatabase extends Mock implements Database {}

class MockCatchManager extends Mock implements CatchManager {}

class MockComparisonReportManager extends Mock
    implements ComparisonReportManager {}

class MockCustomEntityManager extends Mock implements CustomEntityManager {}

class MockFishingSpotManager extends Mock implements FishingSpotManager {}

class MockImageManager extends Mock implements ImageManager {}

class MockLocalDatabaseManager extends Mock implements LocalDatabaseManager {}

class MockLocationMonitor extends Mock implements LocationMonitor {}

class MockPreferencesManager extends Mock implements UserPreferenceManager {}

class MockPropertiesManager extends Mock implements PropertiesManager {}

class MockSpeciesManager extends Mock implements SpeciesManager {}

class MockSubscriptionManager extends Mock implements SubscriptionManager {}

class MockSummaryReportManager extends Mock implements SummaryReportManager {}

class MockTimeManager extends Mock implements TimeManager {}

class MockTripManager extends Mock implements TripManager {}

class MockUserPreferenceManager extends Mock implements UserPreferenceManager {}

class MockFilePickerWrapper extends Mock implements FilePickerWrapper {}

class MockFirebaseAuthWrapper extends Mock implements FirebaseAuthWrapper {}

class MockFirebaseWrapper extends Mock implements FirebaseWrapper {}

class MockFirestoreWrapper extends Mock implements FirestoreWrapper {}

class MockHttpWrapper extends Mock implements HttpWrapper {}

class MockImageCompressWrapper extends Mock implements ImageCompressWrapper {}

class MockImagePickerWrapper extends Mock implements ImagePickerWrapper {}

class MockIoWrapper extends Mock implements IoWrapper {}

class MockPackageInfoWrapper extends Mock implements PackageInfoWrapper {}

class MockPathProviderWrapper extends Mock implements PathProviderWrapper {}

class MockPermissionHandlerWrapper extends Mock
    implements PermissionHandlerWrapper {}

class MockPhotoManagerWrapper extends Mock implements PhotoManagerWrapper {}

class MockServicesWrapper extends Mock implements ServicesWrapper {}

class MockUrlLauncherWrapper extends Mock implements UrlLauncherWrapper {}

class MockAppManager extends Mock implements AppManager {
  MockAppPreferenceManager mockAppPreferenceManager;
  MockAuthManager mockAuthManager;
  MockBaitCategoryManager mockBaitCategoryManager;
  MockBaitManager mockBaitManager;
  MockCatchManager mockCatchManager;
  MockComparisonReportManager mockComparisonReportManager;
  MockCustomEntityManager mockCustomEntityManager;
  MockFishingSpotManager mockFishingSpotManager;
  MockImageManager mockImageManager;
  MockLocalDatabaseManager mockLocalDatabaseManager;
  MockLocationMonitor mockLocationMonitor;
  MockPreferencesManager mockPreferencesManager;
  MockPropertiesManager mockPropertiesManager;
  MockSpeciesManager mockSpeciesManager;
  MockSubscriptionManager mockSubscriptionManager;
  MockSummaryReportManager mockSummaryReportManager;
  MockTimeManager mockTimeManager;
  MockTripManager mockTripManager;
  MockUserPreferenceManager mockUserPreferenceManager;

  MockFilePickerWrapper mockFilePickerWrapper;
  MockFirebaseAuthWrapper mockFirebaseAuthWrapper;
  MockFirebaseWrapper mockFirebaseWrapper;
  MockFirestoreWrapper mockFirestoreWrapper;
  MockHttpWrapper mockHttpWrapper;
  MockImageCompressWrapper mockImageCompressWrapper;
  MockImagePickerWrapper mockImagePickerWrapper;
  MockIoWrapper mockIoWrapper;
  MockPackageInfoWrapper mockPackageInfoWrapper;
  MockPathProviderWrapper mockPathProviderWrapper;
  MockPermissionHandlerWrapper mockPermissionHandlerWrapper;
  MockPhotoManagerWrapper mockPhotoManagerWrapper;
  MockServicesWrapper mockServicesWrapper;
  MockUrlLauncherWrapper mockUrlLauncherWrapper;

  MockAppManager({
    bool mockAppPreferenceManager = false,
    bool mockAuthManager = false,
    bool mockBaitCategoryManager = false,
    bool mockBaitManager = false,
    bool mockCatchManager = false,
    bool mockComparisonReportManager = false,
    bool mockCustomEntityManager = false,
    bool mockCustomEntityValueManager = false,
    bool mockFishingSpotManager = false,
    bool mockImageManager = false,
    bool mockLocalDatabaseManager = false,
    bool mockLocationMonitor = false,
    bool mockPreferencesManager = false,
    bool mockPropertiesManager = false,
    bool mockSpeciesManager = false,
    bool mockSubscriptionManager = false,
    bool mockSummaryReportManager = false,
    bool mockTimeManager = false,
    bool mockTripManager = false,
    bool mockUserPreferenceManager = false,
    bool mockFilePickerWrapper = false,
    bool mockFirebaseAuthWrapper = false,
    bool mockFirebaseWrapper = false,
    bool mockFirestoreWrapper = false,
    bool mockHttpWrapper = false,
    bool mockImageCompressWrapper = false,
    bool mockImagePickerWrapper = false,
    bool mockIoWrapper = false,
    bool mockPackageInfoWrapper = false,
    bool mockPathProviderWrapper = false,
    bool mockPermissionHandlerWrapper = false,
    bool mockPhotoManagerWrapper = false,
    bool mockServicesWrapper = false,
    bool mockUrlLauncherWrapper = false,
  }) {
    if (mockAppPreferenceManager) {
      this.mockAppPreferenceManager = MockAppPreferenceManager();
      when(appPreferenceManager).thenReturn(this.mockAppPreferenceManager);
    }

    if (mockAuthManager) {
      this.mockAuthManager = MockAuthManager();
      when(authManager).thenReturn(this.mockAuthManager);
    }

    if (mockBaitCategoryManager) {
      this.mockBaitCategoryManager = MockBaitCategoryManager();
      when(baitCategoryManager).thenReturn(this.mockBaitCategoryManager);
    }

    if (mockBaitManager) {
      this.mockBaitManager = MockBaitManager();
      when(baitManager).thenReturn(this.mockBaitManager);
    }

    if (mockCatchManager) {
      this.mockCatchManager = MockCatchManager();
      when(catchManager).thenReturn(this.mockCatchManager);
    }

    if (mockComparisonReportManager) {
      this.mockComparisonReportManager = MockComparisonReportManager();
      when(comparisonReportManager)
          .thenReturn(this.mockComparisonReportManager);
    }

    if (mockCustomEntityManager) {
      this.mockCustomEntityManager = MockCustomEntityManager();
      when(customEntityManager).thenReturn(this.mockCustomEntityManager);
    }

    if (mockFishingSpotManager) {
      this.mockFishingSpotManager = MockFishingSpotManager();
      when(fishingSpotManager).thenReturn(this.mockFishingSpotManager);
    }

    if (mockImageManager) {
      this.mockImageManager = MockImageManager();
      when(imageManager).thenReturn(this.mockImageManager);
    }

    if (mockLocalDatabaseManager) {
      this.mockLocalDatabaseManager = MockLocalDatabaseManager();
      when(localDatabaseManager).thenReturn(this.mockLocalDatabaseManager);
    }

    if (mockLocationMonitor) {
      this.mockLocationMonitor = MockLocationMonitor();
      when(locationMonitor).thenReturn(this.mockLocationMonitor);
    }

    if (mockPreferencesManager) {
      this.mockPreferencesManager = MockPreferencesManager();
      when(userPreferenceManager).thenReturn(this.mockPreferencesManager);
    }

    if (mockPropertiesManager) {
      this.mockPropertiesManager = MockPropertiesManager();
      when(propertiesManager).thenReturn(this.mockPropertiesManager);
    }

    if (mockSpeciesManager) {
      this.mockSpeciesManager = MockSpeciesManager();
      when(speciesManager).thenReturn(this.mockSpeciesManager);
    }

    if (mockSubscriptionManager) {
      this.mockSubscriptionManager = MockSubscriptionManager();
      when(subscriptionManager).thenReturn(this.mockSubscriptionManager);
    }

    if (mockSummaryReportManager) {
      this.mockSummaryReportManager = MockSummaryReportManager();
      when(summaryReportManager).thenReturn(this.mockSummaryReportManager);
    }

    if (mockTimeManager) {
      this.mockTimeManager = MockTimeManager();

      // Default to the current time.
      stubCurrentTime(DateTime.now());
      when(timeManager).thenReturn(this.mockTimeManager);
    }

    if (mockTripManager) {
      this.mockTripManager = MockTripManager();
      when(tripManager).thenReturn(this.mockTripManager);
    }

    if (mockUserPreferenceManager) {
      this.mockUserPreferenceManager = MockUserPreferenceManager();
      when(userPreferenceManager).thenReturn(this.mockUserPreferenceManager);
    }

    if (mockFilePickerWrapper) {
      this.mockFilePickerWrapper = MockFilePickerWrapper();
      when(filePickerWrapper).thenReturn(this.mockFilePickerWrapper);
    }

    if (mockFirebaseAuthWrapper) {
      this.mockFirebaseAuthWrapper = MockFirebaseAuthWrapper();
      when(firebaseAuthWrapper).thenReturn(this.mockFirebaseAuthWrapper);
    }

    if (mockFirebaseWrapper) {
      this.mockFirebaseWrapper = MockFirebaseWrapper();
      when(firebaseWrapper).thenReturn(this.mockFirebaseWrapper);
    }

    if (mockFirestoreWrapper) {
      this.mockFirestoreWrapper = MockFirestoreWrapper();
      when(firestoreWrapper).thenReturn(this.mockFirestoreWrapper);
    }

    if (mockHttpWrapper) {
      this.mockHttpWrapper = MockHttpWrapper();
      when(httpWrapper).thenReturn(this.mockHttpWrapper);
    }

    if (mockImageCompressWrapper) {
      this.mockImageCompressWrapper = MockImageCompressWrapper();
      when(imageCompressWrapper).thenReturn(this.mockImageCompressWrapper);
    }

    if (mockImagePickerWrapper) {
      this.mockImagePickerWrapper = MockImagePickerWrapper();
      when(imagePickerWrapper).thenReturn(this.mockImagePickerWrapper);
    }

    if (mockIoWrapper) {
      this.mockIoWrapper = MockIoWrapper();
      when(ioWrapper).thenReturn(this.mockIoWrapper);
    }

    if (mockPackageInfoWrapper) {
      this.mockPackageInfoWrapper = MockPackageInfoWrapper();
      when(packageInfoWrapper).thenReturn(this.mockPackageInfoWrapper);
    }

    if (mockPathProviderWrapper) {
      this.mockPathProviderWrapper = MockPathProviderWrapper();
      when(pathProviderWrapper).thenReturn(this.mockPathProviderWrapper);
    }

    if (mockPermissionHandlerWrapper) {
      this.mockPermissionHandlerWrapper = MockPermissionHandlerWrapper();
      when(permissionHandlerWrapper)
          .thenReturn(this.mockPermissionHandlerWrapper);
    }

    if (mockPhotoManagerWrapper) {
      this.mockPhotoManagerWrapper = MockPhotoManagerWrapper();
      when(photoManagerWrapper).thenReturn(this.mockPhotoManagerWrapper);
    }

    if (mockServicesWrapper) {
      this.mockServicesWrapper = MockServicesWrapper();
      when(servicesWrapper).thenReturn(this.mockServicesWrapper);
    }

    if (mockUrlLauncherWrapper) {
      this.mockUrlLauncherWrapper = MockUrlLauncherWrapper();
      when(urlLauncherWrapper).thenReturn(this.mockUrlLauncherWrapper);
    }
  }

  void stubCurrentTime(DateTime now) {
    when(mockTimeManager.currentDateTime).thenReturn(now);
    when(mockTimeManager.currentTime).thenReturn(TimeOfDay.fromDateTime(now));
    when(mockTimeManager.msSinceEpoch).thenReturn(now.millisecondsSinceEpoch);
  }
}
