import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/detail_input.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Right chevron added", (tester) async {
    await tester.pumpWidget(Testable((_) => DetailInput()));
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets("Custom padding", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => DetailInput(
        padding: EdgeInsets.all(5),
      ),
    ));
    expect(
      (tester.widgetList<Padding>(find.byType(Padding)).first).padding,
      EdgeInsets.all(5),
    );
  });

  testWidgets("Default padding", (tester) async {
    await tester.pumpWidget(Testable((_) => DetailInput()));
    expect(
      (tester.widgetList<Padding>(find.byType(Padding)).first).padding,
      insetsDefault,
    );
  });
}
