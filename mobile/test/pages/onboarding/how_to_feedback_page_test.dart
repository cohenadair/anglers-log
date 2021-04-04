import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/how_to_feedback_page.dart';
import 'package:mobile/widgets/list_item.dart';

import '../../test_utils.dart';

void main() {
  testWidgets("Feedback and rate scrolling", (tester) async {
    await tester.pumpWidget(Testable((_) => HowToFeedbackPage()));

    var scrollable = Scrollable.of((tester
            .firstWidget(find.widgetWithText(ListItem, "Send Feedback"))
            .key as GlobalKey)
        .currentContext!)!;
    expect(scrollable.widget.controller!.offset, 0.0);

    // Wait for scroll animation. Duration is scroll delay + duration from
    // _HowToFeedbackPageState.
    await tester.pumpAndSettle(Duration(milliseconds: 1500));
    expect(scrollable.widget.controller!.offset, greaterThan(0.0));

    // Wait to jump back to top.
    await tester.pumpAndSettle(Duration(milliseconds: 2500));
    expect(scrollable.widget.controller!.offset, 0.0);

    // And scroll again.
    await tester.pumpAndSettle(Duration(milliseconds: 1500));
    expect(scrollable.widget.controller!.offset, greaterThan(0.0));
  });
}
