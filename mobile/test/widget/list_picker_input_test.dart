import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

main() {
  testWidgets("Title/value can't both be empty", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => ListPickerInput()));
    expect(tester.takeException(), isAssertionError);
  });

  testWidgets("If title is empty, value is used as title", (WidgetTester tester)
      async
  {
    await tester.pumpWidget(Testable((_) => ListPickerInput(
      value: "Value",
    )));
    expect(find.widgetWithText(Label, "Value"), findsOneWidget);
    expect(find.byType(SecondaryLabel), findsNothing);
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("Enabled", (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(Testable((_) => ListPickerInput(
      value: "Value",
      onTap: () => tapped = true,
    )));
    expect(findFirst<ListItem>(tester).contentPadding, isNull);

    await tester.tap(find.byType(ListItem));
    expect(tapped, isTrue);
  });

  testWidgets("Disabled", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => ListPickerInput(
      value: "Value",
      enabled: false,
    )));
    expect(findFirst<ListItem>(tester).contentPadding, isNotNull);
  });

  testWidgets("Empty value renders not selected message", (WidgetTester tester)
      async
  {
    await tester.pumpWidget(Testable((_) => ListPickerInput(
      title: "Title",
    )));
    expect(find.byType(SecondaryLabel), findsOneWidget);
    expect(find.text("Not Selected"), findsOneWidget);
  });
}