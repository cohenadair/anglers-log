import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

void main() {
  group("ListItem", () {
    testWidgets("Text title/subtitle use default style", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => ListItem(
          title: Text("Title"),
          subtitle: Text("Subtitle"),
        ),
      ));

      expect(find.byType(DefaultTextStyle), findsNWidgets(4));
    });

    testWidgets("Leading icons use default style", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => ListItem(
          leading: Icon(Icons.check),
        ),
      ));

      expect(find.byType(IconTheme), findsNWidgets(3));
    });

    testWidgets("Default padding", (tester) async {
      await tester.pumpWidget(Testable((_) => ListItem()));
      expect(
        find.byWidgetPredicate(
            (widget) => widget is Padding && widget.padding == insetsDefault),
        findsOneWidget,
      );
    });

    testWidgets("Custom padding", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => ListItem(
          padding: EdgeInsets.all(1),
        ),
      ));

      expect(
        find.byWidgetPredicate((widget) =>
            widget is Padding && widget.padding == EdgeInsets.all(1)),
        findsOneWidget,
      );
    });

    testWidgets("Null leading/trailing/title/subtitle", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => ListItem(
          title: null,
          subtitle: null,
          trailing: null,
          leading: null,
        ),
      ));

      expect(find.byType(HorizontalSpace), findsNothing);
      expect(find.byType(Empty), findsNWidgets(6));
    });

    testWidgets("Non-null leading/trailing/title/subtitle", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => ListItem(
          title: Text("Title"),
          subtitle: Text("Subtitle"),
          trailing: Icon(Icons.chevron_right),
          leading: Icon(Icons.check),
        ),
      ));

      expect(find.byType(HorizontalSpace), findsNWidgets(2));
      expect(find.byType(Empty), findsNothing);
      expect(find.text("Title"), findsOneWidget);
      expect(find.text("Subtitle"), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group("ExpansionListItem", () {
    testWidgets("Expanded on tap", (tester) async {
      var changed = false;
      await tester.pumpWidget(
        Testable(
          (_) => ExpansionListItem(
            title: Text("Title"),
            children: [
              Text("Child 1"),
              Text("Child 2"),
            ],
            onExpansionChanged: (_) => changed = true,
          ),
        ),
      );

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
    testWidgets("Editing shows edit/delete buttons", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListItem(
            child: Text("Child"),
            editing: true,
            onTapDeleteButton: () => false,
          ),
        ),
      );
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.text("EDIT"), findsOneWidget);
    });

    testWidgets("Custom text widget doesn't use default style", (tester) async {
      var context = await pumpContext(
        tester,
        (_) => ManageableListItem(
          child: MinDivider(),
          onTapDeleteButton: () => false,
        ),
      );

      expect(find.byType(MinDivider), findsOneWidget);
      expect(find.primaryText(context), findsNothing);
    });

    testWidgets("Tapping delete button shows dialog", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListItem(
            child: Text("Child"),
            deleteMessageBuilder: (_) => Text("A delete message."),
            onConfirmDelete: () {},
            editing: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      expect(find.text("A delete message."), findsOneWidget);
    });

    testWidgets("onConfirmDelete invoked", (tester) async {
      var confirmed = false;
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListItem(
            child: Text("Child"),
            deleteMessageBuilder: (_) => Text("A delete message."),
            onConfirmDelete: () => confirmed = true,
            editing: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text("DELETE"));
      await tester.pumpAndSettle();
      expect(find.text("A delete message."), findsNothing);
      expect(confirmed, isTrue);
    });

    testWidgets("Custom onTapDeleteButton", (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListItem(
            child: Text("Child"),
            onTapDeleteButton: () => tapped = true,
            editing: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      expect(tapped, isTrue);
    });

    testWidgets("Custom trailing widget doesn't show while editing",
        (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListItem(
            child: Text("Child"),
            onTapDeleteButton: () => false,
            editing: true,
            trailing: Icon(Icons.style),
          ),
        ),
      );
      await tester.pumpAndSettle();

      var box = tester.renderObject(find.ancestor(
          of: find.byIcon(Icons.style),
          matching: find.byType(AnimatedCrossFade))) as RenderBox;

      // Width of "Child" text + padding.
      expect(box.size.width, 72);
    });

    testWidgets("Custom trailing widget shows when not editing",
        (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListItem(
            child: Text("Child"),
            onTapDeleteButton: () => false,
            trailing: Icon(Icons.style),
          ),
        ),
      );
      await tester.pumpAndSettle();

      var box = tester.renderObject(find.ancestor(
          of: find.byIcon(Icons.style),
          matching: find.byType(AnimatedCrossFade))) as RenderBox;

      // Width of icon + padding.
      expect(box.size.width, 24 + paddingDefault);
    });
  });

  group("ManageableListImageItem", () {
    testWidgets("Padding added to trailing widget", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListImageItem(
            title: "Title",
            subtitle: "Subtitle",
            subtitle2: "Subtitle 2",
            trailing: RightChevronIcon(),
          ),
        ),
      );
      // One for image, one for trailing.
      expect(find.byType(Padding), findsNWidgets(2));
    });

    testWidgets("No trailing widget", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListImageItem(
            title: "Title",
            subtitle: "Subtitle",
            subtitle2: "Subtitle 2",
          ),
        ),
      );
      // One for image.
      expect(find.byType(Padding), findsOneWidget);
    });

    testWidgets("Empty subtitle3", (tester) async {
      var context = await pumpContext(
        tester,
        (_) => ManageableListImageItem(
          title: "Title",
          subtitle: "Subtitle",
          subtitle2: "Subtitle 2",
        ),
      );
      expect(find.subtitleText(context, text: null), findsNWidgets(2));
    });

    testWidgets("Non-empty subtitle3", (tester) async {
      var context = await pumpContext(
        tester,
        (_) => ManageableListImageItem(
          title: "Title",
          subtitle: "Subtitle",
          subtitle2: "Subtitle 2",
          subtitle3: "Subtitle 3",
        ),
      );
      expect(find.subtitleText(context, text: null), findsNWidgets(3));
    });
  });

  group("PickerListItem", () {
    testWidgets("Non-null subtitle", (tester) async {
      var context = await pumpContext(
        tester,
        (_) => PickerListItem(
          title: "Test",
          subtitle: "Subtitle",
        ),
      );

      expect(find.subtitleText(context), findsOneWidget);
    });

    testWidgets("Null subtitle", (tester) async {
      var context = await pumpContext(
        tester,
        (_) => PickerListItem(
          title: "Test",
        ),
      );
      expect(find.subtitleText(context), findsNothing);
    });

    testWidgets("Selected when multi", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => PickerListItem(
            title: "Test",
            isMulti: true,
            isSelected: true,
          ),
        ),
      );

      expect(find.byType(PaddedCheckbox), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets("Selected when single", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => PickerListItem(
            title: "Test",
            isSelected: true,
          ),
        ),
      );

      expect(find.byType(PaddedCheckbox), findsNothing);
      expect(find.byType(Icon), findsOneWidget);
    });
  });
}
