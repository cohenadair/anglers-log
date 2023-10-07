import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/floating_container.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

void main() {
  group("Button", () {
    testWidgets("No icon", (tester) async {
      var pressed = false;
      var button = Button(
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

    testWidgets("Icon", (tester) async {
      var button = Button(
        text: "Test",
        onPressed: () => {},
        icon: const Icon(Icons.group),
      );

      await tester.pumpWidget(Testable((_) => button));
      expect(find.byIcon(Icons.group), findsOneWidget);
    });
  });

  group("ActionButton", () {
    testWidgets("Constructors", (tester) async {
      await tester.pumpWidget(Testable((_) => const ActionButton.done()));
      expect(find.text("DONE"), findsOneWidget);

      await tester.pumpWidget(Testable((_) => const ActionButton.save()));
      expect(find.text("SAVE"), findsOneWidget);

      await tester.pumpWidget(Testable((_) => const ActionButton.cancel()));
      expect(find.text("CANCEL"), findsOneWidget);

      await tester.pumpWidget(Testable((_) => const ActionButton.edit()));
      expect(find.text("EDIT"), findsOneWidget);

      await tester.pumpWidget(
        Testable(
          (_) => const ActionButton(
            text: "Test",
          ),
        ),
      );
      expect(find.text("TEST"), findsOneWidget);
    });

    testWidgets("Text is always uppercase", (tester) async {
      await tester.pumpWidget(Testable((_) => const ActionButton.done()));
      expect(find.text("DONE"), findsOneWidget);
      expect(find.text("Done"), findsNothing);
    });

    testWidgets("Text color", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const ActionButton.done(
            textColor: Colors.red,
          ),
        ),
      );
      expect((tester.firstWidget(find.text("DONE")) as Text).style!.color,
          Colors.red);
    });

    testWidgets("Disabled", (tester) async {
      await tester.pumpWidget(Testable((_) => const ActionButton.done()));
      expect(findFirst<EnabledOpacity>(tester).isEnabled, isFalse);
    });

    testWidgets("Enabled", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ActionButton.done(
            onPressed: () => {},
          ),
        ),
      );
      expect(findFirst<EnabledOpacity>(tester).isEnabled, isTrue);
    });

    testWidgets("Condensed", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const ActionButton.done(
            condensed: true,
          ),
        ),
      );
      expect(findFirst<RawMaterialButton>(tester).padding, insetsSmall);
    });

    testWidgets("Not condensed", (tester) async {
      await tester.pumpWidget(Testable((_) => const ActionButton.done()));
      expect(findFirst<RawMaterialButton>(tester).padding, insetsDefault);
    });
  });

  group("ChipButton", () {
    testWidgets("Enabled", (tester) async {
      var pressed = false;
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

    testWidgets("Without icon", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ChipButton(
            label: "Test",
            onPressed: () => {},
          ),
        ),
      );
      var chip = findFirst<ActionChip>(tester);
      expect(chip.avatar, isNull);
    });

    testWidgets("With icon", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ChipButton(
            label: "Test",
            icon: Icons.add,
            onPressed: () => {},
          ),
        ),
      );
      var chip = findFirst<ActionChip>(tester);
      expect(chip.avatar, isNotNull);
    });
  });

  group("MinimumIconButton", () {
    testWidgets("Custom color when enabled", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => MinimumIconButton(
            icon: Icons.group,
            color: Colors.red,
            onTap: () {},
          ),
        ),
      );
      expect(findFirst<Icon>(tester).color, Colors.red);
    });

    testWidgets("Disabled color when disabled", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const MinimumIconButton(
            icon: Icons.group,
            color: Colors.red,
          ),
        ),
      );
      expect(findFirst<Icon>(tester).color != Colors.red, isTrue);
    });
  });

  group("FloatingButton", () {
    testWidgets("Not pushed color", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => FloatingButton.icon(
            icon: Icons.backpack,
            onPressed: () {},
          ),
        ),
      );
      expect(findFirst<RawMaterialButton>(tester).fillColor, isNull);
    });

    testWidgets("Pushed color", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => FloatingButton.icon(
            icon: Icons.backpack,
            onPressed: () {},
            pushed: true,
          ),
        ),
      );
      expect(findFirst<RawMaterialButton>(tester).fillColor, Colors.grey);
    });

    testWidgets("Default padding", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => FloatingButton.icon(
            icon: Icons.backpack,
            onPressed: () {},
          ),
        ),
      );
      expect(findFirst<Padding>(tester).padding, insetsDefault);
    });

    testWidgets("Custom padding", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => FloatingButton.icon(
            icon: Icons.backpack,
            onPressed: () {},
            padding: insetsSmall,
          ),
        ),
      );
      expect(findFirst<Padding>(tester).padding, insetsSmall);
    });

    testWidgets("With label", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => FloatingButton.icon(
            icon: Icons.backpack,
            onPressed: () {},
            label: "Backpack",
          ),
        ),
      );
      expect(find.text("Backpack"), findsOneWidget);
    });

    testWidgets("Without label", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => FloatingButton.icon(
            icon: Icons.backpack,
            onPressed: () {},
          ),
        ),
      );
      expect(find.byType(Text), findsNothing);
    });

    testWidgets("Android back button", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const FloatingButton.back(),
          platform: TargetPlatform.android,
        ),
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(
        findFirstWithIcon<RawMaterialButton>(tester, Icons.arrow_back)
            .onPressed,
        isNotNull,
      );
      expect(findFirst<Tooltip>(tester).message, "Back");
    });

    testWidgets("iOS back button", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const FloatingButton.back(),
          platform: TargetPlatform.iOS,
        ),
      );
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
      expect(
        findFirstWithIcon<RawMaterialButton>(tester, Icons.arrow_back_ios)
            .onPressed,
        isNotNull,
      );
      expect(findFirst<Tooltip>(tester).message, "Back");
    });

    testWidgets("Close button", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const FloatingButton.close(),
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(
        findFirstWithIcon<RawMaterialButton>(tester, Icons.close).onPressed,
        isNotNull,
      );
      expect(findFirst<Tooltip>(tester).message, "Close");
    });

    testWidgets("Text", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => FloatingButton(
            text: "Test",
            tooltip: "Tooltip",
          ),
        ),
      );
      expect(find.byType(Icon), findsNothing);
      expect(find.text("TEST"), findsOneWidget);
      expect(findFirst<Tooltip>(tester).message, "Tooltip");
    });

    testWidgets("Transparent background", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => FloatingButton(
            icon: Icons.delete,
            transparentBackground: true,
          ),
        ),
      );
      expect(findFirst<Container>(tester).decoration, isNull);
      expect(findFirst<RawMaterialButton>(tester).fillColor, isNull);
    });

    testWidgets("Custom size", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const FloatingButton.smallIcon(
            icon: Icons.delete,
          ),
        ),
      );
      expect(findFirst<FloatingContainer>(tester).width, 24.0);
      expect(findFirst<FloatingContainer>(tester).height, 24.0);
    });

    testWidgets("Icon x offset", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const FloatingButton.smallIcon(
            icon: Icons.delete,
            iconOffsetX: -5,
          ),
        ),
      );
      expect(
        find.byWidgetPredicate(
            (widget) => widget is Container && widget.transform != null),
        findsOneWidget,
      );
    });
  });
}
