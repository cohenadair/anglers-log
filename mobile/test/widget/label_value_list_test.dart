import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/label_value_list.dart';
import 'package:mobile/widgets/widget.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

  testWidgets("Empty items shows empty widget", (tester) async {
    await pumpContext(tester, (_) => const LabelValueList(items: []));
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("Empty title widget", (tester) async {
    await pumpContext(
      tester,
      (_) => LabelValueList(items: [LabelValueListItem("Label", "Value")]),
    );
    expect(find.byType(HeadingDivider), findsNothing);
  });

  testWidgets("Non-empty title widget", (tester) async {
    await pumpContext(
      tester,
      (_) => LabelValueList(
        title: "Title",
        items: [LabelValueListItem("Label", "Value")],
      ),
    );
    expect(find.byType(HeadingDivider), findsOneWidget);
  });

  testWidgets("Custom padding", (tester) async {
    await pumpContext(
      tester,
      (_) => LabelValueList(
        padding: const EdgeInsets.all(3),
        items: [LabelValueListItem("Label", "Value")],
      ),
    );
    expect(findFirst<Padding>(tester).padding, const EdgeInsets.all(3));
  });

  testWidgets("Default padding", (tester) async {
    await pumpContext(
      tester,
      (_) => LabelValueList(items: [LabelValueListItem("Label", "Value")]),
    );
    expect(findFirst<Padding>(tester).padding, insetsZero);
  });
}
