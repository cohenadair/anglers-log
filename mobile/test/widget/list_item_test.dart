import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

main() {
  group("ExpansionListItem", () {
    testWidgets("Expanded on tap", (WidgetTester tester) async {
      bool changed = false;
      await tester.pumpWidget(Testable((_) => ExpansionListItem(
        title: Text("Title"),
        children: [
          Text("Child 1"),
          Text("Child 2"),
        ],
        onExpansionChanged: (_) => changed = true,
      )));

      // Verify children aren't showing.
      expect(find.byType(ExpansionListItem), findsOneWidget);
      expect(find.text("Child 1"), findsNothing);
      expect(changed, isFalse);

      // Expand tile.
      await tester.tap(find.text("Title"));
      await tester.pumpAndSettle();

      expect(find.text("Child 1"), findsOneWidget);
      expect(find.text("Child 2"), findsOneWidget);
      expect(changed, isTrue);
    });
  });

  group("ManageableListItem", () {
    testWidgets("Editing shows edit/delete buttons", (WidgetTester tester)
        async
    {
      await tester.pumpWidget(Testable((_) => ManageableListItem(
        child: Text("Child"),
        editing: true,
        onTapDeleteButton: () {},
      )));
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.byType(RightChevronIcon), findsOneWidget);
    });

    testWidgets("Custom text widget doesn't use default style",
        (WidgetTester tester) async
    {
      await tester.pumpWidget(Testable((_) => ManageableListItem(
        child: NoteLabel("Child"),
        onTapDeleteButton: () {},
      )));
      expect(find.byType(NoteLabel), findsOneWidget);
    });

    testWidgets("Tapping delete button shows dialog", (WidgetTester tester)
        async
    {
      await tester.pumpWidget(Testable((_) => ManageableListItem(
        child: Text("Child"),
        deleteMessageBuilder: (_) => Text("A delete message."),
        onConfirmDelete: () {},
        editing: true,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      expect(find.text("A delete message."), findsOneWidget);
    });

    testWidgets("onConfirmDelete invoked", (WidgetTester tester) async {
      bool confirmed = false;
      await tester.pumpWidget(Testable((_) => ManageableListItem(
        child: Text("Child"),
        deleteMessageBuilder: (_) => Text("A delete message."),
        onConfirmDelete: () => confirmed = true,
        editing: true,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text("DELETE"));
      await tester.pumpAndSettle();
      expect(find.text("A delete message."), findsNothing);
      expect(confirmed, isTrue);
    });

    testWidgets("Custom onTapDeleteButton", (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(Testable((_) => ManageableListItem(
        child: Text("Child"),
        onTapDeleteButton: () => tapped = true,
        editing: true,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      expect(tapped, isTrue);
    });

    testWidgets("Custom trailing widget doesn't show while editing",
        (WidgetTester tester) async
    {
      await tester.pumpWidget(Testable((_) => ManageableListItem(
        child: Text("Child"),
        onTapDeleteButton: () {},
        editing: true,
        trailing: Icon(Icons.style),
      )));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.style), findsNothing);
    });

    testWidgets("Custom trailing widget shows when not editing",
        (WidgetTester tester) async
    {
      await tester.pumpWidget(Testable((_) => ManageableListItem(
        child: Text("Child"),
        onTapDeleteButton: () {},
        trailing: Icon(Icons.style),
      )));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.style), findsOneWidget);
    });

    testWidgets("Extra padding after delete button when editing",
        (WidgetTester tester) async
    {
      await tester.pumpWidget(Testable((_) => ManageableListItem(
        child: Text("Child"),
        onTapDeleteButton: () {},
        editing: true,
      )));
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is Padding
          && widget.padding.horizontal
              == paddingDefaultDouble + paddingDefault), findsOneWidget);
    });
  });
}