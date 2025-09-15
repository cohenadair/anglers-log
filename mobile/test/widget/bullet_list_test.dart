import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/bullet_list.dart';
import 'package:mobile/widgets/text.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';

void main() {
  testWidgets("All items are shown", (tester) async {
    await pumpContext(
      tester,
      (_) => BulletList(
        items: {
          BulletListItem("Item 1"),
          BulletListItem("Item 2"),
          BulletListItem("Item 3"),
          BulletListItem("Item 4 %s", const Icon(Icons.add)),
        },
      ),
    );

    expect(find.text("Item 1"), findsOneWidget);
    expect(find.text("Item 2"), findsOneWidget);
    expect(find.text("Item 3"), findsOneWidget);
    expect(find.byType(IconLabel), findsOneWidget);

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
      insetsBottomSmall,
    );
    expect(findFirstWithIcon<Padding>(tester, Icons.add).padding, insetsZero);
  });
}
