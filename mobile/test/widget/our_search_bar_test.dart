import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/our_search_bar.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Custom leading widget", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => OurSearchBar(
          delegate: InputSearchBarDelegate((_) {}),
          leading: const Text("LEAD"),
        ),
      ),
    );
    expect(find.text("LEAD"), findsOneWidget);
    expect(find.byIcon(Icons.search), findsNothing);
  });

  testWidgets("Default leading widget", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => OurSearchBar(
          delegate: InputSearchBarDelegate((_) {}),
        ),
      ),
    );
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets("Custom trailing widget", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => OurSearchBar(
          delegate: InputSearchBarDelegate((_) {}),
          trailing: const Text("TRAIL"),
        ),
      ),
    );
    expect(find.text("TRAIL"), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets("Initial text is shown", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => OurSearchBar(
          delegate: InputSearchBarDelegate((_) {}),
          text: "A search term",
        ),
      ),
    );
    expect(find.text("A search term"), findsOneWidget);
  });

  group("As button", () {
    testWidgets("Default trailing widget for button", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => OurSearchBar(
            delegate: ButtonSearchBarDelegate(() {}),
          ),
        ),
      );
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byType(Empty), findsOneWidget);
    });

    testWidgets("Delegate onTap is invoked", (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        Testable(
          (_) => OurSearchBar(
            delegate: ButtonSearchBarDelegate(() => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(OurSearchBar));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  group("As input", () {
    testWidgets("Default trailing widget for input", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => OurSearchBar(
            delegate: InputSearchBarDelegate((_) {}),
          ),
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byType(Empty), findsNothing);
    });

    testWidgets("Delegate onTextChanged is invoked", (tester) async {
      var invokedCount = 0;
      await tester.pumpWidget(
        Testable(
          (_) => OurSearchBar(
            delegate: InputSearchBarDelegate((_) => invokedCount++),
          ),
        ),
      );

      await tester.enterText(find.byType(CupertinoTextField), "search");
      await tester.pumpAndSettle();
      expect(invokedCount, 1);
    });

    testWidgets("Clear invokes callback when text changes", (tester) async {
      var invokedCount = 0;
      await tester.pumpWidget(
        Testable(
          (_) => OurSearchBar(
            delegate: InputSearchBarDelegate((_) => invokedCount++),
          ),
        ),
      );

      await tester.enterText(find.byType(CupertinoTextField), "search");
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // One for enter text and one for clearing.
      expect(invokedCount, 2);
    });

    testWidgets("Clear does not invoke callback when text doesn't change",
        (tester) async {
      var invokedCount = 0;
      await tester.pumpWidget(
        Testable(
          (_) => OurSearchBar(
            delegate: InputSearchBarDelegate((_) => invokedCount++),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(invokedCount, 0);
    });
  });
}
