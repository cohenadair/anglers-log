import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/floating_bottom_container.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

main() {
  testWidgets("Default margins", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => FloatingBottomContainer(
      title: "Test",
    )));
    expect(findFirst<Container>(tester).margin, insetsDefault);
  });

  testWidgets("Custom margins", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => FloatingBottomContainer(
      title: "Test",
      margin: EdgeInsets.all(37),
    )));
    expect(findFirst<Container>(tester).margin, EdgeInsets.all(37));
  });

  testWidgets("Tap enabled", (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(Testable((_) => FloatingBottomContainer(
      title: "Test",
      onTap: () => tapped = true,
    )));
    await tester.tap(find.text("Test"));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
    expect(find.byType(RightChevronIcon), findsOneWidget);
    expect(findFirst<ListItem>(tester).contentPadding.right, paddingSmall);
  });

  testWidgets("Tap disabled", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => FloatingBottomContainer(
      title: "Test",
    )));
    expect(find.byType(RightChevronIcon), findsNothing);
    expect(findFirst<ListItem>(tester).contentPadding.right, paddingDefault);
  });

  testWidgets("Empty title shows subtitle", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => FloatingBottomContainer(
      subtitle: "Subtitle",
    )));
    expect(find.byType(SubtitleLabel), findsNothing);
    expect(find.text("Subtitle"), findsOneWidget);
  });

  testWidgets("Title and subtitle", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => FloatingBottomContainer(
      title: "Title",
      subtitle: "Subtitle",
    )));
    expect(find.byType(Label), findsNWidgets(2)); // Title and Subtitle
    expect(find.text("Title"), findsOneWidget);
    expect(find.byType(SubtitleLabel), findsOneWidget);
    expect(find.text("Subtitle"), findsOneWidget);
  });

  testWidgets("Title/subtitle cannot both be empty", (WidgetTester tester)
      async
  {
    await tester.pumpWidget(Testable((_) => FloatingBottomContainer()));
    expect(tester.takeException(), isAssertionError);
  });

  testWidgets("Children are added", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => FloatingBottomContainer(
      title: "Title",
      subtitle: "Subtitle",
      children: [
        Text("Child 1"),
        Text("Child 2"),
        Text("Child 3"),
      ],
    )));
    expect(find.text("Child 1"), findsOneWidget);
    expect(find.text("Child 2"), findsOneWidget);
    expect(find.text("Child 3"), findsOneWidget);
  });
}