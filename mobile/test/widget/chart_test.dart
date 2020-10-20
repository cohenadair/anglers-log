import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/chart.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  group("Initialization", () {
    testWidgets("Assertion if no title/description when not showing all",
        (WidgetTester tester) async
    {
      Series<Species> series = Series({
        Species()..name = "Bass": 5,
      }, DisplayDateRange.last7Days);

      await tester.pumpWidget(Testable((_) => Chart(
        series: [series],
        labelBuilder: null,
      )));
      expect(tester.takeException(), isAssertionError);

      await tester.pumpWidget(Testable((_) => Chart(
        series: [series],
        labelBuilder: null,
        viewAllTitle: "Title",
      )));
      expect(tester.takeException(), isAssertionError);

      await tester.pumpWidget(Testable((_) => Chart(
        series: [series],
        labelBuilder: null,
        chartPageDescription: "A description.",
      )));
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets("Assertion if not all series data has equal length",
        (WidgetTester tester) async
    {
      Series<Species> series1 = Series({
        Species()..name = "Bass": 5,
      }, DisplayDateRange.last7Days);

      Series<Species> series2 = Series({
        Species()..name = "Bass": 5,
        Species()..name = "Trout": 10,
      }, DisplayDateRange.last7Days);

      await tester.pumpWidget(Testable((_) => Chart(
        series: [series1, series2],
        labelBuilder: (_) => "",
        viewAllTitle: "Title",
        chartPageDescription: "A description.",
      )));
      expect(tester.takeException(), isAssertionError);
    });
  });

  group("Legend", () {
    testWidgets("Single series does not show legend", (WidgetTester tester)
        async
    {
      Series<Species> series = Series({
        Species()..name = "Bass": 5,
        Species()..name = "Trout": 10,
      }, DisplayDateRange.last7Days);

      await tester.pumpWidget(Testable((_) => Chart(
        series: [series],
        labelBuilder: (_) => "",
        viewAllTitle: "Title",
        chartPageDescription: "A description.",
      )));
      expect(find.byType(Empty), findsOneWidget);
      expect(find.text("Last 7 days"), findsNothing);
    });

    testWidgets("Multiple series shows legend", (WidgetTester tester) async {
      Series<Species> series1 = Series({
        Species()..name = "Bass": 5,
        Species()..name = "Trout": 10,
      }, DisplayDateRange.last7Days);

      Series<Species> series2 = Series({
        Species()..name = "Bass": 8,
        Species()..name = "Trout": 11,
      }, DisplayDateRange.lastMonth);

      await tester.pumpWidget(Testable((_) => Chart(
        series: [series1, series2],
        labelBuilder: (_) => "",
        viewAllTitle: "Title",
        chartPageDescription: "A description.",
      )));
      expect(find.text("Last month"), findsOneWidget);
      expect(find.text("Last 7 days"), findsOneWidget);
    });
  });

  group("Chart rows", () {
    testWidgets("Series max value 0 shows empty rows", (WidgetTester tester)
        async
    {
      Series<Species> series1 = Series({
        Species()..name = "Bass": 0,
      }, DisplayDateRange.last7Days);

      Series<Species> series2 = Series({
        Species()..name = "Bass": 0,
      }, DisplayDateRange.lastMonth);

      await tester.pumpWidget(Testable((_) => Chart(
        series: [series1, series2],
        labelBuilder: (_) => "",
        viewAllTitle: "Title",
        chartPageDescription: "A description.",
      )));
      expect(find.byType(Empty), findsNWidgets(2));
    });

    testWidgets("Row with non-null onTap action", (WidgetTester tester) async {
      MockAppManager appManager = MockAppManager(
        mockTimeManager: true,
      );
      when(appManager.mockTimeManager.currentDateTime).thenReturn(DateTime.now());

      Series<Species> series = Series({
        Species()..name = "Bass": 10,
      }, DisplayDateRange.lastMonth);

      bool tapped = false;
      await tester.pumpWidget(Testable(
        (_) => Chart(
          series: [series],
          labelBuilder: (species) => species.name,
          viewAllTitle: "Title",
          chartPageDescription: "A description.",
          onTapRow: (_, __) => tapped = true,
        ),
        mediaQueryData: MediaQueryData(
          // Chart row widths are based on screen size. Need to give a screen
          // size to tap.
          size: Size(500, 500),
        ),
        appManager: appManager,
      ));
      expect(find.byType(InkWell), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets("Normal series data rows", (WidgetTester tester) async {
      Series<Species> series1 = Series({
        Species()..name = "Bass": 10,
        Species()..name = "Catfish": 3,
        Species()..name = "Skipjack": 17,
        Species()..name = "Pike": 30,
      }, DisplayDateRange.lastYear);

      Series<Species> series2 = Series({
        Species()..name = "Bass": 12,
        Species()..name = "Catfish": 5,
        Species()..name = "Skipjack": 13,
        Species()..name = "Pike": 15,
      }, DisplayDateRange.thisYear);

      Series<Species> series3 = Series({
        Species()..name = "Bass": 0,
        Species()..name = "Catfish": 0,
        Species()..name = "Skipjack": 0,
        Species()..name = "Pike": 0,
      }, DisplayDateRange.lastMonth);

      await tester.pumpWidget(Testable((_) => Chart(
        series: [series1, series2, series3],
        labelBuilder: (species) => species.name,
        viewAllTitle: "View all",
        chartPageDescription: "A description.",
      )));

      // Legend
      expect(find.text("Last year"), findsOneWidget);
      expect(find.text("This year"), findsOneWidget);
      expect(find.text("Last month"), findsOneWidget);

      // Rows
      expect(find.text("Bass (10)"), findsOneWidget);
      expect(find.text("Bass (12)"), findsOneWidget);
      expect(find.text("Bass (0)"), findsOneWidget);
      expect(find.text("Catfish (3)"), findsOneWidget);
      expect(find.text("Catfish (5)"), findsOneWidget);
      expect(find.text("Catfish (0)"), findsOneWidget);
      expect(find.text("Skipjack (17)"), findsOneWidget);
      expect(find.text("Skipjack (13)"), findsOneWidget);
      expect(find.text("Skipjack (0)"), findsOneWidget);

      // Pike is past he max number of showing in a condensed chart.
      expect(find.text("Pike (30)"), findsNothing);
      expect(find.text("Pike (15)"), findsNothing);
      expect(find.text("Pike (0)"), findsNothing);

      // View all
      expect(find.text("View all"), findsOneWidget);
    });
  });

  group("View all row", () {
    testWidgets("If condensed, row is rendered", (WidgetTester tester) async {
      Series<Species> series1 = Series({
        Species()..name = "Bass": 10,
        Species()..name = "Catfish": 3,
        Species()..name = "Skipjack": 17,
        Species()..name = "Pike": 30,
      }, DisplayDateRange.lastYear);

      Series<Species> series2 = Series({
        Species()..name = "Bass": 12,
        Species()..name = "Catfish": 5,
        Species()..name = "Skipjack": 13,
        Species()..name = "Pike": 15,
      }, DisplayDateRange.thisYear);

      await tester.pumpWidget(Testable((_) => Chart(
        series: [series1, series2],
        labelBuilder: (species) => species.name,
        viewAllTitle: "View all",
        chartPageDescription: "A description.",
      )));

      expect(find.text("View all"), findsOneWidget);
    });

    testWidgets("If condensed and all series length < min, row is not rendered",
        (WidgetTester tester) async
    {
      Series<Species> series1 = Series({
        Species()..name = "Bass": 10,
        Species()..name = "Catfish": 3,
      }, DisplayDateRange.lastYear);

      Series<Species> series2 = Series({
        Species()..name = "Bass": 12,
        Species()..name = "Catfish": 5,
      }, DisplayDateRange.thisYear);

      await tester.pumpWidget(Testable((_) => Chart(
        series: [series1, series2],
        labelBuilder: (species) => species.name,
        viewAllTitle: "View all",
        chartPageDescription: "A description.",
      )));

      expect(find.text("View all"), findsNothing);
    });

    testWidgets("If showing all, no show all row is rendered",
        (WidgetTester tester) async
    {
      Series<Species> series1 = Series({
        Species()..name = "Bass": 10,
        Species()..name = "Catfish": 3,
        Species()..name = "Skipjack": 17,
        Species()..name = "Pike": 30,
      }, DisplayDateRange.lastYear);

      Series<Species> series2 = Series({
        Species()..name = "Bass": 12,
        Species()..name = "Catfish": 5,
        Species()..name = "Skipjack": 13,
        Species()..name = "Pike": 15,
      }, DisplayDateRange.thisYear);

      await tester.pumpWidget(Testable((_) => Chart(
        series: [series1, series2],
        labelBuilder: (species) => species.name,
        chartPageDescription: "A description.",
        showAll: true,
      )));
      expect(find.text("View all"), findsNothing);

      await tester.pumpWidget(Testable((_) => Chart(
        series: [series1, series2],
        labelBuilder: (species) => species.name,
        viewAllTitle: "View all",
        chartPageDescription: "A description.",
        showAll: true,
      )));
      expect(find.text("View all"), findsNothing);
    });
  });

  group("_ChartPage", () {
    testWidgets("With filters", (WidgetTester tester) async {
      Series<Species> series1 = Series({
        Species()..name = "Bass": 10,
        Species()..name = "Catfish": 3,
        Species()..name = "Skipjack": 17,
        Species()..name = "Pike": 30,
      }, DisplayDateRange.lastYear);

      await tester.pumpWidget(Testable(
        (_) => Chart(
          series: [series1],
          labelBuilder: (species) => species.name,
          viewAllTitle: "View all",
          chartPageDescription: "A description.",
          chartPageFilters: { "Filter 1", "Filter 2" },
        ),
        mediaQueryData: MediaQueryData(
          // Chart row widths are based on screen size. Need to give a screen
          // size to tap.
          size: Size(500, 500),
        ),
        navigatorObserver: MockNavigatorObserver(),
      ));

      expect(find.text("View all"), findsOneWidget);
      await tester.tap(find.text("View all"));
      await tester.pumpAndSettle();

      expect(find.text("Filter 1"), findsOneWidget);
      expect(find.text("Filter 2"), findsOneWidget);
    });

    testWidgets("Without filters", (WidgetTester tester) async {
      Series<Species> series1 = Series({
        Species()..name = "Bass": 10,
        Species()..name = "Catfish": 3,
        Species()..name = "Skipjack": 17,
        Species()..name = "Pike": 30,
      }, DisplayDateRange.lastYear);

      await tester.pumpWidget(Testable(
            (_) => Chart(
          series: [series1],
          labelBuilder: (species) => species.name,
          viewAllTitle: "View all",
          chartPageDescription: "A description.",
        ),
        mediaQueryData: MediaQueryData(
          // Chart row widths are based on screen size. Need to give a screen
          // size to tap.
          size: Size(500, 500),
        ),
        navigatorObserver: MockNavigatorObserver(),
      ));

      expect(find.text("View all"), findsOneWidget);
      await tester.tap(find.text("View all"));
      await tester.pumpAndSettle();

      expect(find.byType(ChipWrap), findsNothing);
    });
  });
}