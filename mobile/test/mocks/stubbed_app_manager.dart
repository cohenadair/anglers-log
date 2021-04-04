import 'package:flutter/material.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mockito/mockito.dart';

import 'mocks.dart';
import 'mocks.mocks.dart';

class StubbedAppManager {
  MockAppManager app = MockAppManager();

  MockAppPreferenceManager appPreferenceManager = MockAppPreferenceManager();
  MockAuthManager authManager = MockAuthManager();
  MockBaitCategoryManager baitCategoryManager = MockBaitCategoryManager();
  MockBaitManager baitManager = MockBaitManager();
  MockCatchManager catchManager = MockCatchManager();
  MockComparisonReportManager comparisonReportManager =
      MockComparisonReportManager();
  MockCustomEntityManager customEntityManager = MockCustomEntityManager();
  MockFishingSpotManager fishingSpotManager = MockFishingSpotManager();
  MockImageManager imageManager = MockImageManager();
  MockLocalDatabaseManager localDatabaseManager = MockLocalDatabaseManager();
  MockLocationMonitor locationMonitor = MockLocationMonitor();
  MockPropertiesManager propertiesManager = MockPropertiesManager();
  MockSpeciesManager speciesManager = MockSpeciesManager();
  MockSubscriptionManager subscriptionManager = MockSubscriptionManager();
  MockSummaryReportManager summaryReportManager = MockSummaryReportManager();
  MockTimeManager timeManager = MockTimeManager();
  MockTripManager tripManager = MockTripManager();
  MockUserPreferenceManager userPreferenceManager = MockUserPreferenceManager();

  MockFilePickerWrapper filePickerWrapper = MockFilePickerWrapper();
  MockFirebaseAuthWrapper firebaseAuthWrapper = MockFirebaseAuthWrapper();
  MockFirebaseStorageWrapper firebaseStorageWrapper =
      MockFirebaseStorageWrapper();
  MockFirebaseWrapper firebaseWrapper = MockFirebaseWrapper();
  MockFirestoreWrapper firestoreWrapper = MockFirestoreWrapper();
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
  MockUrlLauncherWrapper urlLauncherWrapper = MockUrlLauncherWrapper();

  StubbedAppManager() {
    when(app.appPreferenceManager).thenReturn(appPreferenceManager);
    when(app.authManager).thenReturn(authManager);
    when(app.baitCategoryManager).thenReturn(baitCategoryManager);
    when(app.baitManager).thenReturn(baitManager);
    when(app.catchManager).thenReturn(catchManager);
    when(app.comparisonReportManager).thenReturn(comparisonReportManager);
    when(app.customEntityManager).thenReturn(customEntityManager);
    when(app.fishingSpotManager).thenReturn(fishingSpotManager);
    when(app.imageManager).thenReturn(imageManager);
    when(app.localDatabaseManager).thenReturn(localDatabaseManager);
    when(app.locationMonitor).thenReturn(locationMonitor);
    when(app.propertiesManager).thenReturn(propertiesManager);
    when(app.speciesManager).thenReturn(speciesManager);
    when(app.subscriptionManager).thenReturn(subscriptionManager);
    when(app.summaryReportManager).thenReturn(summaryReportManager);
    when(app.timeManager).thenReturn(timeManager);
    when(app.tripManager).thenReturn(tripManager);
    when(app.userPreferenceManager).thenReturn(userPreferenceManager);
    when(app.filePickerWrapper).thenReturn(filePickerWrapper);
    when(app.firebaseAuthWrapper).thenReturn(firebaseAuthWrapper);
    when(app.firebaseStorageWrapper).thenReturn(firebaseStorageWrapper);
    when(app.firebaseWrapper).thenReturn(firebaseWrapper);
    when(app.firestoreWrapper).thenReturn(firestoreWrapper);
    when(app.httpWrapper).thenReturn(httpWrapper);
    when(app.imageCompressWrapper).thenReturn(imageCompressWrapper);
    when(app.imagePickerWrapper).thenReturn(imagePickerWrapper);
    when(app.ioWrapper).thenReturn(ioWrapper);
    when(app.packageInfoWrapper).thenReturn(packageInfoWrapper);
    when(app.pathProviderWrapper).thenReturn(pathProviderWrapper);
    when(app.permissionHandlerWrapper).thenReturn(permissionHandlerWrapper);
    when(app.photoManagerWrapper).thenReturn(photoManagerWrapper);
    when(app.purchasesWrapper).thenReturn(purchasesWrapper);
    when(app.servicesWrapper).thenReturn(servicesWrapper);
    when(app.urlLauncherWrapper).thenReturn(urlLauncherWrapper);

    // Default to the current time.
    stubCurrentTime(DateTime.now());

    // Setup default listener stubs on EntityListener classes, since
    // addSimpleListener is called often in tests, but rarely actually used.
    when(baitCategoryManager.addSimpleListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
    )).thenReturn(SimpleEntityListener());
    when(baitCategoryManager.entity(any)).thenReturn(null);

    when(baitManager.addSimpleListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
    )).thenReturn(SimpleEntityListener());
    when(baitManager.entity(any)).thenReturn(null);

    when(catchManager.addSimpleListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
    )).thenReturn(SimpleEntityListener());
    when(catchManager.entity(any)).thenReturn(null);

    when(comparisonReportManager.addSimpleListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
    )).thenReturn(SimpleEntityListener());
    when(comparisonReportManager.entity(any)).thenReturn(null);

    when(customEntityManager.addSimpleListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
    )).thenReturn(SimpleEntityListener());
    when(customEntityManager.entity(any)).thenReturn(null);

    when(fishingSpotManager.addSimpleListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
    )).thenReturn(SimpleEntityListener());
    when(fishingSpotManager.entity(any)).thenReturn(null);

    when(speciesManager.addSimpleListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
    )).thenReturn(SimpleEntityListener());
    when(speciesManager.entity(any)).thenReturn(null);

    when(summaryReportManager.addSimpleListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
    )).thenReturn(SimpleEntityListener());
    when(summaryReportManager.entity(any)).thenReturn(null);
  }

  void stubCurrentTime(DateTime now) {
    when(timeManager.currentDateTime).thenReturn(now);
    when(timeManager.currentTime).thenReturn(TimeOfDay.fromDateTime(now));
    when(timeManager.msSinceEpoch).thenReturn(now.millisecondsSinceEpoch);
  }
}
