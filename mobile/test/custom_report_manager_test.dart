import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';

void main() {
  late StubbedAppManager appManager;

  late MockEntityListener<Report> reportListener;

  late ReportManager reportManager;
  late SpeciesManager speciesManager;
  late BaitManager baitManager;
  late FishingSpotManager fishingSpotManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.authManager.stream).thenAnswer((_) => const Stream.empty());

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.localDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.baitManager.addListener(any)).thenAnswer((_) {});
    when(appManager.fishingSpotManager.addListener(any)).thenAnswer((_) {});
    when(appManager.speciesManager.addListener(any)).thenAnswer((_) {});

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    // Setup real objects.
    speciesManager = SpeciesManager(appManager.app);
    when(appManager.app.speciesManager).thenReturn(speciesManager);

    baitManager = BaitManager(appManager.app);
    when(appManager.app.baitManager).thenReturn(baitManager);

    fishingSpotManager = FishingSpotManager(appManager.app);
    when(appManager.app.fishingSpotManager).thenReturn(fishingSpotManager);

    reportListener = MockEntityListener<Report>();
    when(reportListener.onAdd).thenReturn((_) {});

    reportManager = ReportManager(appManager.app);
    reportManager.addListener(reportListener);
  });

  test("On species deleted, reports updated and listeners notified", () async {
    var updatedReports = <Report>[];
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

    var report = Report()
      ..id = randomId()
      ..speciesIds.add(species.id);
    reportManager.addOrUpdate(report);

    await speciesManager.addOrUpdate(species);
    await speciesManager.delete(species.id);

    verify(reportListener.onAdd).called(1);

    // Wait for addOrUpdate calls to finish.
    await Future.delayed(const Duration(milliseconds: 50));

    expect(updatedReports.length, 1);
    expect(updatedReports.first.id, report.id);
  });

  test("On baits deleted, reports updated and listeners notified", () async {
    var updatedReports = <Report>[];
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

    var report = Report()
      ..id = randomId()
      ..baits.add(BaitAttachment(baitId: bait.id));
    reportManager.addOrUpdate(report);

    await baitManager.addOrUpdate(bait);
    await baitManager.delete(bait.id);

    verify(reportListener.onAdd).called(1);

    // Wait for addOrUpdate calls to finish.
    await Future.delayed(const Duration(milliseconds: 50));

    expect(updatedReports.length, 1);
    expect(updatedReports.first.id, report.id);
  });

  test("On fishing spots deleted, reports updated and listeners notified",
      () async {
    var updatedReports = <Report>[];
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

    var report = Report()
      ..id = randomId()
      ..fishingSpotIds.add(fishingSpot.id);
    reportManager.addOrUpdate(report);

    await fishingSpotManager.addOrUpdate(fishingSpot);
    await fishingSpotManager.delete(fishingSpot.id);

    verify(reportListener.onAdd).called(1);

    // Wait for addOrUpdate calls to finish.
    await Future.delayed(const Duration(milliseconds: 50));

    expect(updatedReports.length, 1);
    expect(updatedReports.first.id, report.id);
  });

  test("removeAttachedBaits", () async {
    var attachmentToRemove = BaitAttachment(baitId: randomId());

    var report = Report()..id = randomId();
    report.baits.add(attachmentToRemove);

    reportManager.removeAttachedBaits(report, attachmentToRemove.baitId);
    expect(
      report.baits.contains(attachmentToRemove),
      isFalse,
    );
  });

  test("removeFishingSpot", () async {
    var fishingSpotToRemove = FishingSpot()..id = randomId();

    var report = Report()..id = randomId();
    report.fishingSpotIds.add(fishingSpotToRemove.id);

    reportManager.removeFishingSpot(report, fishingSpotToRemove);
    expect(
      report.fishingSpotIds.contains(fishingSpotToRemove.id),
      isFalse,
    );
  });

  test("removeSpecies", () async {
    var speciesToRemove = Species()..id = randomId();

    var report = Report()..id = randomId();
    report.speciesIds.add(speciesToRemove.id);

    reportManager.removeSpecies(report, speciesToRemove);
    expect(
      report.speciesIds.contains(speciesToRemove.id),
      isFalse,
    );
  });
}
