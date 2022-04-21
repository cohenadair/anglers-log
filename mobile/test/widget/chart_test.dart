import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/widgets/chart.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  group("Initialization", () {
    testWidgets("Assertion if no title/description when not showing all",
        (tester) async {
      var series = Series<Species>({
        Species()..name = "Bass": 5,
      }, DateRange(period: DateRange_Period.last7Days));

      await tester.pumpWidget(
        Testable(
          (_) => Chart(
            series: [series],
            labelBuilder: (_) => null,
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);

      await tester.pumpWidget(
        Testable(
          (_) => Chart(
            series: [series],
            labelBuilder: (_) => null,
            viewAllTitle: "Title",
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);

      await tester.pumpWidget(
        Testable(
          (_) => Chart(
            series: [series],
            labelBuilder: (_) => null,
            chartPageDescription: "A description.",
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets("Assertion if not all series data has equal length",
        (tester) async {
      var series1 = Series<Species>({
        Species()..name = "Bass": 5,
      }, DateRange(period: DateRange_Period.last7Days));

      var series2 = Series<Species>({
        Species()..name = "Bass": 5,
        Species()..name = "Trout": 10,
      }, DateRange(period: DateRange_Period.last7Days));

      await tester.pumpWidget(
        Testable(
          (_) => Chart(
            series: [series1, series2],
            labelBuilder: (dynamic _) => "",
            viewAllTitle: "Title",
            chartPageDescription: "A description.",
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);
    });
  });

  group("Legend", () {
    testWidgets("Single series does not show legend", (tester) async {
      var series = Series<Species>({
        Species()..name = "Bass": 5,
        Species()..name = "Trout": 10,
      }, DateRange(period: DateRange_Period.last7Days));

      await tester.pumpWidget(
        Testable(
          (_) => Chart(
            series: [series],
            labelBuilder: (dynamic _) => "",
            viewAllTitle: "Title",
            chartPageDescription: "A description.",
          ),
        ),
      );
      expect(find.byType(Empty), findsOneWidget);
      expect(find.text("Last 7 days"), findsNothing);
    });

    testWidgets("Multiple series shows legend", (tester) async {
      var series1 = Series<Species>({
        Species()..name = "Bass": 5,
        Species()..name = "Trout": 10,
      }, DateRange(period: DateRange_Period.last7Days));

      var series2 = Series<Species>({
        Species()..name = "Bass": 8,
        Species()..name = "Trout": 11,
      }, DateRange(period: DateRange_Period.lastMonth));

      await tester.pumpWidget(
        Testable(
          (_) => Chart(
            series: [series1, series2],
            labelBuilder: (dynamic _) => "",
            viewAllTitle: "Title",
            chartPageDescription: "A description.",
          ),
        ),
      );
      expect(find.text("Last month"), findsOneWidget);
      expect(find.text("Last 7 days"), findsOneWidget);
    });
  });

  group("Chart rows", () {
    testWidgets("Row with non-null onTap action", (tester) async {
      var appManager = StubbedAppManager();
      when(appManager.timeManager.currentDateTime).thenReturn(now());

      var series = Series<Species>({
        Species()..name = "Bass": 10,
      }, DateRange(period: DateRange_Period.lastMonth));

      var tapped = false;
      await tester.pumpWidget(Testable(
        (_) => Chart(
          series: [series],
          labelBuilder: (dynamic species) => species.name,
          viewAllTitle: "Title",
          chartPageDescription: "A description.",
          onTapRow: (dynamic _, __) => tapped = true,
        ),
        mediaQueryData: const MediaQueryData(
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

    testWidgets("Row with non-null onTap, but value of 0 is disabled",
        (tester) async {
      var appManager = StubbedAppManager();
      when(appManager.timeManager.currentDateTime).thenReturn(now());

      var series = Series<Species>({
        Species()..name = "Bass": 0,
      }, DateRange(period: DateRange_Period.lastMonth));

      var tapped = false;
      await tester.pumpWidget(Testable(
        (_) => Chart(
          series: [series],
          labelBuilder: (dynamic species) => species.name,
          viewAllTitle: "Title",
          chartPageDescription: "A description.",
          onTapRow: (dynamic _, __) => tapped = true,
        ),
        mediaQueryData: const MediaQueryData(
          // Chart row widths are based on screen size. Need to give a screen
          // size to tap.
          size: Size(500, 500),
        ),
        appManager: appManager,
      ));
      expect(find.byType(InkWell), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      expect(tapped, isFalse);
    });

    testWidgets("Normal series data rows", (tester) async {
      var series1 = Series<Species>({
        Species()..name = "Bass": 10,
        Species()..name = "Catfish": 3,
        Species()..name = "Skipjack": 17,
        Species()..name = "Pike": 30,
      }, DateRange(period: DateRange_Period.lastYear));

      var series2 = Series<Species>({
        Species()..name = "Bass": 12,
        Species()..name = "Catfish": 5,
        Species()..name = "Skipjack": 13,
        Species()..name = "Pike": 15,
      }, DateRange(period: DateRange_Period.thisYear));

      var series3 = Series<Species>({
        Species()..name = "Bass": 0,
        Species()..name = "Catfish": 0,
        Species()..name = "Skipjack": 0,
        Species()..name = "Pike": 0,
      }, DateRange(period: DateRange_Period.lastMonth));

      await tester.pumpWidget(
        Testable(
          (_) => ListView(
            children: [
              Chart<Species>(
                series: [series1, series2, series3],
                labelBuilder: (species) => species.name,
                viewAllTitle: "View all",
                chartPageDescription: "A description.",
              ),
            ],
          ),
        ),
      );

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

    testWidgets("fullPageSeries is used", (tester) async {
      var series1 = Series<Species>({
        Species()..name = "Bass": 10,
        Species()..name = "Catfish": 3,
        Species()..name = "Skipjack": 17,
        Species()..name = "Pike": 30,
      }, DateRange(period: DateRange_Period.lastYear));

      var series2 = Series<Species>({
        Species()..name = "Bass": 12,
        Species()..name = "Catfish": 5,
        Species()..name = "Skipjack": 13,
        Species()..name = "Pike": 15,
      }, DateRange(period: DateRange_Period.thisYear));

      await tester.pumpWidget(
        Testable(
          (_) => ListView(
            children: [
              Chart<Species>(
                series: [series1],
                fullPageSeries: [series2],
                labelBuilder: (species) => species.name,
                viewAllTitle: "View all",
                chartPageDescription: "A description.",
              ),
            ],
          ),
        ),
      );

      await tapAndSettle(tester, find.text("View all"));

      expect(find.text("Bass (12)"), findsOneWidget);
      expect(find.text("Catfish (5)"), findsOneWidget);
      expect(find.text("Skipjack (13)"), findsOneWidget);
      expect(find.text("Pike (15)"), findsOneWidget);
    });
  });

  group("View all row", () {
    testWidgets("If condensed, row is rendered", (tester) async {
      var series1 = Series<Species>({
        Species()..name = "Bass": 10,
        Species()..name = "Catfish": 3,
        Species()..name = "Skipjack": 17,
        Species()..name = "Pike": 30,
      }, DateRange(period: DateRange_Period.lastYear));

      var series2 = Series<Species>({
        Species()..name = "Bass": 12,
        Species()..name = "Catfish": 5,
        Species()..name = "Skipjack": 13,
        Species()..name = "Pike": 15,
      }, DateRange(period: DateRange_Period.thisYear));

      await tester.pumpWidget(
        Testable(
          (_) => ListView(
            children: [
              Chart(
                series: [series1, series2],
                labelBuilder: (dynamic species) => species.name,
                viewAllTitle: "View all",
                chartPageDescription: "A description.",
              ),
            ],
          ),
        ),
      );

      expect(find.text("View all"), findsOneWidget);
    });

    testWidgets("If condensed and all series length < min, row is not rendered",
        (tester) async {
      var series1 = Series<Species>({
        Species()..name = "Bass": 10,
        Species()..name = "Catfish": 3,
      }, DateRange(period: DateRange_Period.lastYear));

      var series2 = Series<Species>({
        Species()..name = "Bass": 12,
        Species()..name = "Catfish": 5,
      }, DateRange(period: DateRange_Period.thisYear));

      await tester.pumpWidget(
        Testable(
          (_) => ListView(
            children: [
              Chart(
                series: [series1, series2],
                labelBuilder: (dynamic species) => species.name,
                viewAllTitle: "View all",
                chartPageDescription: "A description.",
              ),
            ],
          ),
        ),
      );

      expect(find.text("View all"), findsNothing);
    });

    testWidgets("If showing all, no show all row is rendered", (tester) async {
      var series1 = Series<Species>({
        Species()..name = "Bass": 10,
        Species()..name = "Catfish": 3,
        Species()..name = "Skipjack": 17,
        Species()..name = "Pike": 30,
      }, DateRange(period: DateRange_Period.lastYear));

      var series2 = Series<Species>({
        Species()..name = "Bass": 12,
        Species()..name = "Catfish": 5,
        Species()..name = "Skipjack": 13,
        Species()..name = "Pike": 15,
      }, DateRange(period: DateRange_Period.thisYear));

      await tester.pumpWidget(
        Testable(
          (_) => ListView(
            children: [
              Chart(
                series: [series1, series2],
                labelBuilder: (dynamic species) => species.name,
                chartPageDescription: "A description.",
                showAll: true,
              ),
            ],
          ),
        ),
      );
      expect(find.text("View all"), findsNothing);

      await tester.pumpWidget(
        Testable(
          (_) => ListView(
            children: [
              Chart(
                series: [series1, series2],
                labelBuilder: (dynamic species) => species.name,
                viewAllTitle: "View all",
                chartPageDescription: "A description.",
                showAll: true,
              ),
            ],
          ),
        ),
      );
      expect(find.text("View all"), findsNothing);
    });
  });

  group("_ChartPage", () {
    testWidgets("With filters", (tester) async {
      var series1 = Series<Species>({
        Species()..name = "Bass": 10,
        Species()..name = "Catfish": 3,
        Species()..name = "Skipjack": 17,
        Species()..name = "Pike": 30,
      }, DateRange(period: DateRange_Period.lastYear));

      await tester.pumpWidget(Testable(
        (_) => Chart(
          series: [series1],
          labelBuilder: (dynamic species) => species.name,
          viewAllTitle: "View all",
          chartPageDescription: "A description.",
          chartPageFilters: const {"Filter 1", "Filter 2"},
        ),
        mediaQueryData: const MediaQueryData(
          // Chart row widths are based on screen size. Need to give a screen
          // size to tap.
          size: Size(500, 500),
        ),
      ));

      expect(find.text("View all"), findsOneWidget);
      await tester.tap(find.text("View all"));
      await tester.pumpAndSettle();

      expect(find.text("Filter 1"), findsOneWidget);
      expect(find.text("Filter 2"), findsOneWidget);
    });

    testWidgets("Without filters", (tester) async {
      var series1 = Series<Species>({
        Species()..name = "Bass": 10,
        Species()..name = "Catfish": 3,
        Species()..name = "Skipjack": 17,
        Species()..name = "Pike": 30,
      }, DateRange(period: DateRange_Period.lastYear));

      await tester.pumpWidget(Testable(
        (_) => Chart(
          series: [series1],
          labelBuilder: (dynamic species) => species.name,
          viewAllTitle: "View all",
          chartPageDescription: "A description.",
        ),
        mediaQueryData: const MediaQueryData(
          // Chart row widths are based on screen size. Need to give a screen
          // size to tap.
          size: Size(500, 500),
        ),
      ));

      expect(find.text("View all"), findsOneWidget);
      await tester.tap(find.text("View all"));
      await tester.pumpAndSettle();

      expect(find.byType(ChipWrap), findsNothing);
    });
  });
}
