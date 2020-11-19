import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/search_bar.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

main() {
  testWidgets("Custom leading widget", (WidgetTester tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => SearchBar(
          delegate: InputSearchBarDelegate((_) {}),
          leading: Text("LEAD"),
        ),
      ),
    );
    expect(find.text("LEAD"), findsOneWidget);
    expect(find.byIcon(Icons.search), findsNothing);
  });

  testWidgets("Default leading widget", (WidgetTester tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => SearchBar(
          delegate: InputSearchBarDelegate((_) {}),
        ),
      ),
    );
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets("Custom trailing widget", (WidgetTester tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => SearchBar(
          delegate: InputSearchBarDelegate((_) {}),
          trailing: Text("TRAIL"),
        ),
      ),
    );
    expect(find.text("TRAIL"), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets("Initial text is shown", (WidgetTester tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => SearchBar(
          delegate: InputSearchBarDelegate((_) {}),
          text: "A search term",
        ),
      ),
    );
    expect(find.text("A search term"), findsOneWidget);
  });

  group("As button", () {
    testWidgets("Default trailing widget for button",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => SearchBar(
            delegate: ButtonSearchBarDelegate(() {}),
          ),
        ),
      );
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byType(Empty), findsOneWidget);
    });

    testWidgets("Delegate onTap is invoked", (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        Testable(
          (_) => SearchBar(
            delegate: ButtonSearchBarDelegate(() => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(SearchBar));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  group("As input", () {
    testWidgets("Default trailing widget for input",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => SearchBar(
            delegate: InputSearchBarDelegate((_) {}),
          ),
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byType(Empty), findsNothing);
    });

    testWidgets("Delegate onTextChanged is invoked",
        (WidgetTester tester) async {
      int invokedCount = 0;
      await tester.pumpWidget(
        Testable(
          (_) => SearchBar(
            delegate: InputSearchBarDelegate((_) => invokedCount++),
          ),
        ),
      );

      await tester.enterText(find.byType(CupertinoTextField), "search");
      await tester.pumpAndSettle();
      expect(invokedCount, 1);
    });

    testWidgets("Clear invokes callback when text changes",
        (WidgetTester tester) async {
      int invokedCount = 0;
      await tester.pumpWidget(
        Testable(
          (_) => SearchBar(
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
        (WidgetTester tester) async {
      int invokedCount = 0;
      await tester.pumpWidget(
        Testable(
          (_) => SearchBar(
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
