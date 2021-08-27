import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/scroll_page.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Centered content", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ScrollPage(
          centerContent: true,
          children: [
            Text("Test"),
          ],
        ),
      ),
    );

    expect(find.byType(Center), findsOneWidget);
  });

  testWidgets("Not centered content", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ScrollPage(
          children: [
            Text("Test"),
          ],
        ),
      ),
    );

    expect(find.byType(Center), findsNothing);
  });

  testWidgets("Includes refresh indicator", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ScrollPage(
          children: [
            Text("Test"),
          ],
          onRefresh: () => Future.value(),
        ),
      ),
    );

    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets("No refresh indicator", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ScrollPage(
          children: [
            Text("Test"),
          ],
        ),
      ),
    );

    expect(find.byType(RefreshIndicator), findsNothing);
  });

  testWidgets("Default clip behavior when showing footer", (tester) async {
    await pumpContext(
      tester,
      (_) => ScrollPage(
        children: [
          Text("Test"),
        ],
        footer: [
          TextButton(
            child: Text("Tap Me"),
            onPressed: () {},
          ),
        ],
      ),
    );
    expect(
      tester
          .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
          .clipBehavior,
      Clip.hardEdge,
    );
  });

  testWidgets("No clip behavior with empty footer", (tester) async {
    await pumpContext(
      tester,
      (_) => ScrollPage(
        children: [
          Text("Test"),
        ],
        footer: [],
      ),
    );
    expect(
      tester
          .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
          .clipBehavior,
      Clip.none,
    );
  });
}
