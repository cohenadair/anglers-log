import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/text.dart';

import '../test_utils.dart';

void main() {
  group("TimeText", () {
    testWidgets("12 hour", (WidgetTester tester) async {
      await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(alwaysUse24HourFormat: false),
        child: Testable(TimeText(TimeOfDay(hour: 15, minute: 30))),
      ));
      expect(find.text("3:30 PM"), findsOneWidget);

      await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(alwaysUse24HourFormat: false),
        child: Testable(TimeText(TimeOfDay(hour: 4, minute: 30))),
      ));
      expect(find.text("4:30 AM"), findsOneWidget);
    });

    testWidgets("24 hour", (WidgetTester tester) async {
      await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(alwaysUse24HourFormat: true),
        child: Testable(TimeText(TimeOfDay(hour: 15, minute: 30))),
      ));
      expect(find.text("15:30"), findsOneWidget);

      await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(alwaysUse24HourFormat: true),
        child: Testable(TimeText(TimeOfDay(hour: 4, minute: 30))),
      ));
      expect(find.text("04:30"), findsOneWidget);
    });
  });
}