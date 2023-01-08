import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

void main() {
  group("SingleLineText", () {
    testWidgets("Null text renders Empty", (tester) async {
      await pumpContext(tester, (_) => const SingleLineText(null));
      expect(find.byType(Empty), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets("Empty text renders Empty", (tester) async {
      await pumpContext(tester, (_) => const SingleLineText(""));
      expect(find.byType(Empty), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets("Non-empty text renders text", (tester) async {
      await pumpContext(tester, (_) => const SingleLineText("Test"));
      expect(find.byType(Empty), findsNothing);
      expect(find.byType(Text), findsOneWidget);
    });
  });

  group("IconNoteLabel", () {
    testWidgets("Bad input", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => IconLabel(
            text: "Test",
            textArg: const Icon(Icons.group),
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets("Valid input", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => IconLabel(
            text: "Test %s",
            textArg: const Icon(Icons.group),
          ),
        ),
      );
      expect(find.byType(IconLabel), findsOneWidget);
    });
  });

  group("EnabledLabel", () {
    testWidgets("State color", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const EnabledLabel(
            "Test",
            enabled: true,
          ),
        ),
      );
      var enabledColor =
          (tester.firstWidget(find.text("Test")) as Text).style!.color;

      await tester.pumpWidget(
        Testable(
          (_) => const EnabledLabel(
            "Test 2",
            enabled: false,
          ),
        ),
      );
      var disabledColor =
          (tester.firstWidget(find.text("Test 2")) as Text).style!.color;

      expect(enabledColor != disabledColor, isTrue);
    });
  });
}
