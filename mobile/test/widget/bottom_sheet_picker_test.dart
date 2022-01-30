import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/bottom_sheet_picker.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

void main() {
  Visibility? visibility(String text, tester) {
    return tester.firstWidget(find.descendant(
      of: find.widgetWithText(ListItem, text),
      matching: find.byType(Visibility),
    ));
  }

  testWidgets("Current item has icon", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => const BottomSheetPicker<String>(
          currentValue: "Value 1",
          items: {
            "Option 1": "Value 1",
            "Option 2": "Value 2",
            "Option 3": "Value 3",
          },
        ),
      ),
    );

    expect(visibility("Option 1", tester)!.visible, isTrue);
    expect(visibility("Option 2", tester)!.visible, isFalse);
    expect(visibility("Option 3", tester)!.visible, isFalse);
  });

  testWidgets("No current item does not have icon", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => const BottomSheetPicker<String>(
          items: {
            "Option 1": "Value 1",
            "Option 2": "Value 2",
            "Option 3": "Value 3",
          },
        ),
      ),
    );

    expect(visibility("Option 1", tester)!.visible, isFalse);
    expect(visibility("Option 2", tester)!.visible, isFalse);
    expect(visibility("Option 3", tester)!.visible, isFalse);
  });

  testWidgets("onPicked callback invoked and dismissed", (tester) async {
    String? pickedValue;
    await tester.pumpWidget(
      Testable(
        (_) => BottomSheetPicker<String>(
          items: const {
            "Option 1": "Value 1",
            "Option 2": "Value 2",
            "Option 3": "Value 3",
          },
          onPicked: (picked) => pickedValue = picked,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Option 2"));
    expect(pickedValue, "Value 2");
    expect(find.byType(BottomSheetPicker), findsNothing);
  });

  testWidgets("All items rendered", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => const BottomSheetPicker<String>(
          currentValue: "Value 1",
          items: {
            "Option 1": "Value 1",
            "Option 2": "Value 2",
            "Option 3": "Value 3",
          },
        ),
      ),
    );

    expect(find.text("Option 1"), findsOneWidget);
    expect(find.text("Option 2"), findsOneWidget);
    expect(find.text("Option 3"), findsOneWidget);
  });

  testWidgets("Footer is shown", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => const BottomSheetPicker<String>(
          footer: Text("Footer"),
        ),
      ),
    );
    expect(find.text("Footer"), findsOneWidget);
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("Footer is hidden", (tester) async {
    await tester.pumpWidget(Testable((_) => const BottomSheetPicker<String>()));
    expect(find.byType(Text), findsNothing);
    expect(find.byType(Empty), findsNWidgets(2));
  });

  testWidgets("Item has custom style", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => const BottomSheetPicker<String>(
          currentValue: "Value 1",
          items: {
            "Option 1": "Value 1",
            "Option 2": "Value 2",
            "Option 3": "Value 3",
          },
          itemStyle: styleHeading,
        ),
      ),
    );

    expect(find.headingText(text: "Option 1"), findsOneWidget);
    expect(find.headingText(text: "Option 2"), findsOneWidget);
    expect(find.headingText(text: "Option 3"), findsOneWidget);
  });
}
