import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/summary_report_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';

void main() {
  MockAppManager appManager;

  SummaryReportManager summaryReportManager;

  setUp(() {
    appManager = MockAppManager(
      mockDataManager: true,
      mockBaitManager: true,
      mockFishingSpotManager: true,
      mockSpeciesManager: true,
    );

    when(appManager.mockDataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.mockBaitManager.addListener(any)).thenAnswer((_) {});
    when(appManager.mockFishingSpotManager.addListener(any)).thenAnswer((_) {});
    when(appManager.mockSpeciesManager.addListener(any)).thenAnswer((_) {});

    summaryReportManager = SummaryReportManager(appManager);
  });

  test("removeBait", () async {
    var baitToRemove = Bait()..id = randomId();

    var report = SummaryReport()..id = randomId();
    report.baitIds.add(baitToRemove.id);

    summaryReportManager.removeBait(report, baitToRemove);
    expect(
      report.baitIds.contains(baitToRemove.id),
      isFalse,
    );
  });

  test("removeFishingSpot", () async {
    var fishingSpotToRemove = FishingSpot()..id = randomId();

    var report = SummaryReport()..id = randomId();
    report.fishingSpotIds.add(fishingSpotToRemove.id);

    summaryReportManager.removeFishingSpot(report, fishingSpotToRemove);
    expect(
      report.fishingSpotIds.contains(fishingSpotToRemove.id),
      isFalse,
    );
  });

  test("removeSpecies", () async {
    var speciesToRemove = Species()..id = randomId();

    var report = SummaryReport()..id = randomId();
    report.speciesIds.add(speciesToRemove.id);

    summaryReportManager.removeSpecies(report, speciesToRemove);
    expect(
      report.speciesIds.contains(speciesToRemove.id),
      isFalse,
    );
  });
}
