import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/empty_list_placeholder.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

void main() {
  testWidgets("No search results", (tester) async {
    await tester.pumpWidget(Testable(EmptyListPlaceholder.noSearchResults));

    expect(find.text("No results found"), findsOneWidget);
    expect(
      find.text(
          "Please adjust your search filter to find what you're looking for."),
      findsOneWidget,
    );
    expect(findFirst<WatermarkLogo>(tester).icon, Icons.search_off);
  });

  testWidgets("Custom input", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => const EmptyListPlaceholder(
          title: "Test title",
          description: "Test description",
          icon: Icons.group,
          scrollable: false,
          padding: insetsZero,
        ),
      ),
    );

    expect(find.text("Test title"), findsOneWidget);
    expect(find.text("Test description"), findsOneWidget);
    expect(findFirst<WatermarkLogo>(tester).icon, Icons.group);
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets("Custom input scrollable", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => const EmptyListPlaceholder(
          title: "Test title",
          description: "Test description",
          icon: Icons.group,
          scrollable: true,
          padding: insetsZero,
        ),
      ),
    );

    expect(find.text("Test title"), findsOneWidget);
    expect(find.text("Test description"), findsOneWidget);
    expect(findFirst<WatermarkLogo>(tester).icon, Icons.group);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
