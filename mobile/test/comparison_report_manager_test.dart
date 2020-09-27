import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/comparison_report_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';

void main() {
  MockAppManager appManager;

  ComparisonReportManager comparisonReportManager;

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

    comparisonReportManager = ComparisonReportManager(appManager);
  });

  test("onDeleteBait", () async {
    Bait baitToRemove = Bait()
      ..id = randomId();

    ComparisonReport report = ComparisonReport()
      ..id = randomId();
    report.baitIds.add(baitToRemove.id);

    await comparisonReportManager.addOrUpdate(report);
    expect(comparisonReportManager.entity(report.id).baitIds
        .contains(baitToRemove.id), isTrue);

    comparisonReportManager.onDeleteBait(baitToRemove);
    expect(comparisonReportManager.entity(report.id).baitIds
        .contains(baitToRemove.id), isFalse);
  });

  test("onDeleteFishingSpot", () async {
    FishingSpot fishingSpotToRemove = FishingSpot()
      ..id = randomId();

    ComparisonReport report = ComparisonReport()
      ..id = randomId();
    report.fishingSpotIds.add(fishingSpotToRemove.id);

    await comparisonReportManager.addOrUpdate(report);
    expect(comparisonReportManager.entity(report.id).fishingSpotIds
        .contains(fishingSpotToRemove.id), isTrue);

    comparisonReportManager.onDeleteFishingSpot(fishingSpotToRemove);
    expect(comparisonReportManager.entity(report.id).fishingSpotIds
        .contains(fishingSpotToRemove.id), isFalse);
  });

  test("onDeleteSpecies", () async {
    Species speciesToRemove = Species()
      ..id = randomId();

    ComparisonReport report = ComparisonReport()
      ..id = randomId();
    report.speciesIds.add(speciesToRemove.id);

    await comparisonReportManager.addOrUpdate(report);
    expect(comparisonReportManager.entity(report.id).speciesIds
        .contains(speciesToRemove.id), isTrue);

    comparisonReportManager.onDeleteSpecies(speciesToRemove);
    expect(comparisonReportManager.entity(report.id).speciesIds
        .contains(speciesToRemove.id), isFalse);
  });
}