import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/icon_list.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Only first icon is visible", (tester) async {
    await tester.pumpWidget((Testable(
      (_) => const IconList(
        values: ["Item 1", "Item 2", "Item 3"],
        icon: Icons.add,
      ),
    )));

    var opacities = tester.widgetList<Opacity>(find.byType(Opacity)).toList();
    expect(opacities.length, 3);
    expect(opacities[0].opacity, 1.0);
    expect(opacities[1].opacity, 0.0);
    expect(opacities[2].opacity, 0.0);
  });

  testWidgets("All items are shown", (tester) async {
    await tester.pumpWidget((Testable(
      (_) => const IconList(
        values: ["Item 1", "Item 2", "Item 3"],
        icon: Icons.add,
      ),
    )));

    expect(find.text("Item 1"), findsOneWidget);
    expect(find.text("Item 2"), findsOneWidget);
    expect(find.text("Item 3"), findsOneWidget);
  });
}
