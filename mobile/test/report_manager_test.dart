import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

import 'mock_app_manager.dart';

class MockBatch extends Mock implements Batch {}

class MockCustomReportListener extends Mock
    implements EntityListener<SummaryReport> {}

class TestCustomReportManager extends ReportManager<SummaryReport> {
  final _id = randomId();

  TestCustomReportManager(AppManager app) : super(app);

  @override
  SummaryReport entityFromBytes(List<int> bytes) => SummaryReport()
    ..id = _id
    ..name = "Summary Report";

  @override
  Id id(SummaryReport entity) => _id;

  @override
  String name(SummaryReport entity) => "Summary Report";

  @override
  String get tableName => "summary_report";

  @override
  bool removeBait(SummaryReport report, Bait bait) => true;

  @override
  bool removeFishingSpot(SummaryReport report, FishingSpot fishingSpot) => true;

  @override
  bool removeSpecies(SummaryReport report, Species species) => true;
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
    when(reportListener.onAdd).thenReturn((_) {});

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
    var updatedReports = <SummaryReport>[];
    when(reportListener.onUpdate)
        .thenReturn((reports) => updatedReports = reports);

    // Can't delete because catch exists.
    when(appManager.mockCatchManager.existsWith(
      speciesId: anyNamed("speciesId"),
    )).thenReturn(true);

    var species = Species()
      ..id = randomId()
      ..name = "Bass";
    await speciesManager.delete(species.id);
    verifyNever(reportListener.onUpdate);

    // Successful delete.
    when(appManager.mockCatchManager.existsWith(
      speciesId: anyNamed("speciesId"),
    )).thenReturn(false);

    var report = SummaryReport()
      ..id = randomId()
      ..speciesIds.add(species.id);
    reportManager.addOrUpdate(report);

    await speciesManager.addOrUpdate(species);
    await speciesManager.delete(species.id);

    verify(reportListener.onAdd).called(1);

    expect(updatedReports.length, 1);
    expect(updatedReports.first.id, report.id);
  });

  test("On baits deleted, reports updated and listeners notified", () async {
    var updatedReports = <SummaryReport>[];
    when(reportListener.onUpdate)
        .thenReturn((reports) => updatedReports = reports);

    // Nothing to delete.
    when(appManager.mockDataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(false));

    var bait = Bait()
      ..id = randomId()
      ..name = "Lure";
    await baitManager.delete(bait.id);
    verifyNever(reportListener.onUpdate);

    // Successful delete.
    when(appManager.mockDataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    var report = SummaryReport()
      ..id = randomId()
      ..baitIds.add(bait.id);
    reportManager.addOrUpdate(report);

    await baitManager.addOrUpdate(bait);
    await baitManager.delete(bait.id);

    verify(reportListener.onAdd).called(1);

    expect(updatedReports.length, 1);
    expect(updatedReports.first.id, report.id);
  });

  test("On fishing spots deleted, reports updated and listeners notified",
      () async {
    var updatedReports = <SummaryReport>[];
    when(reportListener.onUpdate)
        .thenReturn((reports) => updatedReports = reports);

    // Nothing to delete.
    when(appManager.mockDataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(false));

    var fishingSpot = FishingSpot()
      ..id = randomId()
      ..lat = 0.03
      ..lng = 0.05;
    await fishingSpotManager.delete(fishingSpot.id);
    verifyNever(reportListener.onUpdate);

    // Successful delete.
    when(appManager.mockDataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    var report = SummaryReport()
      ..id = randomId()
      ..fishingSpotIds.add(fishingSpot.id);
    reportManager.addOrUpdate(report);

    await fishingSpotManager.addOrUpdate(fishingSpot);
    await fishingSpotManager.delete(fishingSpot.id);

    verify(reportListener.onAdd).called(1);

    expect(updatedReports.length, 1);
    expect(updatedReports.first.id, report.id);
  });
}
