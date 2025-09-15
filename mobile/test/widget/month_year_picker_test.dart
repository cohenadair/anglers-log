import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/month_year_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/timezone.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.lib.timeManager.currentDateTime,
    ).thenReturn(dateTime(2022, 10, 15));
  });

  void verifyMonth(WidgetTester tester, String month, Color color) {
    expect(
      (findFirstWithText<AnimatedContainer>(tester, month).decoration
              as BoxDecoration)
          .color,
      color,
    );
  }

  testWidgets("Changing year", (tester) async {
    await pumpContext(
      tester,
      (context) => Scaffold(
        body: Button(
          text: "Test",
          onPressed: () => showMonthYearPicker(context),
        ),
      ),
    );

    await tapAndSettle(tester, find.text("TEST"));
    expect(find.text("2022"), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.chevron_left));
    expect(find.text("2022"), findsNothing);
    expect(find.text("2021"), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.chevron_right));
    await tapAndSettle(tester, find.byIcon(Icons.chevron_right));
    expect(find.text("2022"), findsNothing);
    expect(find.text("2021"), findsNothing);
    expect(find.text("2023"), findsOneWidget);
  });

  testWidgets("Changing month", (tester) async {
    await pumpContext(
      tester,
      (context) => Scaffold(
        body: Button(
          text: "Test",
          onPressed: () => showMonthYearPicker(context),
        ),
      ),
    );

    await tapAndSettle(tester, find.text("TEST"));
    verifyMonth(tester, "Oct", AppConfig.get.colorAppTheme);

    await tapAndSettle(tester, find.text("Mar"));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    verifyMonth(tester, "Oct", Colors.transparent);
    verifyMonth(tester, "Mar", AppConfig.get.colorAppTheme);
  });

  testWidgets("Non-null result", (tester) async {
    TZDateTime? result;
    await pumpContext(
      tester,
      (context) => Scaffold(
        body: Button(
          text: "Test",
          onPressed: () async {
            result = await showMonthYearPicker(context);
          },
        ),
      ),
    );

    await tapAndSettle(tester, find.text("TEST"));
    await tapAndSettle(tester, find.text("Mar"));
    await tapAndSettle(tester, find.byIcon(Icons.chevron_left));
    await tapAndSettle(tester, find.text("OK"));

    expect(result, isNotNull);
    expect(result!.year, 2021);
    expect(result!.month, 3);
  });

  testWidgets("Null result", (tester) async {
    TZDateTime? result;
    await pumpContext(
      tester,
      (context) => Scaffold(
        body: Button(
          text: "Test",
          onPressed: () async {
            result = await showMonthYearPicker(context);
          },
        ),
      ),
    );

    await tapAndSettle(tester, find.text("TEST"));
    await tapAndSettle(tester, find.text("Mar"));
    await tapAndSettle(tester, find.byIcon(Icons.chevron_left));
    await tapAndSettle(tester, find.text("CANCEL"));

    expect(result, isNull);
  });
}
