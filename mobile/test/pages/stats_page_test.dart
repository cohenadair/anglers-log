import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/comparison_report_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/stats_page.dart';
import 'package:mobile/summary_report_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/reports/comparison_report_view.dart';
import 'package:mobile/widgets/reports/overview_report_view.dart';
import 'package:mobile/widgets/reports/summary_report_view.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockBaitManager: true,
      mockCatchManager: true,
      mockComparisonReportManager: true,
      mockDataManager: true,
      mockFishingSpotManager: true,
      mockSummaryReportManager: true,
      mockSpeciesManager: true,
      mockTimeManager: true,
    );

    when(appManager.mockBaitManager.addSimpleListener(
      onDelete: anyNamed("onDelete"),
      onAddOrUpdate: anyNamed("onAddOrUpdate"),
      onClear: anyNamed("onClear"),
    )).thenReturn(SimpleEntityListener<Bait>());
    when(appManager.mockBaitManager.list()).thenReturn([]);

    when(appManager.mockCatchManager.catchesSortedByTimestamp(
      any,
      dateRange: anyNamed("dateRange"),
      baitIds: anyNamed("baitIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      speciesIds: anyNamed("speciesIds"),
    )).thenReturn([]);
    when(appManager.mockCatchManager.addSimpleListener(
      onDelete: anyNamed("onDelete"),
      onAddOrUpdate: anyNamed("onAddOrUpdate"),
      onClear: anyNamed("onClear"),
    )).thenReturn(SimpleEntityListener<Catch>());

    when(appManager.mockComparisonReportManager.addSimpleListener(
      onDelete: anyNamed("onDelete"),
      onAddOrUpdate: anyNamed("onAddOrUpdate"),
      onClear: anyNamed("onClear"),
    )).thenReturn(SimpleEntityListener<ComparisonReport>());
    when(appManager.mockComparisonReportManager.list()).thenReturn([]);

    when(appManager.mockDataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockDataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.mockFishingSpotManager.addSimpleListener(
      onDelete: anyNamed("onDelete"),
      onAddOrUpdate: anyNamed("onAddOrUpdate"),
      onClear: anyNamed("onClear"),
    )).thenReturn(SimpleEntityListener<FishingSpot>());
    when(appManager.mockFishingSpotManager.list()).thenReturn([]);

    when(appManager.mockSummaryReportManager.addSimpleListener(
      onDelete: anyNamed("onDelete"),
      onAddOrUpdate: anyNamed("onAddOrUpdate"),
      onClear: anyNamed("onClear"),
    )).thenReturn(SimpleEntityListener<SummaryReport>());

    when(appManager.mockSpeciesManager.addSimpleListener(
      onDelete: anyNamed("onDelete"),
      onAddOrUpdate: anyNamed("onAddOrUpdate"),
      onClear: anyNamed("onClear"),
    )).thenReturn(SimpleEntityListener<Species>());
    when(appManager.mockSpeciesManager.list()).thenReturn([]);
  });

  testWidgets("Defaults to overview", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => StatsPage(),
      appManager: appManager,
    ));
    expect(find.text("Overview"), findsOneWidget);
    expect(find.byType(OverviewReportView), findsOneWidget);
    expect(find.byType(SummaryReportView), findsNothing);
    expect(find.byType(ComparisonReportView), findsNothing);
  });

  testWidgets("Selecting summary shows summary", (WidgetTester tester) async {
    when(appManager.mockComparisonReportManager.list()).thenReturn([]);
    when(appManager.mockSummaryReportManager.list()).thenReturn([
      SummaryReport()
        ..id = randomId()
        ..name = "Summary"
    ]);

    await tester.pumpWidget(Testable(
      (_) => StatsPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Overview"));
    await tapAndSettle(tester, find.text("Summary"));

    expect(find.byType(OverviewReportView), findsNothing);
    expect(find.byType(SummaryReportView), findsOneWidget);
    expect(find.byType(ComparisonReportView), findsNothing);
  });

  testWidgets("Selecting comparison shows comparison", (WidgetTester tester)
      async
  {
    when(appManager.mockSummaryReportManager.list()).thenReturn([]);
    when(appManager.mockComparisonReportManager.list()).thenReturn([
      ComparisonReport()
        ..id = randomId()
        ..name = "Comparison"
    ]);

    await tester.pumpWidget(Testable(
      (_) => StatsPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Overview"));
    await tapAndSettle(tester, find.text("Comparison"));

    expect(find.byType(OverviewReportView), findsNothing);
    expect(find.byType(SummaryReportView), findsNothing);
    expect(find.byType(ComparisonReportView), findsOneWidget);
  });

  testWidgets("If current report is deleted, falls back to overview",
      (WidgetTester tester) async
  {
    var summaryReportManager = SummaryReportManager(appManager);
    when(appManager.summaryReportManager).thenReturn(summaryReportManager);

    var comparisonReportManager = ComparisonReportManager(appManager);
    when(appManager.comparisonReportManager)
        .thenReturn(comparisonReportManager);
    Id reportId = randomId();
    await comparisonReportManager.addOrUpdate(ComparisonReport()
      ..id = reportId
      ..name = "Comparison"
    );

    await tester.pumpWidget(Testable(
      (_) => StatsPage(),
      appManager: appManager,
    ));

    // Select a report.
    await tapAndSettle(tester, find.text("Overview"));
    await tapAndSettle(tester, find.text("Comparison"));
    expect(find.byType(ComparisonReportView), findsOneWidget);

    // Simulate deleting the report.
    await comparisonReportManager.delete(reportId);

    // Wait for listeners to be invoked.
    await tester.pumpAndSettle(Duration(milliseconds: 250));
    expect(find.byType(ComparisonReportView), findsNothing);
    expect(find.text("Comparison"), findsNothing);
    expect(find.byType(OverviewReportView), findsOneWidget);
    expect(find.text("Overview"), findsOneWidget);
  });

  testWidgets("If non-current report is deleted, report stays the same",
      (WidgetTester tester) async
  {
    var summaryReportManager = SummaryReportManager(appManager);
    when(appManager.summaryReportManager).thenReturn(summaryReportManager);
    Id summaryId = randomId();
    await summaryReportManager.addOrUpdate(SummaryReport()
      ..id = summaryId
      ..name = "Summary"
    );

    var comparisonReportManager = ComparisonReportManager(appManager);
    when(appManager.comparisonReportManager)
        .thenReturn(comparisonReportManager);
    Id comparisonId = randomId();
    await comparisonReportManager.addOrUpdate(ComparisonReport()
      ..id = comparisonId
      ..name = "Comparison"
    );

    await tester.pumpWidget(Testable(
      (_) => StatsPage(),
      appManager: appManager,
    ));

    // Select a report.
    await tapAndSettle(tester, find.text("Overview"));
    await tapAndSettle(tester, find.text("Comparison"));
    expect(find.byType(ComparisonReportView), findsOneWidget);

    // Simulate deleting a report that isn't selected.
    await summaryReportManager.delete(summaryId);

    // Wait for listeners to be invoked.
    await tester.pumpAndSettle(Duration(milliseconds: 250));
    expect(find.byType(ComparisonReportView), findsOneWidget);
    expect(find.text("Comparison"), findsOneWidget);
  });
}