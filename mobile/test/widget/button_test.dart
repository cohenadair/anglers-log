import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

main() {
  group("Button", () {
    testWidgets("No icon", (WidgetTester tester) async {
      bool pressed = false;
      Button button = Button(
        text: "Test",
        onPressed: () => pressed = true,
      );

      await tester.pumpWidget(Testable(
        (_) => button,
      ));

      expect(find.byWidget(button), findsOneWidget);
      await tester.tap(find.byWidget(button));
      expect(pressed, isTrue);
    });

    testWidgets("Icon", (WidgetTester tester) async {
      Button button = Button(
        text: "Test",
        onPressed: () => {},
        icon: Icon(Icons.group),
      );

      await tester.pumpWidget(Testable((_) => button));
      expect(find.byIcon(Icons.group), findsOneWidget);
    });
  });

  group("ActionButton", () {
    testWidgets("Constructors", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => ActionButton.done()));
      expect(find.text("DONE"), findsOneWidget);

      await tester.pumpWidget(Testable((_) => ActionButton.save()));
      expect(find.text("SAVE"), findsOneWidget);

      await tester.pumpWidget(Testable((_) => ActionButton.cancel()));
      expect(find.text("CANCEL"), findsOneWidget);

      await tester.pumpWidget(Testable((_) => ActionButton.edit()));
      expect(find.text("EDIT"), findsOneWidget);

      await tester.pumpWidget(
        Testable(
          (_) => ActionButton(
            text: "Test",
          ),
        ),
      );
      expect(find.text("TEST"), findsOneWidget);
    });

    testWidgets("Text is always uppercase", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => ActionButton.done()));
      expect(find.text("DONE"), findsOneWidget);
      expect(find.text("Done"), findsNothing);
    });

    testWidgets("Text color", (WidgetTester tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ActionButton.done(
            textColor: Colors.red,
          ),
        ),
      );
      expect((tester.firstWidget(find.text("DONE")) as Text).style.color,
          Colors.red);
    });

    testWidgets("Disabled", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => ActionButton.done()));
      expect(findFirst<EnabledOpacity>(tester).enabled, isFalse);
    });

    testWidgets("Enabled", (WidgetTester tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ActionButton.done(
            onPressed: () => {},
          ),
        ),
      );
      expect(findFirst<EnabledOpacity>(tester).enabled, isTrue);
    });

    testWidgets("Condensed", (WidgetTester tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ActionButton.done(
            condensed: true,
          ),
        ),
      );
      expect(findFirst<RawMaterialButton>(tester).padding, insetsSmall);
    });

    testWidgets("Not condensed", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => ActionButton.done()));
      expect(findFirst<RawMaterialButton>(tester).padding, insetsDefault);
    });
  });

  group("ChipButton", () {
    testWidgets("Enabled", (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        Testable(
          (_) => ChipButton(
            label: "Test",
            onPressed: () => pressed = true,
          ),
        ),
      );
      await tester.tap(find.byType(ChipButton));
      expect(pressed, isTrue);
    });
  });

  group("MinimumIconButton", () {
    testWidgets("Color", (WidgetTester tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => MinimumIconButton(
            icon: Icons.group,
            color: Colors.red,
          ),
        ),
      );
      expect(findFirst<Icon>(tester).color, Colors.red);
    });
  });

  group("FloatingIconButton", () {
    testWidgets("Not pushed color", (WidgetTester tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => FloatingIconButton(
            icon: Icons.backpack,
            onPressed: () {},
          ),
        ),
      );
      expect(findFirst<RawMaterialButton>(tester).fillColor, Colors.white);
    });

    testWidgets("Pushed color", (WidgetTester tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => FloatingIconButton(
            icon: Icons.backpack,
            onPressed: () {},
            pushed: true,
          ),
        ),
      );
      expect(findFirst<RawMaterialButton>(tester).fillColor, Colors.grey);
    });

    testWidgets("Default padding", (WidgetTester tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => FloatingIconButton(
            icon: Icons.backpack,
            onPressed: () {},
          ),
        ),
      );
      expect(findFirst<Padding>(tester).padding, insetsDefault);
    });

    testWidgets("Custom padding", (WidgetTester tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => FloatingIconButton(
            icon: Icons.backpack,
            onPressed: () {},
            padding: insetsSmall,
          ),
        ),
      );
      expect(findFirst<Padding>(tester).padding, insetsSmall);
    });

    testWidgets("With label", (WidgetTester tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => FloatingIconButton(
            icon: Icons.backpack,
            onPressed: () {},
            label: "Backpack",
          ),
        ),
      );
      expect(find.text("Backpack"), findsOneWidget);
    });

    testWidgets("Without label", (WidgetTester tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => FloatingIconButton(
            icon: Icons.backpack,
            onPressed: () {},
          ),
        ),
      );
      expect(find.byType(Text), findsNothing);
    });
  });
}
