import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

void main() {
  group("HeadingDivider", () {
    testWidgets("Divider shown", (tester) async {
      await tester.pumpWidget(Testable((_) => HeadingDivider("Test")));
      expect(find.byType(MinDivider), findsOneWidget);
    });

    testWidgets("Divider hidden", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => HeadingDivider(
            "Test",
            showDivider: false,
          ),
        ),
      );
      expect(find.byType(MinDivider), findsNothing);
    });
  });

  group("HeadingNoteDivider", () {
    testWidgets("Input", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => HeadingNoteDivider(
            title: "Title",
            hideNote: false,
            noteIcon: null,
            note: null,
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);

      await tester.pumpWidget(
        Testable(
          (_) => HeadingNoteDivider(
            title: "Title",
            hideNote: false,
            noteIcon: null,
            note: "A note",
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);

      await tester.pumpWidget(
        Testable(
          (_) => HeadingNoteDivider(
            title: "Title",
            hideNote: false,
            noteIcon: Icons.group,
            note: null,
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets("Visible note", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => HeadingNoteDivider(
            title: "Title",
            hideNote: false,
            noteIcon: Icons.group,
            note: "A note %s",
          ),
        ),
      );
      expect(find.byType(IconLabel), findsOneWidget);
      expect(find.byType(Empty), findsNothing);
    });

    testWidgets("Hidden note", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => HeadingNoteDivider(
            title: "Title",
            hideNote: true,
            noteIcon: Icons.group,
            note: "A note %s",
          ),
        ),
      );
      expect(find.byType(IconLabel), findsNothing);
      expect(find.byType(Empty), findsOneWidget);
    });
  });

  group("EmptyFutureBuilder", () {
    testWidgets("Empty widget shown until finished", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => EmptyFutureBuilder<bool>(
            future: Future.delayed(Duration(milliseconds: 100), () => true),
            builder: (context, value) => Text(value! ? "True" : "False"),
          ),
        ),
      );
      expect(find.byType(Empty), findsOneWidget);
      await tester.pumpAndSettle(Duration(milliseconds: 150));
      expect(find.text("True"), findsOneWidget);
    });
  });

  group("ChipWrap", () {
    testWidgets("Empty input", (tester) async {
      await tester.pumpWidget(Testable((_) => ChipWrap()));
      expect(find.byType(Empty), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets("All chips rendered", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ChipWrap({
            "Chip 1",
            "Chip 2",
            "Chip 3",
            "Chip 4",
          }),
        ),
      );
      expect(find.byType(Empty), findsNothing);
      expect(find.byType(Chip), findsNWidgets(4));
    });
  });

  group("Loading", () {
    testWidgets("Centered includes a centered column", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => Loading(
            isCentered: true,
            label: "Test...",
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(findFirst<Column>(tester).mainAxisAlignment,
          MainAxisAlignment.center);
    });

    testWidgets("Label not centered includes start aligned column",
        (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => Loading(
            isCentered: false,
            label: "Test...",
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(
          findFirst<Column>(tester).mainAxisAlignment, MainAxisAlignment.start);
    });

    testWidgets("Not centered; no label just shows indicator", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => Loading(
            isCentered: false,
          ),
        ),
      );

      expect(find.byType(Column), findsNothing);
    });
  });
}
