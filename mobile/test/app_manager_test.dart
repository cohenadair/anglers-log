import 'package:mobile/app_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'mocks/mocks.mocks.dart';

class TestAppManager extends AppManager {
  @override
  MockAnglerManager anglerManager = MockAnglerManager();

  @override
  MockBaitCategoryManager baitCategoryManager = MockBaitCategoryManager();

  @override
  MockBaitManager baitManager = MockBaitManager();

  @override
  MockBodyOfWaterManager bodyOfWaterManager = MockBodyOfWaterManager();

  @override
  MockCatchManager catchManager = MockCatchManager();

  @override
  MockCustomEntityManager customEntityManager = MockCustomEntityManager();

  @override
  MockFishingSpotManager fishingSpotManager = MockFishingSpotManager();

  @override
  MockGearManager gearManager = MockGearManager();

  @override
  MockGpsTrailManager gpsTrailManager = MockGpsTrailManager();

  @override
  MockMethodManager methodManager = MockMethodManager();

  @override
  MockPollManager pollManager = MockPollManager();

  @override
  MockReportManager reportManager = MockReportManager();

  @override
  MockSpeciesManager speciesManager = MockSpeciesManager();

  @override
  MockTimeManager timeManager = MockTimeManager();

  @override
  MockTripManager tripManager = MockTripManager();

  @override
  MockWaterClarityManager waterClarityManager = MockWaterClarityManager();

  @override
  MockLocationMonitor locationMonitor = MockLocationMonitor();

  @override
  MockPropertiesManager propertiesManager = MockPropertiesManager();

  @override
  MockSubscriptionManager subscriptionManager = MockSubscriptionManager();

  @override
  MockLocalDatabaseManager localDatabaseManager = MockLocalDatabaseManager();

  @override
  MockUserPreferenceManager userPreferenceManager = MockUserPreferenceManager();

  @override
  MockBackupRestoreManager backupRestoreManager = MockBackupRestoreManager();

  @override
  MockImageManager imageManager = MockImageManager();
}

void main() {
  late TestAppManager appManager;

  setUp(() {
    appManager = TestAppManager();

    when(appManager.locationMonitor.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.propertiesManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.subscriptionManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.localDatabaseManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.userPreferenceManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.anglerManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.baitCategoryManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.baitManager.initialize()).thenAnswer((_) => Future.value());
    when(appManager.bodyOfWaterManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.catchManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.customEntityManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.fishingSpotManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.gpsTrailManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.methodManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.pollManager.initialize()).thenAnswer((_) => Future.value());
    when(appManager.reportManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.speciesManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.tripManager.initialize()).thenAnswer((_) => Future.value());
    when(appManager.waterClarityManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.backupRestoreManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.imageManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.timeManager.initialize()).thenAnswer((_) => Future.value());
  });

  test("Initialize on startup", () async {
    await appManager.initialize(isStartup: true);
    verify(appManager.locationMonitor.initialize()).called(1);
    verify(appManager.pollManager.initialize()).called(1);
    verify(appManager.propertiesManager.initialize()).called(1);
    verify(appManager.subscriptionManager.initialize()).called(1);
    verify(appManager.backupRestoreManager.initialize()).called(1);
    verify(appManager.imageManager.initialize()).called(1);
  });

  test("Initialize after startup", () async {
    await appManager.initialize(isStartup: false);
    verifyNever(appManager.locationMonitor.initialize());
    verifyNever(appManager.pollManager.initialize());
    verifyNever(appManager.propertiesManager.initialize());
    verifyNever(appManager.subscriptionManager.initialize());
    verifyNever(appManager.backupRestoreManager.initialize());
    verifyNever(appManager.imageManager.initialize());
  });
}
