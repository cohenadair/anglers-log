import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

main() {
  group("HeadingNoteDivider", () {
    testWidgets("Input", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => HeadingNoteDivider(
        title: "Title",
        hideNote: false,
        noteIcon: null,
        note: null,
      )));
      expect(tester.takeException(), isAssertionError);

      await tester.pumpWidget(Testable((_) => HeadingNoteDivider(
        title: "Title",
        hideNote: false,
        noteIcon: null,
        note: "A note",
      )));
      expect(tester.takeException(), isAssertionError);

      await tester.pumpWidget(Testable((_) => HeadingNoteDivider(
        title: "Title",
        hideNote: false,
        noteIcon: Icons.group,
        note: null,
      )));
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets("Visible note", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => HeadingNoteDivider(
        title: "Title",
        hideNote: false,
        noteIcon: Icons.group,
        note: "A note %s",
      )));
      expect(find.byType(IconNoteLabel), findsOneWidget);
      expect(find.byType(Empty), findsNothing);
    });

    testWidgets("Hidden note", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => HeadingNoteDivider(
        title: "Title",
        hideNote: true,
        noteIcon: Icons.group,
        note: "A note %s",
      )));
      expect(find.byType(IconNoteLabel), findsNothing);
      expect(find.byType(Empty), findsOneWidget);
    });
  });

  group("EmptyFutureBuilder", () {
    testWidgets("Empty widget shown until finished", (WidgetTester tester)
        async
    {
      await tester.pumpWidget(Testable((_) => EmptyFutureBuilder<bool>(
        future: Future.delayed(Duration(milliseconds: 100), () => true),
        builder: (context, value) => Text(value ? "True" : "False"),
      )));
      expect(find.byType(Empty), findsOneWidget);
      await tester.pumpAndSettle(Duration(milliseconds: 150));
      expect(find.text("True"), findsOneWidget);
    });
  });

  group("ChipWrap", () {
    testWidgets("Empty input", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => ChipWrap()));
      expect(find.byType(Empty), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets("All chips rendered", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => ChipWrap({
        "Chip 1", "Chip 2", "Chip 3", "Chip 4",
      })));
      expect(find.byType(Empty), findsNothing);
      expect(find.byType(Chip), findsNWidgets(4));
    });
  });
}