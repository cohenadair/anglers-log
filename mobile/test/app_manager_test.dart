import 'package:mobile/app_manager.dart';
import 'package:mobile/local_database_manager.dart';
import 'package:mobile/poll_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'mocks/mocks.mocks.dart';
import 'test_utils.dart';

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
  MockBackupRestoreManager backupRestoreManager = MockBackupRestoreManager();

  @override
  MockImageManager imageManager = MockImageManager();

  @override
  MockNotificationManager notificationManager = MockNotificationManager();
}

void main() {
  late TestAppManager appManager;
  late MockPollManager pollManager;

  setUp(() {
    appManager = TestAppManager();

    var localDatabaseManager = MockLocalDatabaseManager();
    when(localDatabaseManager.init()).thenAnswer((_) => Future.value());
    LocalDatabaseManager.set(localDatabaseManager);

    var userPreferenceManager = MockUserPreferenceManager();
    when(userPreferenceManager.init()).thenAnswer((_) => Future.value());
    UserPreferenceManager.set(userPreferenceManager);

    pollManager = MockPollManager();
    when(pollManager.initialize()).thenAnswer((_) => Future.value());
    PollManager.set(pollManager);

    when(appManager.locationMonitor.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.propertiesManager.initialize())
        .thenAnswer((_) => Future.value());
    when(appManager.subscriptionManager.initialize())
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
    when(appManager.notificationManager.initialize())
        .thenAnswer((_) => Future.value());

    stubRegionManager(MockRegionManager());
  });

  test("Initialize on startup", () async {
    await appManager.init(isStartup: true);
    verify(appManager.locationMonitor.initialize()).called(1);
    verify(appManager.propertiesManager.initialize()).called(1);
    verify(appManager.subscriptionManager.initialize()).called(1);
    verify(appManager.backupRestoreManager.initialize()).called(1);
    verify(appManager.imageManager.initialize()).called(1);
    verify(appManager.notificationManager.initialize()).called(1);
    verify(pollManager.initialize()).called(1);
  });

  test("Initialize after startup", () async {
    await appManager.init(isStartup: false);
    verifyNever(appManager.locationMonitor.initialize());
    verifyNever(appManager.propertiesManager.initialize());
    verifyNever(appManager.subscriptionManager.initialize());
    verifyNever(appManager.backupRestoreManager.initialize());
    verifyNever(appManager.imageManager.initialize());
    verifyNever(appManager.notificationManager.initialize());
    verifyNever(pollManager.initialize());
  });
}
