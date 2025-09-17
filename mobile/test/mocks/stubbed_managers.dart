import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/l10n/gen/localizations.dart';
import 'package:mobile/l10n/syncfusion/sf_localizations.dart';
import 'package:mobile/local_database_manager.dart';
import 'package:mobile/poll_manager.dart';
import 'package:mobile/properties_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/stubbed_managers.dart'
    as s;
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../test_utils.dart';
import 'mocks.dart';
import 'mocks.mocks.dart';

class StubbedManagers {
  late final s.StubbedManagers lib;

  MockAppManager app = MockAppManager();

  MockAnglerManager anglerManager = MockAnglerManager();
  MockBackupRestoreManager backupRestoreManager = MockBackupRestoreManager();
  MockBaitCategoryManager baitCategoryManager = MockBaitCategoryManager();
  MockBaitManager baitManager = MockBaitManager();
  MockBodyOfWaterManager bodyOfWaterManager = MockBodyOfWaterManager();
  MockCatchManager catchManager = MockCatchManager();
  MockCustomEntityManager customEntityManager = MockCustomEntityManager();
  MockFishingSpotManager fishingSpotManager = MockFishingSpotManager();
  MockGearManager gearManager = MockGearManager();
  MockGpsTrailManager gpsTrailManager = MockGpsTrailManager();
  MockImageManager imageManager = MockImageManager();
  MockLocalDatabaseManager localDatabaseManager = MockLocalDatabaseManager();
  MockLocationMonitor locationMonitor = MockLocationMonitor();
  MockMethodManager methodManager = MockMethodManager();
  MockNotificationManager notificationManager = MockNotificationManager();
  MockPollManager pollManager = MockPollManager();
  MockPropertiesManager propertiesManager = MockPropertiesManager();
  MockRegionManager regionManager = MockRegionManager();
  MockReportManager reportManager = MockReportManager();
  MockSpeciesManager speciesManager = MockSpeciesManager();
  MockTripManager tripManager = MockTripManager();
  MockUserPreferenceManager userPreferenceManager = MockUserPreferenceManager();
  MockWaterClarityManager waterClarityManager = MockWaterClarityManager();

  MockCsvWrapper csvWrapper = MockCsvWrapper();
  MockDriveApiWrapper driveApiWrapper = MockDriveApiWrapper();
  MockExifWrapper exifWrapper = MockExifWrapper();
  MockFilePickerWrapper filePickerWrapper = MockFilePickerWrapper();
  MockGeolocatorWrapper geolocatorWrapper = MockGeolocatorWrapper();
  MockGoogleSignInWrapper googleSignInWrapper = MockGoogleSignInWrapper();
  MockHttpWrapper httpWrapper = MockHttpWrapper();
  MockImageCompressWrapper imageCompressWrapper = MockImageCompressWrapper();
  MockImagePickerWrapper imagePickerWrapper = MockImagePickerWrapper();
  MockInAppReviewWrapper inAppReviewWrapper = MockInAppReviewWrapper();
  MockIsolatesWrapper isolatesWrapper = MockIsolatesWrapper();
  MockPackageInfoWrapper packageInfoWrapper = MockPackageInfoWrapper();
  MockPathProviderWrapper pathProviderWrapper = MockPathProviderWrapper();
  MockPhotoManagerWrapper photoManagerWrapper = MockPhotoManagerWrapper();
  MockRegionSettingsWrapper regionSettingsWrapper = MockRegionSettingsWrapper();
  MockServicesWrapper servicesWrapper = MockServicesWrapper();
  MockSharedPreferencesWrapper sharedPreferencesWrapper =
      MockSharedPreferencesWrapper();
  MockSharePlusWrapper sharePlusWrapper = MockSharePlusWrapper();
  MockUrlLauncherWrapper urlLauncherWrapper = MockUrlLauncherWrapper();

  // TODO: Can remove the Future return type.
  static Future<StubbedManagers> create() async =>
      StubbedManagers._(await s.StubbedManagers.create());

