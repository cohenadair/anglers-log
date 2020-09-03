import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/custom_comparison_report_manager.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/custom_entity_value_manager.dart';
import 'package:mobile/custom_summary_report_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/properties_manager.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

class MockBaitCategoryManager extends Mock implements BaitCategoryManager {}
class MockBaitManager extends Mock implements BaitManager {}
class MockDatabase extends Mock implements Database {}
class MockDataManager extends Mock implements DataManager {}
class MockCatchManager extends Mock implements CatchManager {}
class MockCustomComparisonReportManager extends Mock implements
    CustomComparisonReportManager {}
class MockCustomEntityManager extends Mock implements CustomEntityManager {}
class MockCustomEntityValueManager extends Mock implements
    CustomEntityValueManager {}
class MockCustomSummaryReportManager extends Mock implements
    CustomSummaryReportManager {}
class MockFishingSpotManager extends Mock implements FishingSpotManager {}
class MockImageManager extends Mock implements ImageManager {}
class MockLocationMonitor extends Mock implements LocationMonitor {}
class MockPreferencesManager extends Mock implements PreferencesManager {}
class MockPropertiesManager extends Mock implements PropertiesManager {}
class MockSpeciesManager extends Mock implements SpeciesManager {}
class MockTripManager extends Mock implements TripManager {}

class MockAppManager extends Mock implements AppManager {
  MockBaitCategoryManager mockBaitCategoryManager;
  MockBaitManager mockBaitManager;
  MockDataManager mockDataManager;
  MockCatchManager mockCatchManager;
  MockCustomComparisonReportManager mockCustomComparisonReportManager;
  MockCustomEntityManager mockCustomEntityManager;
  MockCustomEntityValueManager mockCustomEntityValueManager;
  MockCustomSummaryReportManager mockCustomSummaryReportManager;
  MockFishingSpotManager mockFishingSpotManager;
  MockImageManager mockImageManager;
  MockLocationMonitor mockLocationMonitor;
  MockPreferencesManager mockPreferencesManager;
  MockPropertiesManager mockPropertiesManager;
  MockSpeciesManager mockSpeciesManager;
  MockTripManager mockTripManager;

  MockAppManager({
    bool mockBaitCategoryManager = false,
    bool mockBaitManager = false,
    bool mockDataManager = false,
    bool mockCatchManager = false,
    bool mockCustomComparisonReportManager = false,
    bool mockCustomEntityManager = false,
    bool mockCustomEntityValueManager = false,
    bool mockCustomSummaryReportManager = false,
    bool mockFishingSpotManager = false,
    bool mockImageManager = false,
    bool mockLocationMonitor = false,
    bool mockPreferencesManager = false,
    bool mockPropertiesManager = false,
    bool mockSpeciesManager = false,
    bool mockTripManager = false,
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

    if (mockCustomComparisonReportManager) {
      this.mockCustomComparisonReportManager =
          MockCustomComparisonReportManager();
      when(customComparisonReportManager)
          .thenReturn(this.mockCustomComparisonReportManager);
    }

    if (mockCustomEntityManager) {
      this.mockCustomEntityManager = MockCustomEntityManager();
      when(customEntityManager).thenReturn(this.mockCustomEntityManager);
    }

    if (mockCustomEntityValueManager) {
      this.mockCustomEntityValueManager = MockCustomEntityValueManager();
      when(customEntityValueManager)
          .thenReturn(this.mockCustomEntityValueManager);
    }

    if (mockCustomSummaryReportManager) {
      this.mockCustomSummaryReportManager = MockCustomSummaryReportManager();
      when(customSummaryReportManager)
          .thenReturn(this.mockCustomSummaryReportManager);
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

    if (mockTripManager) {
      this.mockTripManager = MockTripManager();
      when(tripManager).thenReturn(this.mockTripManager);
    }
  }
}