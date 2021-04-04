import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';

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
  late StubbedAppManager appManager;

  late SpeciesManager speciesManager;
  late BaitManager baitManager;
  late FishingSpotManager fishingSpotManager;

  late TestCustomReportManager reportManager;
  late MockEntityListener<SummaryReport> reportListener;

  setUp(() {
    // Setup mocks.
    appManager = StubbedAppManager();

    when(appManager.authManager.stream).thenAnswer((_) => Stream.empty());

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.localDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    reportListener = MockEntityListener<SummaryReport>();
    when(reportListener.onAdd).thenReturn((_) {});

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    // Setup real objects.
    speciesManager = SpeciesManager(appManager.app);
    when(appManager.app.speciesManager).thenReturn(speciesManager);

    baitManager = BaitManager(appManager.app);
    when(appManager.app.baitManager).thenReturn(baitManager);

    fishingSpotManager = FishingSpotManager(appManager.app);
    when(appManager.app.fishingSpotManager).thenReturn(fishingSpotManager);

    reportManager = TestCustomReportManager(appManager.app);
    reportManager.addListener(reportListener);
  });

  test("On species deleted, reports updated and listeners notified", () async {
    var updatedReports = <SummaryReport>[];
    when(reportListener.onUpdate)
        .thenReturn((report) => updatedReports.add(report));

    // Can't delete because catch exists.
    when(appManager.catchManager.existsWith(
      speciesId: anyNamed("speciesId"),
    )).thenReturn(true);

    var species = Species()
      ..id = randomId()
      ..name = "Bass";
    await speciesManager.delete(species.id);
    verifyNever(reportListener.onUpdate);

    // Successful delete.
    when(appManager.catchManager.existsWith(
      speciesId: anyNamed("speciesId"),
    )).thenReturn(false);

    var report = SummaryReport()
      ..id = randomId()
      ..speciesIds.add(species.id);
    reportManager.addOrUpdate(report);

    await speciesManager.addOrUpdate(species);
    await speciesManager.delete(species.id);

    verify(reportListener.onAdd).called(1);

    // Wait for addOrUpdate calls to finish.
    await Future.delayed(Duration(milliseconds: 50));

    expect(updatedReports.length, 1);
    expect(updatedReports.first.id, report.id);
  });

  test("On baits deleted, reports updated and listeners notified", () async {
    var updatedReports = <SummaryReport>[];
    when(reportListener.onUpdate)
        .thenReturn((report) => updatedReports.add(report));

    // Nothing to delete.
    when(appManager.localDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(false));

    var bait = Bait()
      ..id = randomId()
      ..name = "Lure";
    await baitManager.delete(bait.id);
    verifyNever(reportListener.onUpdate);

    // Successful delete.
    when(appManager.localDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    var report = SummaryReport()
      ..id = randomId()
      ..baitIds.add(bait.id);
    reportManager.addOrUpdate(report);

    await baitManager.addOrUpdate(bait);
    await baitManager.delete(bait.id);

    verify(reportListener.onAdd).called(1);

    // Wait for addOrUpdate calls to finish.
    await Future.delayed(Duration(milliseconds: 50));

    expect(updatedReports.length, 1);
    expect(updatedReports.first.id, report.id);
  });

  test("On fishing spots deleted, reports updated and listeners notified",
      () async {
    var updatedReports = <SummaryReport>[];
    when(reportListener.onUpdate)
        .thenReturn((report) => updatedReports.add(report));

    // Nothing to delete.
    when(appManager.localDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(false));

    var fishingSpot = FishingSpot()
      ..id = randomId()
      ..lat = 0.03
      ..lng = 0.05;
    await fishingSpotManager.delete(fishingSpot.id);
    verifyNever(reportListener.onUpdate);

    // Successful delete.
    when(appManager.localDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    var report = SummaryReport()
      ..id = randomId()
      ..fishingSpotIds.add(fishingSpot.id);
    reportManager.addOrUpdate(report);

    await fishingSpotManager.addOrUpdate(fishingSpot);
    await fishingSpotManager.delete(fishingSpot.id);

    verify(reportListener.onAdd).called(1);

    // Wait for addOrUpdate calls to finish.
    await Future.delayed(Duration(milliseconds: 50));

    expect(updatedReports.length, 1);
    expect(updatedReports.first.id, report.id);
  });
}
