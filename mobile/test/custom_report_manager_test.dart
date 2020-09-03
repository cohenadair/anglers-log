import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/custom_report_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/model/custom_report_bait.dart';
import 'package:mobile/model/custom_report_fishing_spot.dart';
import 'package:mobile/model/custom_report_species.dart';
import 'package:mobile/model/custom_summary_report.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

import 'mock_app_manager.dart';

class MockBatch extends Mock implements Batch {}
class MockCustomReportListener extends Mock implements
    EntityListener<CustomReport> {}

class TestCustomReportManager extends CustomReportManager {
  TestCustomReportManager(AppManager app) : super(app);

  @override
  CustomReport entityFromMap(Map<String, dynamic> map) =>
      CustomSummaryReport.fromMap(map);

  @override
  String get tableName => "test_custom_report";
}

void main() {
  MockAppManager appManager;

  SpeciesManager speciesManager;
  BaitManager baitManager;
  FishingSpotManager fishingSpotManager;

  TestCustomReportManager reportManager;
  MockCustomReportListener reportListener;

  setUp(() {
    // Setup mocks.
    appManager = MockAppManager(
      mockBaitCategoryManager: true,
      mockCatchManager: true,
      mockDataManager: true,
      mockCustomEntityValueManager: true,
    );
    when(appManager.mockDataManager.addListener(any)).thenAnswer((_) {});
    when(appManager.mockDataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockDataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockCustomEntityValueManager.setValues(any, any))
        .thenAnswer((_) => Future.value());

    reportListener = MockCustomReportListener();
    when(reportListener.onAddOrUpdate).thenReturn(() {});

    // Setup real objects.
    speciesManager = SpeciesManager(appManager);
    when(appManager.speciesManager).thenReturn(speciesManager);

    baitManager = BaitManager(appManager);
    when(appManager.baitManager).thenReturn(baitManager);

    fishingSpotManager = FishingSpotManager(appManager);
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);

    reportManager = TestCustomReportManager(appManager);
    reportManager.addListener(reportListener);
  });

  Future<void> awaitDataManagerDelete() async {
    await untilCalled(appManager.mockDataManager.delete(any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    ));
  }

  test("Initialize", () async {
    when(appManager.mockDataManager.fetchAll(reportManager.tableName))
        .thenAnswer((_) => Future.value([
          CustomSummaryReport(
            name: "Summary report",
            displayDateRangeId: DisplayDateRange.last7Days.id,
            entityType: EntityType.fishCatch,
          ).toMap(),
        ]));
    when(appManager.mockDataManager.fetchAll("custom_report_bait"))
        .thenAnswer((_) => Future.value([
          CustomReportBait(
            customReportId: "report_id_1",
            baitId: "bait_id_1",
          ).toMap(),
        ]));
    when(appManager.mockDataManager.fetchAll("custom_report_fishing_spot"))
        .thenAnswer((_) => Future.value([
          CustomReportFishingSpot(
            customReportId: "report_id_2",
            fishingSpotId: "fishing_spot_id_1",
          ).toMap(),
        ]));
    when(appManager.mockDataManager.fetchAll("custom_report_species"))
        .thenAnswer((_) => Future.value([
          CustomReportSpecies(
            customReportId: "report_id_3",
            speciesId: "species_id_1",
          ).toMap(),
        ]));
    await reportManager.initialize();
    expect(reportManager.baitIds("report_id_1").length, 1);
    expect(reportManager.fishingSpotIds("report_id_2").length, 1);
    expect(reportManager.speciesIds("report_id_3").length, 1);
    expect(reportManager.baitIds("report_id_3"), isEmpty);
    expect(reportManager.fishingSpotIds("report_id_1"), isEmpty);
    expect(reportManager.speciesIds("report_id_2"), isEmpty);
  });

  test("On species deleted, reports updated and listeners notified", () async {
    when(appManager.mockCatchManager.existsWith(
      speciesId: anyNamed("speciesId"),
    )).thenReturn(false);

    // Nothing to delete.
    when(appManager.mockDataManager.delete(any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(false));

    var species = Species(name: "Bass");
    await speciesManager.addOrUpdate(species);
    await speciesManager.delete(species);
    await awaitDataManagerDelete();
    verifyNever(reportListener.onAddOrUpdate);

    // Successful delete.
    when(appManager.mockDataManager.delete(any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(true));

    await speciesManager.addOrUpdate(species);
    await speciesManager.delete(species);
    await awaitDataManagerDelete();
    verify(reportListener.onAddOrUpdate).called(1);
  });

  test("On baits deleted, reports updated and listeners notified",
      () async
  {
    // Nothing to delete.
    when(appManager.mockDataManager.delete(any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(false));

    var bait = Bait(name: "Lure");
    await baitManager.addOrUpdate(bait);
    await baitManager.delete(bait);
    await awaitDataManagerDelete();
    verifyNever(reportListener.onAddOrUpdate);

    // Successful delete.
    when(appManager.mockDataManager.delete(any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(true));

    await baitManager.addOrUpdate(bait);
    await baitManager.delete(bait);
    await awaitDataManagerDelete();
    verify(reportListener.onAddOrUpdate).called(1);
  });

  test("On fishing spots deleted, reports updated and listeners notified",
      () async
  {
    // Nothing to delete.
    when(appManager.mockDataManager.delete(any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(false));

    var fishingSpot = FishingSpot(lat: 0.03, lng: 0.05);
    await fishingSpotManager.addOrUpdate(fishingSpot);
    await fishingSpotManager.delete(fishingSpot);
    await awaitDataManagerDelete();
    verifyNever(reportListener.onAddOrUpdate);

    // Successful delete.
    when(appManager.mockDataManager.delete(any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(true));

    await fishingSpotManager.addOrUpdate(fishingSpot);
    await fishingSpotManager.delete(fishingSpot);
    await awaitDataManagerDelete();
    verify(reportListener.onAddOrUpdate).called(1);
  });

  test("Add or update", () async {
    var batch = MockBatch();
    when(batch.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) {});
    when(batch.insert(any, any)).thenAnswer((_) {});
    when(appManager.mockDataManager.commitBatch(any)).thenAnswer((invocation) =>
        invocation.positionalArguments.first(batch));

    var report = CustomSummaryReport(
      name: "Report",
      entityType: EntityType.bait,
      displayDateRangeId: DisplayDateRange.last7Days.id,
    );

    // Don't add any mappings.
    await reportManager.addOrUpdate(report);
    expect(reportManager.species(report.id), isEmpty);
    expect(reportManager.baits(report.id), isEmpty);
    expect(reportManager.fishingSpots(report.id), isEmpty);

    // Update with some mappings.
    await reportManager.addOrUpdate(report,
      species: {
        Species(name: "Bass"),
        Species(name: "Trout"),
      },
      baits: {
        Bait(name: "Worm"),
      },
      fishingSpots: {
        FishingSpot(lat: 0.1, lng: 0.2),
        FishingSpot(lat: 0.3, lng: 0.4),
        FishingSpot(lat: 0.5, lng: 0.6),
      },
    );
    expect(reportManager.species(report.id).length, 2);
    expect(reportManager.baits(report.id).length, 1);
    expect(reportManager.fishingSpots(report.id).length, 3);

    // Update with no mappings removes existing mappings.
    await reportManager.addOrUpdate(report);
    expect(reportManager.species(report.id), isEmpty);
    expect(reportManager.baits(report.id), isEmpty);
    expect(reportManager.fishingSpots(report.id), isEmpty);
  });

  test("On database cleared, mappings are cleared", () async {
    // Setup real DataManager to initiate callback.
    var batch = MockBatch();
    when(batch.commit()).thenAnswer((_) => Future.value([]));
    when(batch.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) {});
    when(batch.insert(any, any)).thenAnswer((_) {});

    var database = MockDatabase();
    when(database.rawQuery(any, any)).thenAnswer((_) => Future.value([]));
    when(database.insert(any, any)).thenAnswer((_) => Future.value(1));

    var realDataManager = DataManager();
    await realDataManager.initialize(
      database: database,
      openDatabase: () => Future.value(database),
      resetDatabase: () => Future.value(database),
    );

    when(appManager.dataManager).thenReturn(realDataManager);
    reportManager = TestCustomReportManager(appManager);

    // Add some data.
    when(batch.insert(any, any)).thenAnswer((_) {});
    when(database.batch()).thenReturn(batch);

    var report = CustomSummaryReport(
      name: "Report",
      entityType: EntityType.bait,
      displayDateRangeId: DisplayDateRange.last7Days.id,
    );
    await reportManager.addOrUpdate(report,
      species: {
        Species(name: "Bass"),
        Species(name: "Trout"),
      },
      baits: {
        Bait(name: "Worm"),
      },
      fishingSpots: {
        FishingSpot(lat: 0.1, lng: 0.2),
        FishingSpot(lat: 0.3, lng: 0.4),
        FishingSpot(lat: 0.5, lng: 0.6),
      },
    );

    expect(reportManager.entityCount, 1);
    expect(reportManager.species(report.id).length, 2);
    expect(reportManager.baits(report.id).length, 1);
    expect(reportManager.fishingSpots(report.id).length, 3);

    // Setup listener.
    var listener = MockCustomReportListener();
    when(listener.onClear).thenReturn(() {});
    reportManager.addListener(listener);

    // Clear data.
    await realDataManager.reset();
    expect(reportManager.entityCount, 0);
    await untilCalled(listener.onClear);
    expect(reportManager.species(report.id), isEmpty);
    expect(reportManager.baits(report.id), isEmpty);
    expect(reportManager.fishingSpots(report.id), isEmpty);
    verify(listener.onClear).called(1);
  });
}