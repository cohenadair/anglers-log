import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/widget.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

  group("HeadingDivider", () {
    testWidgets("Divider shown", (tester) async {
      await tester.pumpWidget(Testable((_) => const HeadingDivider("Test")));
      expect(find.byType(MinDivider), findsOneWidget);
    });

    testWidgets("Divider hidden", (tester) async {
      await tester.pumpWidget(
        Testable((_) => const HeadingDivider("Test", showDivider: false)),
      );
      expect(find.byType(MinDivider), findsNothing);
    });

    testWidgets("Custom trailing", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const HeadingDivider("Test", trailing: Icon(Icons.add)),
        ),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets("No trailing", (tester) async {
      await tester.pumpWidget(
        Testable((_) => const HeadingDivider("Test", showDivider: true)),
      );
      expect(find.byType(SizedBox), findsNWidgets(2));
    });
  });

  group("HeadingNoteDivider", () {
    testWidgets("Input", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => HeadingNoteDivider(
            title: "Title",
            hideNote: false,
            noteIcon: null,
            note: null,
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);

      await tester.pumpWidget(
        Testable(
          (_) => HeadingNoteDivider(
            title: "Title",
            hideNote: false,
            noteIcon: null,
            note: "A note",
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);

      await tester.pumpWidget(
        Testable(
          (_) => HeadingNoteDivider(
            title: "Title",
            hideNote: false,
            noteIcon: Icons.group,
            note: null,
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets("Visible note", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => HeadingNoteDivider(
            title: "Title",
            hideNote: false,
            noteIcon: Icons.group,
            note: "A note %s",
          ),
        ),
      );
      var switcher = findFirst<AnimatedSwitcher>(tester);
      expect(switcher.child is Padding, isTrue);
    });

    testWidgets("Hidden note", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => HeadingNoteDivider(
            title: "Title",
            hideNote: true,
            noteIcon: Icons.group,
            note: "A note %s",
          ),
        ),
      );
      var switcher = findFirst<AnimatedSwitcher>(tester);
      expect(switcher.child is SizedBox, isTrue);
    });
  });

  group("EmptyFutureBuilder", () {
    testWidgets("Empty widget shown until finished", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => EmptyFutureBuilder<bool>(
            future: Future.delayed(
              const Duration(milliseconds: 100),
              () => true,
            ),
            builder: (context, value) => Text(value! ? "True" : "False"),
          ),
        ),
      );
      expect(find.byType(SizedBox), findsOneWidget);
      await tester.pumpAndSettle(const Duration(milliseconds: 150));
      expect(find.text("True"), findsOneWidget);
    });
  });

  group("ChipWrap", () {
    testWidgets("Empty input", (tester) async {
      await tester.pumpWidget(Testable((_) => const ChipWrap()));
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets("All chips rendered", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const ChipWrap({"Chip 1", "Chip 2", "Chip 3", "Chip 4"}),
        ),
      );
      expect(find.byType(SizedBox), findsNothing);
      expect(find.byType(Chip), findsNWidgets(4));
    });
  });

  group("CatchFavoriteStar", () {
    testWidgets("Empty if Catch isFavorite isn't set", (tester) async {
      await tester.pumpWidget(
        Testable((_) => CatchFavoriteStar(Catch()..id = randomId())),
      );

      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets("Empty if Catch isFavorite is false", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => CatchFavoriteStar(
            Catch()
              ..id = randomId()
              ..isFavorite = false,
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets("Star icon if Catch isFavorite is true", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => CatchFavoriteStar(
            Catch()
              ..id = randomId()
              ..isFavorite = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets("Large star icon if Catch isFavorite is true", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => CatchFavoriteStar(
            Catch()
              ..id = randomId()
              ..isFavorite = true,
            large: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(findFirst<Icon>(tester).size, 40.0);
    });
  });

  group("NoneFormHeader", () {
    testWidgets("Controller is cleared on tap", (tester) async {
      var controller = InputController<int>(value: 5);
      await tester.pumpWidget(
        Testable((_) => NoneFormHeader(controller: controller)),
      );

      expect(controller.hasValue, isTrue);

      await tapAndSettle(tester, find.text("None"));
      expect(controller.hasValue, isFalse);
    });
  });
}
