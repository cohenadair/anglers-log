import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/bullet_list.dart';

import '../test_utils.dart';

void main() {
  testWidgets("All items are shown", (tester) async {
    await pumpContext(
      tester,
      (_) => const BulletList(
        items: {
          "Item 1",
          "Item 2",
          "Item 3",
        },
      ),
    );

    expect(find.text("Item 1"), findsOneWidget);
    expect(find.text("Item 2"), findsOneWidget);
    expect(find.text("Item 3"), findsOneWidget);

    expect(
      findFirstWithText<Padding>(tester, "Item 1").padding,
      insetsBottomSmall,
    );
    expect(
      findFirstWithText<Padding>(tester, "Item 2").padding,
      insetsBottomSmall,
    );
    expect(
      findFirstWithText<Padding>(tester, "Item 3").padding,
      insetsZero,
    );
  });
}
