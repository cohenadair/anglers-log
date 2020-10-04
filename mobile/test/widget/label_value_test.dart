import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/label_value.dart';

import '../test_utils.dart';

main() {
  testWidgets("Neither label nor value can be null", (WidgetTester tester)
      async
  {
    await tester.pumpWidget(Testable((_) => LabelValue(
      label: null,
      value: null,
    )));
    expect(tester.takeException(), isAssertionError);

    await tester.pumpWidget(Testable((_) => LabelValue(
      label: "",
      value: "",
    )));
    expect(tester.takeException(), isAssertionError);

    await tester.pumpWidget(Testable((_) => LabelValue(
      label: "Test",
      value: null,
    )));
    expect(tester.takeException(), isAssertionError);

    await tester.pumpWidget(Testable((_) => LabelValue(
      label: null,
      value: "Value",
    )));
    expect(tester.takeException(), isAssertionError);

    await tester.pumpWidget(Testable((_) => LabelValue(
      label: "Test",
      value: "Value",
    )));
    expect(find.byType(LabelValue), findsOneWidget);
  });

  testWidgets("Long value renders column", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => LabelValue(
      label: "Test",
      value: "A really long value that shows in a column",
    )));
    expect(find.byType(Column), findsOneWidget);
    expect(find.byType(Row), findsNothing);
  });

  testWidgets("Short column renders row", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => LabelValue(
      label: "Test",
      value: "Value",
    )));
    expect(find.byType(Row), findsOneWidget);
    expect(find.byType(Column), findsNothing);
  });
}