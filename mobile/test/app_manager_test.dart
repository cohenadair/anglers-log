import 'package:mobile/app_manager.dart';
import 'package:mobile/local_database_manager.dart';
import 'package:mobile/poll_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_managers.dart';
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
  MockTripManager tripManager = MockTripManager();

  @override
  MockWaterClarityManager waterClarityManager = MockWaterClarityManager();

  @override
  MockLocationMonitor locationMonitor = MockLocationMonitor();

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

  setUp(() async {
    await StubbedManagers.create();

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

    when(
      appManager.locationMonitor.initialize(),
    ).thenAnswer((_) => Future.value());
    when(appManager.anglerManager.init()).thenAnswer((_) => Future.value());
    when(
      appManager.baitCategoryManager.init(),
    ).thenAnswer((_) => Future.value());
    when(appManager.baitManager.init()).thenAnswer((_) => Future.value());
    when(
      appManager.bodyOfWaterManager.init(),
    ).thenAnswer((_) => Future.value());
    when(appManager.catchManager.init()).thenAnswer((_) => Future.value());
    when(
      appManager.customEntityManager.init(),
    ).thenAnswer((_) => Future.value());
    when(
      appManager.fishingSpotManager.init(),
    ).thenAnswer((_) => Future.value());
    when(appManager.gpsTrailManager.init()).thenAnswer((_) => Future.value());
    when(appManager.methodManager.init()).thenAnswer((_) => Future.value());
    when(appManager.reportManager.init()).thenAnswer((_) => Future.value());
    when(appManager.speciesManager.init()).thenAnswer((_) => Future.value());
    when(appManager.tripManager.init()).thenAnswer((_) => Future.value());
    when(
      appManager.waterClarityManager.init(),
    ).thenAnswer((_) => Future.value());
    when(
      appManager.backupRestoreManager.initialize(),
    ).thenAnswer((_) => Future.value());
    when(
      appManager.imageManager.initialize(),
    ).thenAnswer((_) => Future.value());
    when(
      appManager.notificationManager.initialize(),
    ).thenAnswer((_) => Future.value());

    stubRegionManager(MockRegionManager());
  });

  test("Initialize on startup", () async {
    await appManager.init(isStartup: true);
    verify(appManager.locationMonitor.initialize()).called(1);
    verify(appManager.backupRestoreManager.initialize()).called(1);
    verify(appManager.imageManager.initialize()).called(1);
    verify(appManager.notificationManager.initialize()).called(1);
    verify(pollManager.initialize()).called(1);
  });

  test("Initialize after startup", () async {
    await appManager.init(isStartup: false);
    verifyNever(appManager.locationMonitor.initialize());
    verifyNever(appManager.backupRestoreManager.initialize());
    verifyNever(appManager.imageManager.initialize());
    verifyNever(appManager.notificationManager.initialize());
    verifyNever(pollManager.initialize());
  });
}
