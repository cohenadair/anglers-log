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
import 'package:mobile/wrappers/image_compress_wrapper.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:mobile/wrappers/path_provider_wrapper.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

class MockBaitCategoryManager extends Mock implements BaitCategoryManager {}
class MockBaitManager extends Mock implements BaitManager {}
class MockDatabase extends Mock implements Database {}
class MockDataManager extends Mock implements DataManager {}
class MockCatchManager extends Mock implements CatchManager {}
class MockComparisonReportManager extends Mock implements 
    ComparisonReportManager {}
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

class MockIoWrapper extends Mock implements IoWrapper {}
class MockImageCompressWrapper extends Mock implements ImageCompressWrapper {}
class MockPathProviderWrapper extends Mock implements PathProviderWrapper {}

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

  MockIoWrapper mockIoWrapper;
  MockImageCompressWrapper mockImageCompressWrapper;
  MockPathProviderWrapper mockPathProviderWrapper;

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
    bool mockIoWrapper = false,
    bool mockImageCompressWrapper = false,
    bool mockPathProviderWrapper = false,
  }) {
    if (mockBaitCategoryManager) {
      this.mockBaitCategoryManager = MockBaitCategoryManager();
      when(baitCategoryManager).thenReturn(this.mockBaitCategoryManager);
    }

    if (mockBaitManager) {
      this.mockBaitManager = MockBaitManager();
      when(this.baitManager).thenReturn(this.mockBaitManager);
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

    if (mockIoWrapper) {
      this.mockIoWrapper = MockIoWrapper();
      when(ioWrapper).thenReturn(this.mockIoWrapper);
    }

    if (mockImageCompressWrapper) {
      this.mockImageCompressWrapper = MockImageCompressWrapper();
      when(imageCompressWrapper).thenReturn(this.mockImageCompressWrapper);
    }

    if (mockPathProviderWrapper) {
      this.mockPathProviderWrapper = MockPathProviderWrapper();
      when(pathProviderWrapper).thenReturn(this.mockPathProviderWrapper);
    }
  }

  void stubCurrentTime(DateTime now) {
    when(this.mockTimeManager.currentDateTime).thenReturn(now);
    when(this.mockTimeManager.currentTime)
        .thenReturn(TimeOfDay.fromDateTime(now));
    when(this.mockTimeManager.msSinceEpoch)
        .thenReturn(now.millisecondsSinceEpoch);
  }
}