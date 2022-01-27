import 'package:flutter/material.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mockito/mockito.dart';

import 'mocks.dart';
import 'mocks.mocks.dart';

class StubbedAppManager {
  MockAppManager app = MockAppManager();

  MockAnglerManager anglerManager = MockAnglerManager();
  MockBackupRestoreManager backupRestoreManager = MockBackupRestoreManager();
  MockBaitCategoryManager baitCategoryManager = MockBaitCategoryManager();
  MockBaitManager baitManager = MockBaitManager();
  MockBodyOfWaterManager bodyOfWaterManager = MockBodyOfWaterManager();
  MockCatchManager catchManager = MockCatchManager();
  MockCustomEntityManager customEntityManager = MockCustomEntityManager();
  MockFishingSpotManager fishingSpotManager = MockFishingSpotManager();
  MockImageManager imageManager = MockImageManager();
  MockLocalDatabaseManager localDatabaseManager = MockLocalDatabaseManager();
  MockLocationMonitor locationMonitor = MockLocationMonitor();
  MockMethodManager methodManager = MockMethodManager();
  MockPropertiesManager propertiesManager = MockPropertiesManager();
  MockReportManager reportManager = MockReportManager();
  MockSpeciesManager speciesManager = MockSpeciesManager();
  MockSubscriptionManager subscriptionManager = MockSubscriptionManager();
  MockTimeManager timeManager = MockTimeManager();
  MockTripManager tripManager = MockTripManager();
  MockUserPreferenceManager userPreferenceManager = MockUserPreferenceManager();
  MockWaterClarityManager waterClarityManager = MockWaterClarityManager();

  MockDriveApiWrapper driveApiWrapper = MockDriveApiWrapper();
  MockFilePickerWrapper filePickerWrapper = MockFilePickerWrapper();
  MockGoogleSignInWrapper googleSignInWrapper = MockGoogleSignInWrapper();
  MockHttpWrapper httpWrapper = MockHttpWrapper();
  MockImageCompressWrapper imageCompressWrapper = MockImageCompressWrapper();
  MockImagePickerWrapper imagePickerWrapper = MockImagePickerWrapper();
  MockIoWrapper ioWrapper = MockIoWrapper();
  MockPackageInfoWrapper packageInfoWrapper = MockPackageInfoWrapper();
  MockPathProviderWrapper pathProviderWrapper = MockPathProviderWrapper();
  MockPermissionHandlerWrapper permissionHandlerWrapper =
      MockPermissionHandlerWrapper();
  MockPhotoManagerWrapper photoManagerWrapper = MockPhotoManagerWrapper();
  MockPurchasesWrapper purchasesWrapper = MockPurchasesWrapper();
  MockServicesWrapper servicesWrapper = MockServicesWrapper();
  MockSharedPreferencesWrapper sharedPreferencesWrapper =
      MockSharedPreferencesWrapper();
  MockUrlLauncherWrapper urlLauncherWrapper = MockUrlLauncherWrapper();

  StubbedAppManager() {
    when(app.anglerManager).thenReturn(anglerManager);
    when(app.backupRestoreManager).thenReturn(backupRestoreManager);
    when(app.baitCategoryManager).thenReturn(baitCategoryManager);
    when(app.baitManager).thenReturn(baitManager);
    when(app.bodyOfWaterManager).thenReturn(bodyOfWaterManager);
    when(app.catchManager).thenReturn(catchManager);
    when(app.customEntityManager).thenReturn(customEntityManager);
    when(app.fishingSpotManager).thenReturn(fishingSpotManager);
    when(app.imageManager).thenReturn(imageManager);
    when(app.localDatabaseManager).thenReturn(localDatabaseManager);
    when(app.locationMonitor).thenReturn(locationMonitor);
    when(app.methodManager).thenReturn(methodManager);
    when(app.propertiesManager).thenReturn(propertiesManager);
    when(app.reportManager).thenReturn(reportManager);
    when(app.speciesManager).thenReturn(speciesManager);
    when(app.subscriptionManager).thenReturn(subscriptionManager);
    when(app.timeManager).thenReturn(timeManager);
    when(app.tripManager).thenReturn(tripManager);
    when(app.userPreferenceManager).thenReturn(userPreferenceManager);
    when(app.waterClarityManager).thenReturn(waterClarityManager);
    when(app.driveApiWrapper).thenReturn(driveApiWrapper);
    when(app.filePickerWrapper).thenReturn(filePickerWrapper);
    when(app.googleSignInWrapper).thenReturn(googleSignInWrapper);
    when(app.httpWrapper).thenReturn(httpWrapper);
    when(app.imageCompressWrapper).thenReturn(imageCompressWrapper);
    when(app.imagePickerWrapper).thenReturn(imagePickerWrapper);
    when(app.ioWrapper).thenReturn(ioWrapper);
    when(app.packageInfoWrapper).thenReturn(packageInfoWrapper);
    when(app.pathProviderWrapper).thenReturn(pathProviderWrapper);
    when(app.permissionHandlerWrapper).thenReturn(permissionHandlerWrapper);
    when(app.photoManagerWrapper).thenReturn(photoManagerWrapper);
    when(app.purchasesWrapper).thenReturn(purchasesWrapper);
    when(app.sharedPreferencesWrapper).thenReturn(sharedPreferencesWrapper);
    when(app.servicesWrapper).thenReturn(servicesWrapper);
    when(app.urlLauncherWrapper).thenReturn(urlLauncherWrapper);

    // Default to the current time.
    stubCurrentTime(DateTime.now());

    // Setup default listener stubs on EntityListener classes, since
    // addTypedListener is called often in tests, but rarely actually used.
    when(anglerManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(EntityListener());

    // TODO: Don't stub these by default; lead to unnecessary investigations on
    //  failed tests.
    when(anglerManager.entity(any)).thenReturn(null);

    when(baitCategoryManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(EntityListener());
    when(baitCategoryManager.entity(any)).thenReturn(null);

    when(baitManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(EntityListener());
    when(baitManager.entity(any)).thenReturn(null);
    when(baitManager.list(any)).thenReturn([]);

    when(bodyOfWaterManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(EntityListener());
    when(bodyOfWaterManager.entity(any)).thenReturn(null);
    when(bodyOfWaterManager.list(any)).thenReturn([]);

    when(catchManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(EntityListener());
    when(catchManager.entity(any)).thenReturn(null);

    when(customEntityManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(EntityListener());
    when(customEntityManager.entity(any)).thenReturn(null);

    when(fishingSpotManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(EntityListener());
    when(fishingSpotManager.entity(any)).thenReturn(null);

    when(methodManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(EntityListener());
    when(methodManager.entity(any)).thenReturn(null);

    when(reportManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(EntityListener());
    when(reportManager.entity(any)).thenReturn(null);

    when(speciesManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(EntityListener());
    when(speciesManager.entity(any)).thenReturn(null);

    when(tripManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(EntityListener());

    when(waterClarityManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(EntityListener());
    when(waterClarityManager.entity(any)).thenReturn(null);
  }

  void stubCurrentTime(DateTime now) {
    when(timeManager.currentDateTime).thenReturn(now);
    when(timeManager.currentTime).thenReturn(TimeOfDay.fromDateTime(now));
    when(timeManager.msSinceEpoch).thenReturn(now.millisecondsSinceEpoch);
  }
}
