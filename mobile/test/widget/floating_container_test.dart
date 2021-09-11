import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/floating_container.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Default margins", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FloatingContainer(
          title: "Test",
        ),
      ),
    );
    expect(findFirst<Container>(tester).margin, insetsDefault);
  });

  testWidgets("Custom margins", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FloatingContainer(
          title: "Test",
          margin: EdgeInsets.all(37),
        ),
      ),
    );
    expect(findFirst<Container>(tester).margin, EdgeInsets.all(37));
  });

  testWidgets("Tap enabled", (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      Testable(
        (_) => FloatingContainer(
          title: "Test",
          onTap: () => tapped = true,
        ),
      ),
    );
    await tester.tap(find.text("Test"));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
    expect(find.byType(RightChevronIcon), findsOneWidget);
    expect(findFirst<ImageListItem>(tester).trailing!, isNotNull);
  });

  testWidgets("Tap disabled", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FloatingContainer(
          title: "Test",
        ),
      ),
    );
    expect(find.byType(RightChevronIcon), findsNothing);
    expect(findFirst<ImageListItem>(tester).trailing, isNull);
  });

  testWidgets("Title/subtitle cannot both be empty", (tester) async {
    await tester.pumpWidget(Testable((_) => FloatingContainer()));
    expect(tester.takeException(), isAssertionError);
  });

  testWidgets("Children are added", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FloatingContainer(
          title: "Title",
          subtitle: "Subtitle",
          children: [
            Text("Child 1"),
            Text("Child 2"),
            Text("Child 3"),
          ],
        ),
      ),
    );
    expect(find.text("Child 1"), findsOneWidget);
    expect(find.text("Child 2"), findsOneWidget);
    expect(find.text("Child 3"), findsOneWidget);
  });
}
