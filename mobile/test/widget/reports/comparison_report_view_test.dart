import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/reports/comparison_report_view.dart';
import 'package:mobile/widgets/reports/report_summary.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../../mock_app_manager.dart';
import '../../test_utils.dart';

main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockCatchManager: true,
      mockClock: true,
      mockComparisonReportManager: true,
      mockSpeciesManager: true,
      mockFishingSpotManager: true,
      mockBaitManager: true,
    );

    Species species = Species()
      ..id = randomId()
      ..name = "Bass";

    when(appManager.mockClock.now())
        .thenReturn(DateTime.fromMillisecondsSinceEpoch(10000));
    when(appManager.mockCatchManager.catchesSortedByTimestamp(any,
      dateRange: anyNamed("dateRange"),
      baitIds: anyNamed("baitIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      speciesIds: anyNamed("speciesIds"),
    )).thenReturn([
      Catch()
        ..id = randomId()
        ..timestamp = timestampFromMillis(5000)
        ..speciesId = species.id,
    ]);
    when(appManager.mockSpeciesManager.list()).thenReturn([
      species,
    ]);
    when(appManager.mockSpeciesManager.entity(any)).thenReturn(species);
    when(appManager.mockFishingSpotManager.list()).thenReturn([]);
    when(appManager.mockBaitManager.list()).thenReturn([]);
  });

  testWidgets("Models created correctly", (WidgetTester tester) async {
    ComparisonReport report = ComparisonReport()
      ..id = randomId()
      ..toDisplayDateRangeId = DisplayDateRange.last7Days.id
      ..fromDisplayDateRangeId = DisplayDateRange.last30Days.id;
    when(appManager.mockComparisonReportManager.entity(any))
        .thenReturn(report);

    await tester.pumpWidget(
      Testable((_) => ComparisonReportView(report.id),
        appManager: appManager,
      ),
    );

    expect(find.text("Last 7 days"), findsNWidgets(2));
    expect(find.text("Last 30 days"), findsNWidgets(2));
  });

  testWidgets("Report ID doesn't exist", (WidgetTester tester) async {
    when(appManager.mockComparisonReportManager.entity(any))
        .thenReturn(null);

    await tester.pumpWidget(
      Testable((_) => ComparisonReportView(randomId()),
        appManager: appManager,
      ),
    );

    expect(find.byType(Empty), findsOneWidget);
    expect(find.byType(ReportSummary), findsNothing);
  });
}