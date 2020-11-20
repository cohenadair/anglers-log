import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/search_page.dart';
import 'package:mockito/mockito.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Close button pops page", (tester) async {
    var observer = MockNavigatorObserver();
    var popped = false;
    when(observer.didPop(any, any)).thenAnswer((_) => popped = true);

    await tester.pumpWidget(Testable(
      (_) => SearchPage(
        suggestionsBuilder: (_) => Text("Suggestions"),
        resultsBuilder: (_, __) => Text("Results"),
      ),
      navigatorObserver: observer,
    ));

    await tapAndSettle(tester, find.byIcon(Icons.close));
    expect(popped, isTrue);
  });

  testWidgets("Clear button when text is not empty",
      (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => SearchPage(
          suggestionsBuilder: (_) => Text("Suggestions"),
          resultsBuilder: (_, __) => Text("Results"),
        ),
      ),
    );

    await enterTextAndSettle(tester, find.byType(TextField), "Search text");
    expect(find.text("CLEAR"), findsOneWidget);
  });

  testWidgets("Close button clears text", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => SearchPage(
          suggestionsBuilder: (_) => Text("Suggestions"),
          resultsBuilder: (_, __) => Text("Results"),
        ),
      ),
    );

    await enterTextAndSettle(tester, find.byType(TextField), "Search text");
    await tapAndSettle(tester, find.text("CLEAR"));
    expect(find.text("Search text"), findsNothing);
  });

  testWidgets("Input text updates state", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => SearchPage(
          suggestionsBuilder: (_) => Text("Suggestions"),
          resultsBuilder: (_, __) => Text("Results"),
        ),
      ),
    );

    expect(find.text("Suggestions"), findsOneWidget);

    await tester.enterText(find.byType(TextField), "Search text");
    // Wait for SearchTimer to fire.
    await tester.pumpAndSettle(Duration(milliseconds: 750));
    expect(find.text("Suggestions"), findsNothing);
    expect(find.text("Results"), findsOneWidget);

    await tester.tap(find.text("CLEAR"));
    // Wait for SearchTimer to fire.
    await tester.pumpAndSettle(Duration(milliseconds: 750));
    expect(find.text("Suggestions"), findsOneWidget);
    expect(find.text("Results"), findsNothing);
  });
}
