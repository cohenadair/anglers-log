import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/our_bottom_sheet.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Title is shown", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => const OurBottomSheet(
          title: "Title",
        ),
      ),
    );
    expect(find.headingSmallText(text: "Title"), findsOneWidget);
  });

  testWidgets("Title is hidden", (tester) async {
    await tester.pumpWidget(Testable((_) => const OurBottomSheet()));
    expect(find.byType(Text), findsNothing);
  });
}
