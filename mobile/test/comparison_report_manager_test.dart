import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/comparison_report_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

void main() {
  MockAppManager appManager;

  ComparisonReportManager comparisonReportManager;

  setUp(() {
    appManager = MockAppManager(
      mockAuthManager: true,
      mockDataManager: true,
      mockBaitManager: true,
      mockFishingSpotManager: true,
      mockSpeciesManager: true,
      mockSubscriptionManager: true,
    );

    var authStream = MockStream<void>();
    when(authStream.listen(any)).thenReturn(null);
    when(appManager.mockAuthManager.stream).thenAnswer((_) => authStream);

    when(appManager.mockDataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    var dataStream = MockStream<DataManagerEvent>();
    when(dataStream.listen(any)).thenReturn(null);
    when(appManager.mockDataManager.stream).thenAnswer((_) => dataStream);

    when(appManager.mockBaitManager.addListener(any)).thenAnswer((_) {});
    when(appManager.mockFishingSpotManager.addListener(any)).thenAnswer((_) {});
    when(appManager.mockSpeciesManager.addListener(any)).thenAnswer((_) {});

    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    comparisonReportManager = ComparisonReportManager(appManager);
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
