import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/pages/report_list_page.dart';
import 'package:mobile/pages/save_report_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/report_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/pro_overlay.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  var summaries = <Report>[
    Report()
      ..id = randomId()
      ..name = "Summary 1"
      ..type = Report_Type.summary,
    Report()
      ..id = randomId()
      ..name = "Summary 2"
      ..type = Report_Type.summary,
  ];

  var comparisons = <Report>[
    Report()
      ..id = randomId()
      ..name = "Comparison 1"
      ..type = Report_Type.comparison,
    Report()
      ..id = randomId()
      ..name = "Comparison 2"
      ..type = Report_Type.comparison,
  ];

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.localDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(true);
    when(appManager.subscriptionManager.isFree).thenReturn(false);

    when(appManager.baitManager.list()).thenReturn([]);

    when(appManager.reportManager.list())
        .thenReturn([...comparisons, ...summaries]);
    when(appManager.reportManager.listSortedByDisplayName(any))
        .thenReturn([...comparisons, ...summaries]);
    when(appManager.reportManager.defaultReports).thenReturn([
      Report(id: reportIdPersonalBests),
      Report(id: reportIdCatchSummary),
      Report(id: reportIdTripSummary),
    ]);
    when(appManager.reportManager.displayName(any, any))
        .thenAnswer((invocation) {
      var id = invocation.positionalArguments[1].id;
      if (id == reportIdPersonalBests) {
        return "Personal Bests";
      } else if (id == reportIdCatchSummary) {
        return "Catch Summary";
      } else if (id == reportIdTripSummary) {
        return "Trip Summary";
      }
      return invocation.positionalArguments[1].name;
    });

    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airVisibilitySystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airPressureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
  });

  testWidgets("Current item is selected", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ReportListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, __) => true,
          initialValue: comparisons.first,
        ),
      ),
      appManager: appManager,
    ));

    expect(
      find.descendant(
        of: find.widgetWithText(ManageableListItem, "Comparison 1"),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
  });

  testWidgets("Callback is invoked", (tester) async {
    dynamic pickedReport;
    await tester.pumpWidget(Testable(
      (_) => ReportListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, report) {
            pickedReport = report;
            return true;
          },
          initialValue: comparisons.first,
        ),
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Summary 1"));

    expect(pickedReport, isNotNull);
    expect(pickedReport.type, Report_Type.summary);
    expect(pickedReport.name, "Summary 1");
  });

  testWidgets("Different item types are displayed correctly", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ReportListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, __) => true,
        ),
      ),
      appManager: appManager,
    ));

    expect(find.text("Catch Summary"), findsOneWidget);
    expect(find.text("Trip Summary"), findsOneWidget);
    expect(find.text("Personal Bests"), findsOneWidget);
    expect(find.text("Custom Reports"), findsOneWidget);
    expect(find.text("Comparison 1"), findsOneWidget);
    expect(find.text("Comparison 2"), findsOneWidget);
    expect(find.text("Summary 1"), findsOneWidget);
    expect(find.text("Summary 2"), findsOneWidget);
  });

  testWidgets("Delete reports", (tester) async {
    when(appManager.reportManager.delete(any))
        .thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(Testable(
      (_) => ReportListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, __) => true,
        ),
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.widgetWithText(ActionButton, "EDIT"));
    await tapAndSettle(
      tester,
      find.descendant(
        of: find.widgetWithText(ManageableListItem, "Comparison 1"),
        matching: find.byIcon(Icons.delete),
      ),
    );
    await tapAndSettle(tester, find.text("DELETE"));

    verify(appManager.reportManager.delete(comparisons.first.id)).called(1);
  });

  testWidgets("Default reports cannot be deleted", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ReportListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, __) => true,
        ),
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.widgetWithText(ActionButton, "EDIT"));

    var crossFade = tester.firstWidget<AnimatedCrossFade>(
      find.descendant(
        of: find.widgetWithText(ManageableListItem, "Catch Summary"),
        matching: find.byType(AnimatedCrossFade),
      ),
    );

    // The Empty widget is shown.
    expect(crossFade.crossFadeState, CrossFadeState.showSecond);
  });

  testWidgets("Note shown when custom reports is empty", (tester) async {
    when(appManager.reportManager.list()).thenReturn([]);

    await tester.pumpWidget(Testable(
      (_) => ReportListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, __) => true,
        ),
      ),
      appManager: appManager,
    ));

    expect(find.byType(IconLabel), findsOneWidget);
  });

  testWidgets("Custom reports are sorted alphabetically", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ReportListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, __) => true,
          isRequired: true,
        ),
      ),
      appManager: appManager,
    ));

    var textWidgets = find.descendant(
      of: find.byType(ManageableListItem),
      matching: find.byType(Text),
    );
    expect(
      (textWidgets.at(0).evaluate().single.widget as Text).data,
      "Personal Bests",
    );
    expect(
      (textWidgets.at(2).evaluate().single.widget as Text).data,
      "Catch Summary",
    );
    expect(
      (textWidgets.at(4).evaluate().single.widget as Text).data,
      "Trip Summary",
    );
    expect(
      (textWidgets.at(6).evaluate().single.widget as Text).data,
      "Comparison 1",
    );
    expect(
      (textWidgets.at(8).evaluate().single.widget as Text).data,
      "Comparison 2",
    );
    expect(
      (textWidgets.at(10).evaluate().single.widget as Text).data,
      "Summary 1",
    );
    expect(
      (textWidgets.at(12).evaluate().single.widget as Text).data,
      "Summary 2",
    );
  });

  testWidgets("ProPage is shown when user is not pro", (tester) async {
    when(appManager.baitManager.attachmentsDisplayValues(any, any))
        .thenReturn([]);
    when(appManager.fishingSpotManager.list(any)).thenReturn([]);

    when(appManager.subscriptionManager.isPro).thenReturn(false);
    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));

    await tester.pumpWidget(Testable(
      (_) => ReportListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, __) => true,
          isRequired: true,
        ),
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byIcon(Icons.add));
    expect(find.byType(ProPage), findsOneWidget);

    await tapAndSettle(tester, find.byType(CloseButton));

    when(appManager.subscriptionManager.isPro).thenReturn(true);
    await tapAndSettle(tester, find.byIcon(Icons.add));
    expect(find.byType(SaveReportPage), findsOneWidget);
  });

  testWidgets("Dividers are rendered", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ReportListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, __) => true,
          isRequired: true,
        ),
      ),
      appManager: appManager,
    ));

    expect(find.byType(MinDivider), findsNWidgets(2));
    expect(find.byType(HeadingNoteDivider), findsOneWidget);
  });

  testWidgets("All reports are rendered", (tester) async {
    when(appManager.reportManager.defaultReports).thenReturn([
      Report(id: reportIdPersonalBests),
      Report(id: reportIdCatchSummary),
      Report(id: reportIdTripSummary),
      Report(id: reportIdFishingSpotSummary),
      Report(id: reportIdAnglerSummary),
    ]);

    await tester.pumpWidget(Testable(
      (_) => ReportListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, __) => true,
          isRequired: true,
        ),
      ),
      appManager: appManager,
    ));

    var items =
        findFirst<ManageableListPage>(tester).itemManager.loadItems(null);
    expect(items.length, 12);

    expect(items[0].id, reportIdPersonalBests);
    // items[1] is a MinDivider verified below.
    expect(items[2].id, reportIdCatchSummary);
    expect(items[3].id, reportIdTripSummary);
    // items[4] is a MinDivider verified below.
    expect(items[5].id, reportIdFishingSpotSummary);
    expect(items[6].id, reportIdAnglerSummary);
    // items[7] is a HeadingNoteDivider verified below.
    expect(items[8].name, "Comparison 1");
    expect(items[9].name, "Comparison 2");
    expect(items[10].name, "Summary 1");
    expect(items[11].name, "Summary 2");

    expect(find.byType(MinDivider), findsNWidgets(3));
    expect(find.byType(HeadingNoteDivider), findsOneWidget);
  });

  testWidgets("Pro overlay on custom reports is shown", (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(true);
    when(appManager.reportManager.defaultReports).thenReturn([
      Report(id: reportIdPersonalBests),
      Report(id: reportIdCatchSummary),
    ]);
    when(appManager.reportManager.entityCount).thenReturn(1);

    await tester.pumpWidget(Testable(
      (_) => ReportListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, __) => true,
          isRequired: true,
        ),
      ),
      appManager: appManager,
    ));

    expect(find.byType(ProOverlay), findsOneWidget);
  });

  testWidgets("Pro overlay shows custom reports on upgrade", (tester) async {
    var subscriptionController = StreamController.broadcast(sync: true);
    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => subscriptionController.stream);

    when(appManager.reportManager.defaultReports).thenReturn([
      Report(id: reportIdPersonalBests),
      Report(id: reportIdCatchSummary),
    ]);
    when(appManager.reportManager.entityCount).thenReturn(1);
    when(appManager.reportManager.listSortedByDisplayName(any)).thenReturn([
      Report(
        id: randomId(),
        name: "Test Custom Report",
      ),
    ]);

    // Start as a free user.
    when(appManager.subscriptionManager.isFree).thenReturn(true);

    var invoked = false;
    await tester.pumpWidget(Testable(
      (_) => ReportListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, __) {
            invoked = true;
            return true;
          },
          isRequired: true,
        ),
      ),
      appManager: appManager,
    ));
    expect(find.text("UPGRADE"), findsOneWidget);
    expect(find.text("Test Custom Report"), findsNothing);

    // Upgrade.
    subscriptionController.add(null);
    when(appManager.subscriptionManager.isFree).thenReturn(false);
    await tester.pumpAndSettle();

    expect(find.text("UPGRADE"), findsNothing);
    expect(find.text("Test Custom Report"), findsOneWidget);

    // Ensure custom report is selectable.
    await tapAndSettle(tester, find.text("Test Custom Report"));
    expect(find.byType(ReportListPage), findsNothing);
    expect(invoked, isTrue);
  });

  testWidgets("Pro overlay on custom reports is hidden", (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(true);
    when(appManager.reportManager.defaultReports).thenReturn([
      Report(id: reportIdPersonalBests),
      Report(id: reportIdCatchSummary),
    ]);
    when(appManager.reportManager.entityCount).thenReturn(0);

    await tester.pumpWidget(Testable(
      (_) => ReportListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, __) => true,
          isRequired: true,
        ),
      ),
      appManager: appManager,
    ));

    expect(find.byType(ProOverlay), findsNothing);
  });
}