  StubbedManagers._(this.lib) {
    when(app.anglerManager).thenReturn(anglerManager);
    when(app.backupRestoreManager).thenReturn(backupRestoreManager);
    when(app.baitCategoryManager).thenReturn(baitCategoryManager);
    when(app.baitManager).thenReturn(baitManager);
    when(app.bodyOfWaterManager).thenReturn(bodyOfWaterManager);
    when(app.customEntityManager).thenReturn(customEntityManager);
    when(app.fishingSpotManager).thenReturn(fishingSpotManager);
    when(app.gearManager).thenReturn(gearManager);
    when(app.gpsTrailManager).thenReturn(gpsTrailManager);
    when(app.imageManager).thenReturn(imageManager);
    when(app.locationMonitor).thenReturn(locationMonitor);
    when(app.methodManager).thenReturn(methodManager);
    when(app.notificationManager).thenReturn(notificationManager);
    when(app.reportManager).thenReturn(reportManager);
    when(app.speciesManager).thenReturn(speciesManager);
    when(app.tripManager).thenReturn(tripManager);
    when(app.waterClarityManager).thenReturn(waterClarityManager);
    when(app.csvWrapper).thenReturn(csvWrapper);
    when(app.driveApiWrapper).thenReturn(driveApiWrapper);
    when(app.exifWrapper).thenReturn(exifWrapper);
    when(app.filePickerWrapper).thenReturn(filePickerWrapper);
    when(app.geolocatorWrapper).thenReturn(geolocatorWrapper);
    when(app.googleSignInWrapper).thenReturn(googleSignInWrapper);
    when(app.httpWrapper).thenReturn(httpWrapper);
    when(app.imageCompressWrapper).thenReturn(imageCompressWrapper);
    when(app.imagePickerWrapper).thenReturn(imagePickerWrapper);
    when(app.inAppReviewWrapper).thenReturn(inAppReviewWrapper);
    when(app.isolatesWrapper).thenReturn(isolatesWrapper);
    when(app.packageInfoWrapper).thenReturn(packageInfoWrapper);
    when(app.pathProviderWrapper).thenReturn(pathProviderWrapper);
    when(app.photoManagerWrapper).thenReturn(photoManagerWrapper);
    when(app.sharedPreferencesWrapper).thenReturn(sharedPreferencesWrapper);
    when(app.sharePlusWrapper).thenReturn(sharePlusWrapper);
    when(app.servicesWrapper).thenReturn(servicesWrapper);
    when(app.urlLauncherWrapper).thenReturn(urlLauncherWrapper);

    AppManager.set(app);
    CatchManager.set(catchManager);
    LocalDatabaseManager.set(localDatabaseManager);
    PollManager.set(pollManager);
    PropertiesManager.set(propertiesManager);
    UserPreferenceManager.set(userPreferenceManager);
    stubRegionManager(regionManager);

    // Setup default listener stubs on EntityListener classes, since
    // addTypedListener is called often in tests, but rarely actually used.
    when(
      anglerManager.addTypedListener(
        onAdd: anyNamed("onAdd"),
        onUpdate: anyNamed("onUpdate"),
        onDelete: anyNamed("onDelete"),
        onReset: anyNamed("onReset"),
      ),
    ).thenReturn(MockStreamSubscription());

    when(anglerManager.entity(any)).thenReturn(null);

    when(
      baitCategoryManager.addTypedListener(
        onAdd: anyNamed("onAdd"),
        onUpdate: anyNamed("onUpdate"),
        onDelete: anyNamed("onDelete"),
        onReset: anyNamed("onReset"),
      ),
    ).thenReturn(MockStreamSubscription());
    when(baitCategoryManager.entity(any)).thenReturn(null);

    when(
      baitManager.addTypedListener(
        onAdd: anyNamed("onAdd"),
        onUpdate: anyNamed("onUpdate"),
        onDelete: anyNamed("onDelete"),
        onReset: anyNamed("onReset"),
      ),
    ).thenReturn(MockStreamSubscription());
    when(baitManager.entity(any)).thenReturn(null);
    when(baitManager.list(any)).thenReturn([]);

    when(
      bodyOfWaterManager.addTypedListener(
        onAdd: anyNamed("onAdd"),
        onUpdate: anyNamed("onUpdate"),
        onDelete: anyNamed("onDelete"),
        onReset: anyNamed("onReset"),
      ),
    ).thenReturn(MockStreamSubscription());
    when(bodyOfWaterManager.entity(any)).thenReturn(null);
    when(bodyOfWaterManager.list(any)).thenReturn([]);

    when(
      catchManager.addTypedListener(
        onAdd: anyNamed("onAdd"),
        onUpdate: anyNamed("onUpdate"),
        onDelete: anyNamed("onDelete"),
        onReset: anyNamed("onReset"),
      ),
    ).thenReturn(MockStreamSubscription());
    when(catchManager.entity(any)).thenReturn(null);

    when(
      customEntityManager.addTypedListener(
        onAdd: anyNamed("onAdd"),
        onUpdate: anyNamed("onUpdate"),
        onDelete: anyNamed("onDelete"),
        onReset: anyNamed("onReset"),
      ),
    ).thenReturn(MockStreamSubscription());
    when(customEntityManager.entity(any)).thenReturn(null);

    when(
      fishingSpotManager.addTypedListener(
        onAdd: anyNamed("onAdd"),
        onUpdate: anyNamed("onUpdate"),
        onDelete: anyNamed("onDelete"),
        onReset: anyNamed("onReset"),
      ),
    ).thenReturn(MockStreamSubscription());
    when(fishingSpotManager.entity(any)).thenReturn(null);

    when(
      gearManager.addTypedListener(
        onAdd: anyNamed("onAdd"),
        onUpdate: anyNamed("onUpdate"),
        onDelete: anyNamed("onDelete"),
        onReset: anyNamed("onReset"),
      ),
    ).thenReturn(MockStreamSubscription());
    when(gearManager.entity(any)).thenReturn(null);

    when(
      gpsTrailManager.addTypedListener(
        onAdd: anyNamed("onAdd"),
        onUpdate: anyNamed("onUpdate"),
        onDelete: anyNamed("onDelete"),
        onReset: anyNamed("onReset"),
      ),
    ).thenReturn(MockStreamSubscription());
    when(gpsTrailManager.entity(any)).thenReturn(null);

    when(
      methodManager.addTypedListener(
        onAdd: anyNamed("onAdd"),
        onUpdate: anyNamed("onUpdate"),
        onDelete: anyNamed("onDelete"),
        onReset: anyNamed("onReset"),
      ),
    ).thenReturn(MockStreamSubscription());
    when(methodManager.entity(any)).thenReturn(null);

    when(
      reportManager.addTypedListener(
        onAdd: anyNamed("onAdd"),
        onUpdate: anyNamed("onUpdate"),
        onDelete: anyNamed("onDelete"),
        onReset: anyNamed("onReset"),
      ),
    ).thenReturn(MockStreamSubscription());
    when(reportManager.entity(any)).thenReturn(null);

    when(
      speciesManager.addTypedListener(
        onAdd: anyNamed("onAdd"),
        onUpdate: anyNamed("onUpdate"),
        onDelete: anyNamed("onDelete"),
        onReset: anyNamed("onReset"),
      ),
    ).thenReturn(MockStreamSubscription());
    when(speciesManager.entity(any)).thenReturn(null);

    when(
      tripManager.addTypedListener(
        onAdd: anyNamed("onAdd"),
        onUpdate: anyNamed("onUpdate"),
        onDelete: anyNamed("onDelete"),
        onReset: anyNamed("onReset"),
      ),
    ).thenReturn(MockStreamSubscription());

    when(userPreferenceManager.themeMode).thenReturn(ThemeMode.light);

    when(
      waterClarityManager.addTypedListener(
        onAdd: anyNamed("onAdd"),
        onUpdate: anyNamed("onUpdate"),
        onDelete: anyNamed("onDelete"),
        onReset: anyNamed("onReset"),
      ),
    ).thenReturn(MockStreamSubscription());
    when(waterClarityManager.entity(any)).thenReturn(null);

    Testable.additionalLocalizations = [
      const SfLocalizationsOverrideDelegate(),
      ...AnglersLogLocalizations.localizationsDelegates,
    ];
    Testable.additionalLocales = AnglersLogLocalizations.supportedLocales;
  }
}
