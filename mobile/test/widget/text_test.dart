import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/text.dart';

import '../test_utils.dart';

void main() {
  group("IconNoteLabel", () {
    testWidgets("Bad input", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => IconNoteLabel(
        text: "Test",
        icon: Icon(Icons.group),
      )));
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets("Valid input", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => IconNoteLabel(
        text: "Test %s",
        icon: Icon(Icons.group),
      )));
      expect(find.byType(IconNoteLabel), findsOneWidget);
    });
  });

  group("PrimaryLabel", () {
    testWidgets("State color", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => PrimaryLabel("Test",
        enabled: true,
      )));
      Color enabledColor =
          (tester.firstWidget(find.text("Test")) as Text).style.color;

      await tester.pumpWidget(Testable((_) => PrimaryLabel("Test 2",
        enabled: false,
      )));
      Color disabledColor =
          (tester.firstWidget(find.text("Test 2")) as Text).style.color;

      expect(enabledColor != disabledColor, isTrue);
    });
  });

  group("EnabledLabel", () {
    testWidgets("State color", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => EnabledLabel("Test",
        enabled: true,
      )));
      Color enabledColor =
          (tester.firstWidget(find.text("Test")) as Text).style.color;

      await tester.pumpWidget(Testable((_) => EnabledLabel("Test 2",
        enabled: false,
      )));
      Color disabledColor =
          (tester.firstWidget(find.text("Test 2")) as Text).style.color;

      expect(enabledColor != disabledColor, isTrue);
    });
  });
}