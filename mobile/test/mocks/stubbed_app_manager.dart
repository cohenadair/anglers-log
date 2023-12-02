import 'package:flutter/material.dart';
import 'package:mobile/time_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:quiver/strings.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

import '../test_utils.dart';
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
  MockGearManager gearManager = MockGearManager();
  MockGpsTrailManager gpsTrailManager = MockGpsTrailManager();
  MockImageManager imageManager = MockImageManager();
  MockLocalDatabaseManager localDatabaseManager = MockLocalDatabaseManager();
  MockLocationMonitor locationMonitor = MockLocationMonitor();
  MockMethodManager methodManager = MockMethodManager();
  MockPollManager pollManager = MockPollManager();
  MockPropertiesManager propertiesManager = MockPropertiesManager();
  MockReportManager reportManager = MockReportManager();
  MockSpeciesManager speciesManager = MockSpeciesManager();
  MockSubscriptionManager subscriptionManager = MockSubscriptionManager();
  MockTimeManager timeManager = MockTimeManager();
  MockTripManager tripManager = MockTripManager();
  MockUserPreferenceManager userPreferenceManager = MockUserPreferenceManager();
  MockWaterClarityManager waterClarityManager = MockWaterClarityManager();

  MockCsvWrapper csvWrapper = MockCsvWrapper();
  MockDeviceInfoWrapper deviceInfoWrapper = MockDeviceInfoWrapper();
  MockDriveApiWrapper driveApiWrapper = MockDriveApiWrapper();
  MockExifWrapper exifWrapper = MockExifWrapper();
  MockFilePickerWrapper filePickerWrapper = MockFilePickerWrapper();
  MockGeolocatorWrapper geolocatorWrapper = MockGeolocatorWrapper();
  MockGoogleSignInWrapper googleSignInWrapper = MockGoogleSignInWrapper();
  MockHttpWrapper httpWrapper = MockHttpWrapper();
  MockImageCompressWrapper imageCompressWrapper = MockImageCompressWrapper();
  MockImagePickerWrapper imagePickerWrapper = MockImagePickerWrapper();
  MockInAppReviewWrapper inAppReviewWrapper = MockInAppReviewWrapper();
  MockIoWrapper ioWrapper = MockIoWrapper();
  MockIsolatesWrapper isolatesWrapper = MockIsolatesWrapper();
  MockNativeTimeZoneWrapper timeZoneWrapper = MockNativeTimeZoneWrapper();
  MockPackageInfoWrapper packageInfoWrapper = MockPackageInfoWrapper();
  MockPathProviderWrapper pathProviderWrapper = MockPathProviderWrapper();
  MockPermissionHandlerWrapper permissionHandlerWrapper =
      MockPermissionHandlerWrapper();
  MockPhotoManagerWrapper photoManagerWrapper = MockPhotoManagerWrapper();
  MockPurchasesWrapper purchasesWrapper = MockPurchasesWrapper();
  MockServicesWrapper servicesWrapper = MockServicesWrapper();
  MockSharedPreferencesWrapper sharedPreferencesWrapper =
      MockSharedPreferencesWrapper();
  MockSharePlusWrapper sharePlusWrapper = MockSharePlusWrapper();
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
    when(app.gearManager).thenReturn(gearManager);
    when(app.gpsTrailManager).thenReturn(gpsTrailManager);
    when(app.imageManager).thenReturn(imageManager);
    when(app.localDatabaseManager).thenReturn(localDatabaseManager);
    when(app.locationMonitor).thenReturn(locationMonitor);
    when(app.methodManager).thenReturn(methodManager);
    when(app.pollManager).thenReturn(pollManager);
    when(app.propertiesManager).thenReturn(propertiesManager);
    when(app.reportManager).thenReturn(reportManager);
    when(app.speciesManager).thenReturn(speciesManager);
    when(app.subscriptionManager).thenReturn(subscriptionManager);
    when(app.timeManager).thenReturn(timeManager);
    when(app.tripManager).thenReturn(tripManager);
    when(app.userPreferenceManager).thenReturn(userPreferenceManager);
    when(app.waterClarityManager).thenReturn(waterClarityManager);
    when(app.csvWrapper).thenReturn(csvWrapper);
    when(app.deviceInfoWrapper).thenReturn(deviceInfoWrapper);
    when(app.driveApiWrapper).thenReturn(driveApiWrapper);
    when(app.exifWrapper).thenReturn(exifWrapper);
    when(app.filePickerWrapper).thenReturn(filePickerWrapper);
    when(app.geolocatorWrapper).thenReturn(geolocatorWrapper);
    when(app.googleSignInWrapper).thenReturn(googleSignInWrapper);
    when(app.httpWrapper).thenReturn(httpWrapper);
    when(app.imageCompressWrapper).thenReturn(imageCompressWrapper);
    when(app.imagePickerWrapper).thenReturn(imagePickerWrapper);
    when(app.inAppReviewWrapper).thenReturn(inAppReviewWrapper);
    when(app.ioWrapper).thenReturn(ioWrapper);
    when(app.isolatesWrapper).thenReturn(isolatesWrapper);
    when(app.nativeTimeZoneWrapper).thenReturn(timeZoneWrapper);
    when(app.packageInfoWrapper).thenReturn(packageInfoWrapper);
    when(app.pathProviderWrapper).thenReturn(pathProviderWrapper);
    when(app.permissionHandlerWrapper).thenReturn(permissionHandlerWrapper);
    when(app.photoManagerWrapper).thenReturn(photoManagerWrapper);
    when(app.purchasesWrapper).thenReturn(purchasesWrapper);
    when(app.sharedPreferencesWrapper).thenReturn(sharedPreferencesWrapper);
    when(app.sharePlusWrapper).thenReturn(sharePlusWrapper);
    when(app.servicesWrapper).thenReturn(servicesWrapper);
    when(app.urlLauncherWrapper).thenReturn(urlLauncherWrapper);

    // Default to the current time and time zone.
    stubCurrentTime(DateTime.now());

    // Setup default listener stubs on EntityListener classes, since
    // addTypedListener is called often in tests, but rarely actually used.
    when(anglerManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(MockStreamSubscription());

    when(anglerManager.entity(any)).thenReturn(null);

    when(baitCategoryManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(MockStreamSubscription());
    when(baitCategoryManager.entity(any)).thenReturn(null);

    when(baitManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(MockStreamSubscription());
    when(baitManager.entity(any)).thenReturn(null);
    when(baitManager.list(any)).thenReturn([]);

    when(bodyOfWaterManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(MockStreamSubscription());
    when(bodyOfWaterManager.entity(any)).thenReturn(null);
    when(bodyOfWaterManager.list(any)).thenReturn([]);

    when(catchManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(MockStreamSubscription());
    when(catchManager.entity(any)).thenReturn(null);

    when(customEntityManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(MockStreamSubscription());
    when(customEntityManager.entity(any)).thenReturn(null);

    when(fishingSpotManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(MockStreamSubscription());
    when(fishingSpotManager.entity(any)).thenReturn(null);

    when(gearManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(MockStreamSubscription());
    when(gearManager.entity(any)).thenReturn(null);

    when(gpsTrailManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(MockStreamSubscription());
    when(gpsTrailManager.entity(any)).thenReturn(null);

    when(methodManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(MockStreamSubscription());
    when(methodManager.entity(any)).thenReturn(null);

    when(reportManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(MockStreamSubscription());
    when(reportManager.entity(any)).thenReturn(null);

    when(speciesManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(MockStreamSubscription());
    when(speciesManager.entity(any)).thenReturn(null);

    when(tripManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(MockStreamSubscription());

    when(waterClarityManager.addTypedListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
      onReset: anyNamed("onReset"),
    )).thenReturn(MockStreamSubscription());
    when(waterClarityManager.entity(any)).thenReturn(null);
  }

  void stubCurrentTime(DateTime now, {String timeZone = defaultTimeZone}) {
    initializeTimeZones();

    var defaultLocation = getLocation(timeZone);
    var tzNow = TZDateTime.from(now, defaultLocation);
    when(timeManager.now(any)).thenReturn(tzNow);
    when(timeManager.currentDateTime).thenReturn(tzNow);
    when(timeManager.currentTime).thenReturn(TimeOfDay.fromDateTime(tzNow));
    when(timeManager.currentTimestamp).thenReturn(tzNow.millisecondsSinceEpoch);

    when(timeManager.currentLocation)
        .thenReturn(TimeZoneLocation.fromName(timeZone));
    when(timeManager.currentTimeZone).thenReturn(timeZone);
    when(timeManager.dateTime(any, any)).thenAnswer((invocation) {
      String? tz = invocation.positionalArguments.length == 2
          ? invocation.positionalArguments[1]
          : null;
      if (isEmpty(tz)) {
        tz = timeZone;
      }
      return TZDateTime.fromMillisecondsSinceEpoch(
          getLocation(tz!), invocation.positionalArguments[0]);
    });
    when(timeManager.toTZDateTime(any)).thenAnswer((invocation) =>
        TZDateTime.from(invocation.positionalArguments.first, defaultLocation));
  }
}
