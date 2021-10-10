import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/detail_input.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Right chevron added", (tester) async {
    await tester.pumpWidget(Testable((_) => const DetailInput()));
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets("Custom padding", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const DetailInput(
        padding: EdgeInsets.all(5),
      ),
    ));
    expect(
      (tester.widgetList<Padding>(find.byType(Padding)).first).padding,
      const EdgeInsets.all(5),
    );
  });

  testWidgets("Default padding", (tester) async {
    await tester.pumpWidget(Testable((_) => const DetailInput()));
    expect(
      (tester.widgetList<Padding>(find.byType(Padding)).first).padding,
      insetsDefault,
    );
  });

  testWidgets("Disabled doesn't invoke onTap", (tester) async {
    var invoked = false;
    await tester.pumpWidget(
      Testable(
        (_) => DetailInput(
          isEnabled: false,
          onTap: () => invoked = true,
        ),
      ),
    );

    await tapAndSettle(tester, find.byType(DetailInput));
    expect(invoked, isFalse);
  });

  testWidgets("Enabled invokes onTap", (tester) async {
    var invoked = false;
    await tester.pumpWidget(
      Testable(
        (_) => DetailInput(
          isEnabled: true,
          onTap: () => invoked = true,
        ),
      ),
    );

    await tapAndSettle(tester, find.byType(DetailInput));
    expect(invoked, isTrue);
  });
}
