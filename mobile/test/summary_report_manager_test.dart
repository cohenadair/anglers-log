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

  test("onDeleteBait", () async {
    Bait baitToRemove = Bait()..id = randomId();

    SummaryReport report = SummaryReport()..id = randomId();
    report.baitIds.add(baitToRemove.id);

    await summaryReportManager.addOrUpdate(report);
    expect(
      summaryReportManager.entity(report.id).baitIds.contains(baitToRemove.id),
      isTrue,
    );

    summaryReportManager.onDeleteBait(baitToRemove);
    expect(
      summaryReportManager.entity(report.id).baitIds.contains(baitToRemove.id),
      isFalse,
    );
  });

  test("onDeleteFishingSpot", () async {
    FishingSpot fishingSpotToRemove = FishingSpot()..id = randomId();

    SummaryReport report = SummaryReport()..id = randomId();
    report.fishingSpotIds.add(fishingSpotToRemove.id);

    await summaryReportManager.addOrUpdate(report);
    expect(
      summaryReportManager
          .entity(report.id)
          .fishingSpotIds
          .contains(fishingSpotToRemove.id),
      isTrue,
    );

    summaryReportManager.onDeleteFishingSpot(fishingSpotToRemove);
    expect(
      summaryReportManager
          .entity(report.id)
          .fishingSpotIds
          .contains(fishingSpotToRemove.id),
      isFalse,
    );
  });

  test("onDeleteSpecies", () async {
    Species speciesToRemove = Species()..id = randomId();

    SummaryReport report = SummaryReport()..id = randomId();
    report.speciesIds.add(speciesToRemove.id);

    await summaryReportManager.addOrUpdate(report);
    expect(
      summaryReportManager
          .entity(report.id)
          .speciesIds
          .contains(speciesToRemove.id),
      isTrue,
    );

    summaryReportManager.onDeleteSpecies(speciesToRemove);
    expect(
      summaryReportManager
          .entity(report.id)
          .speciesIds
          .contains(speciesToRemove.id),
      isFalse,
    );
  });
}
