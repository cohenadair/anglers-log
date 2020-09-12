import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/species_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

import 'mock_app_manager.dart';

class MockBatch extends Mock implements Batch {}
class MockCustomReportListener extends Mock implements
    EntityListener<SummaryReport> {}

class TestCustomReportManager extends ReportManager<SummaryReport> {
  final _id = Id.random();

  TestCustomReportManager(AppManager app) : super(app);

  @override
  SummaryReport entityFromBytes(List<int> bytes) => SummaryReport()
    ..id = _id.bytes
    ..name = "Summary Report";

  @override
  Id id(SummaryReport entity) => _id;

  @override
  String name(SummaryReport entity) => "Summary Report";

  @override
  void onDeleteBait(Bait bait) {
    // Do nothing.
  }

  @override
  void onDeleteFishingSpot(FishingSpot fishingSpot) {
    // Do nothing.
  }

  @override
  void onDeleteSpecies(Species species) {
    // Do nothing.
  }

  @override
  String get tableName => "summary_report";
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
    when(appManager.mockDataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockDataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

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

  test("On species deleted, reports updated and listeners notified", () async {
    // Can't delete because catch exists.
    when(appManager.mockCatchManager.existsWith(
      speciesId: anyNamed("speciesId"),
    )).thenReturn(true);

    var species = Species()
      ..id = Id.random().bytes
      ..name = "Bass";
    await speciesManager.delete(Id(species.id));
    verifyNever(reportListener.onAddOrUpdate);

    // Successful delete.
    when(appManager.mockCatchManager.existsWith(
      speciesId: anyNamed("speciesId"),
    )).thenReturn(false);

    await speciesManager.addOrUpdate(species);
    await speciesManager.delete(Id(species.id));
    verify(reportListener.onAddOrUpdate).called(1);
  });

  test("On baits deleted, reports updated and listeners notified", () async {
    // Nothing to delete.
    when(appManager.mockDataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(false));

    var bait = Bait()
      ..id = Id.random().bytes
      ..name = "Lure";
    await baitManager.delete(Id(bait.id));
    verifyNever(reportListener.onAddOrUpdate);

    // Successful delete.
    when(appManager.mockDataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    await baitManager.addOrUpdate(bait);
    await baitManager.delete(Id(bait.id));
    verify(reportListener.onAddOrUpdate).called(1);
  });

  test("On fishing spots deleted, reports updated and listeners notified",
      () async
  {
    // Nothing to delete.
    when(appManager.mockDataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(false));

    var fishingSpot = FishingSpot()
      ..id = Id.random().bytes
      ..lat = 0.03
      ..lng = 0.05;
    await fishingSpotManager.delete(Id(fishingSpot.id));
    verifyNever(reportListener.onAddOrUpdate);

    // Successful delete.
    when(appManager.mockDataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    await fishingSpotManager.addOrUpdate(fishingSpot);
    await fishingSpotManager.delete(Id(fishingSpot.id));
    verify(reportListener.onAddOrUpdate).called(1);
  });
}