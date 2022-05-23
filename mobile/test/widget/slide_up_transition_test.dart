import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/slide_up_transition.dart';

import '../test_utils.dart';

void main() {
  testWidgets("onDismissed callback invoked", (tester) async {
    var invoked = false;
    await tester.pumpWidget(Testable((_) => _TestSlide(() => invoked = true)));
    // Wait for initial animation.
    await tester.pumpAndSettle();

    // Dismiss.
    await tapAndSettle(tester, find.text("BUTTON"));
    await tester.pumpAndSettle();

    expect(invoked, isTrue);
    expect(find.text("Test"), findsNothing);
  });
}

class _TestSlide extends StatefulWidget {
  final VoidCallback? onDismissed;

  const _TestSlide(this.onDismissed);

  @override
  __TestSlideState createState() => __TestSlideState();
}

class __TestSlideState extends State<_TestSlide> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Button(
          text: "Button",
          onPressed: () => setState(() => _isVisible = false),
        ),
        SlideUpTransition(
          isVisible: _isVisible,
          onDismissed: widget.onDismissed,
          child: const Text("Text"),
        ),
      ],
    );
  }
}
