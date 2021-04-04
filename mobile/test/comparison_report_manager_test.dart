import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/comparison_report_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_app_manager.dart';

void main() {
  late StubbedAppManager appManager;

  late ComparisonReportManager comparisonReportManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.authManager.stream).thenAnswer((_) => Stream.empty());

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.baitManager.addListener(any)).thenAnswer((_) {});
    when(appManager.fishingSpotManager.addListener(any)).thenAnswer((_) {});
    when(appManager.speciesManager.addListener(any)).thenAnswer((_) {});

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    comparisonReportManager = ComparisonReportManager(appManager.app);
  });

  test("removeBait", () async {
    var baitToRemove = Bait()..id = randomId();

    var report = ComparisonReport()..id = randomId();
    report.baitIds.add(baitToRemove.id);

    comparisonReportManager.removeBait(report, baitToRemove);
    expect(
      report.baitIds.contains(baitToRemove.id),
      isFalse,
    );
  });

  test("removeFishingSpot", () async {
    var fishingSpotToRemove = FishingSpot()..id = randomId();

    var report = ComparisonReport()..id = randomId();
    report.fishingSpotIds.add(fishingSpotToRemove.id);

    comparisonReportManager.removeFishingSpot(report, fishingSpotToRemove);
    expect(
      report.fishingSpotIds.contains(fishingSpotToRemove.id),
      isFalse,
    );
  });

  test("removeSpecies", () async {
    var speciesToRemove = Species()..id = randomId();

    var report = ComparisonReport()..id = randomId();
    report.speciesIds.add(speciesToRemove.id);

    comparisonReportManager.removeSpecies(report, speciesToRemove);
    expect(
      report.speciesIds.contains(speciesToRemove.id),
      isFalse,
    );
  });
}
