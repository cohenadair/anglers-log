import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
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
import 'package:mobile/time_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/wrappers/file_picker_wrapper.dart';
import 'package:mobile/wrappers/image_compress_wrapper.dart';
import 'package:mobile/wrappers/image_picker_wrapper.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:mobile/wrappers/mail_sender_wrapper.dart';
import 'package:mobile/wrappers/package_info_wrapper.dart';
import 'package:mobile/wrappers/path_provider_wrapper.dart';
import 'package:mobile/wrappers/permission_handler_wrapper.dart';
import 'package:mobile/wrappers/photo_manager_wrapper.dart';
import 'package:mobile/wrappers/url_launcher_wrapper.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

class MockBaitCategoryManager extends Mock implements BaitCategoryManager {}

class MockBaitManager extends Mock implements BaitManager {}

class MockDatabase extends Mock implements Database {}

class MockDataManager extends Mock implements DataManager {}

class MockCatchManager extends Mock implements CatchManager {}

class MockComparisonReportManager extends Mock
    implements ComparisonReportManager {}

class MockCustomEntityManager extends Mock implements CustomEntityManager {}

class MockFishingSpotManager extends Mock implements FishingSpotManager {}

class MockImageManager extends Mock implements ImageManager {}

class MockLocationMonitor extends Mock implements LocationMonitor {}

class MockPreferencesManager extends Mock implements PreferencesManager {}

class MockPropertiesManager extends Mock implements PropertiesManager {}

class MockSpeciesManager extends Mock implements SpeciesManager {}

class MockSummaryReportManager extends Mock implements SummaryReportManager {}

class MockTimeManager extends Mock implements TimeManager {}

class MockTripManager extends Mock implements TripManager {}

class MockFilePickerWrapper extends Mock implements FilePickerWrapper {}

class MockImageCompressWrapper extends Mock implements ImageCompressWrapper {}

class MockImagePickerWrapper extends Mock implements ImagePickerWrapper {}

class MockIoWrapper extends Mock implements IoWrapper {}

class MockMailSenderWrapper extends Mock implements MailSenderWrapper {}

class MockPackageInfoWrapper extends Mock implements PackageInfoWrapper {}

class MockPathProviderWrapper extends Mock implements PathProviderWrapper {}

class MockPermissionHandlerWrapper extends Mock
    implements PermissionHandlerWrapper {}

class MockPhotoManagerWrapper extends Mock implements PhotoManagerWrapper {}

class MockUrlLauncherWrapper extends Mock implements UrlLauncherWrapper {}

class MockAppManager extends Mock implements AppManager {
  MockBaitCategoryManager mockBaitCategoryManager;
  MockBaitManager mockBaitManager;
  MockDataManager mockDataManager;
  MockCatchManager mockCatchManager;
  MockComparisonReportManager mockComparisonReportManager;
  MockCustomEntityManager mockCustomEntityManager;
  MockFishingSpotManager mockFishingSpotManager;
  MockImageManager mockImageManager;
  MockLocationMonitor mockLocationMonitor;
  MockPreferencesManager mockPreferencesManager;
  MockPropertiesManager mockPropertiesManager;
  MockSpeciesManager mockSpeciesManager;
  MockSummaryReportManager mockSummaryReportManager;
  MockTimeManager mockTimeManager;
  MockTripManager mockTripManager;

  MockFilePickerWrapper mockFilePickerWrapper;
  MockImageCompressWrapper mockImageCompressWrapper;
  MockImagePickerWrapper mockImagePickerWrapper;
  MockIoWrapper mockIoWrapper;
  MockMailSenderWrapper mockMailSenderWrapper;
  MockPackageInfoWrapper mockPackageInfoWrapper;
  MockPathProviderWrapper mockPathProviderWrapper;
  MockPermissionHandlerWrapper mockPermissionHandlerWrapper;
  MockPhotoManagerWrapper mockPhotoManagerWrapper;
  MockUrlLauncherWrapper mockUrlLauncherWrapper;

  MockAppManager({
    bool mockBaitCategoryManager = false,
    bool mockBaitManager = false,
    bool mockDataManager = false,
    bool mockCatchManager = false,
    bool mockComparisonReportManager = false,
    bool mockCustomEntityManager = false,
    bool mockCustomEntityValueManager = false,
    bool mockFishingSpotManager = false,
    bool mockImageManager = false,
    bool mockLocationMonitor = false,
    bool mockPreferencesManager = false,
    bool mockPropertiesManager = false,
    bool mockSpeciesManager = false,
    bool mockSummaryReportManager = false,
    bool mockTimeManager = false,
    bool mockTripManager = false,
    bool mockFilePickerWrapper = false,
    bool mockImageCompressWrapper = false,
    bool mockImagePickerWrapper = false,
    bool mockIoWrapper = false,
    bool mockMailSenderWrapper = false,
    bool mockPackageInfoWrapper = false,
    bool mockPathProviderWrapper = false,
    bool mockPermissionHandlerWrapper = false,
    bool mockPhotoManagerWrapper = false,
    bool mockUrlLauncherWrapper = false,
  }) {
    if (mockBaitCategoryManager) {
      this.mockBaitCategoryManager = MockBaitCategoryManager();
      when(baitCategoryManager).thenReturn(this.mockBaitCategoryManager);
    }

    if (mockBaitManager) {
      this.mockBaitManager = MockBaitManager();
      when(baitManager).thenReturn(this.mockBaitManager);
    }

    if (mockDataManager) {
      this.mockDataManager = MockDataManager();
      when(dataManager).thenReturn(this.mockDataManager);
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

    if (mockLocationMonitor) {
      this.mockLocationMonitor = MockLocationMonitor();
      when(locationMonitor).thenReturn(this.mockLocationMonitor);
    }

    if (mockPreferencesManager) {
      this.mockPreferencesManager = MockPreferencesManager();
      when(preferencesManager).thenReturn(this.mockPreferencesManager);
    }

    if (mockPropertiesManager) {
      this.mockPropertiesManager = MockPropertiesManager();
      when(propertiesManager).thenReturn(this.mockPropertiesManager);
    }

    if (mockSpeciesManager) {
      this.mockSpeciesManager = MockSpeciesManager();
      when(speciesManager).thenReturn(this.mockSpeciesManager);
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

    if (mockFilePickerWrapper) {
      this.mockFilePickerWrapper = MockFilePickerWrapper();
      when(filePickerWrapper).thenReturn(this.mockFilePickerWrapper);
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

    if (mockMailSenderWrapper) {
      this.mockMailSenderWrapper = MockMailSenderWrapper();
      when(mailSenderWrapper).thenReturn(this.mockMailSenderWrapper);
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
