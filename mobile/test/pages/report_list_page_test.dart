import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/pages/report_list_page.dart';
import 'package:mobile/pages/save_report_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
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

    when(appManager.authManager.stream).thenAnswer((_) => Stream.empty());

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.localDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    when(appManager.baitManager.list()).thenReturn([]);

    when(appManager.reportManager.list())
        .thenReturn([]..addAll(comparisons)..addAll(summaries));
    when(appManager.reportManager.listSortedByName())
        .thenReturn([]..addAll(comparisons)..addAll(summaries));

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

    expect(find.text("Overview"), findsOneWidget);
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

  testWidgets("Overview report cannot be deleted", (tester) async {
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
        of: find.widgetWithText(ManageableListItem, "Overview"),
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
      "Overview",
    );
    expect(
      (textWidgets.at(2).evaluate().single.widget as Text).data,
      "Comparison 1",
    );
    expect(
      (textWidgets.at(4).evaluate().single.widget as Text).data,
      "Comparison 2",
    );
    expect(
      (textWidgets.at(6).evaluate().single.widget as Text).data,
      "Summary 1",
    );
    expect(
      (textWidgets.at(8).evaluate().single.widget as Text).data,
      "Summary 2",
    );
  });

  testWidgets("ProPage is shown when user is not pro", (tester) async {
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
}
