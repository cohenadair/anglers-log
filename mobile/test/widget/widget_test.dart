import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

void main() {
  group("HeadingDivider", () {
    testWidgets("Divider shown", (tester) async {
      await tester.pumpWidget(Testable((_) => const HeadingDivider("Test")));
      expect(find.byType(MinDivider), findsOneWidget);
    });

    testWidgets("Divider hidden", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const HeadingDivider(
            "Test",
            showDivider: false,
          ),
        ),
      );
      expect(find.byType(MinDivider), findsNothing);
    });

    testWidgets("Custom trailing", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const HeadingDivider(
            "Test",
            trailing: Icon(Icons.add),
          ),
        ),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets("No trailing", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const HeadingDivider(
            "Test",
            showDivider: true,
          ),
        ),
      );
      expect(find.byType(Empty), findsOneWidget);
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
      expect(switcher.child is Empty, isTrue);
    });
  });

  group("EmptyFutureBuilder", () {
    testWidgets("Empty widget shown until finished", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => EmptyFutureBuilder<bool>(
            future:
                Future.delayed(const Duration(milliseconds: 100), () => true),
            builder: (context, value) => Text(value! ? "True" : "False"),
          ),
        ),
      );
      expect(find.byType(Empty), findsOneWidget);
      await tester.pumpAndSettle(const Duration(milliseconds: 150));
      expect(find.text("True"), findsOneWidget);
    });
  });

  group("ChipWrap", () {
    testWidgets("Empty input", (tester) async {
      await tester.pumpWidget(Testable((_) => const ChipWrap()));
      expect(find.byType(Empty), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets("All chips rendered", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const ChipWrap({
            "Chip 1",
            "Chip 2",
            "Chip 3",
            "Chip 4",
          }),
        ),
      );
      expect(find.byType(Empty), findsNothing);
      expect(find.byType(Chip), findsNWidgets(4));
    });
  });

  group("Loading", () {
    testWidgets("Centered includes a centered column", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const Loading(
            isCentered: true,
            label: "Test...",
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(findFirst<Column>(tester).mainAxisAlignment,
          MainAxisAlignment.center);
    });

    testWidgets("Label not centered includes start aligned column",
        (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const Loading(
            isCentered: false,
            label: "Test...",
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(
          findFirst<Column>(tester).mainAxisAlignment, MainAxisAlignment.start);
    });

    testWidgets("Not centered; no label just shows indicator", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => const Loading(
            isCentered: false,
          ),
        ),
      );

      expect(find.byType(Column), findsNothing);
    });

    testWidgets("App bar uses custom color", (tester) async {
      await pumpContext(tester, (_) => const Loading.appBar());
      expect(findFirst<CircularProgressIndicator>(tester).color, isNotNull);
    });

    testWidgets("Default has null color", (tester) async {
      await pumpContext(tester, (_) => const Loading(isAppBar: false));
      expect(findFirst<CircularProgressIndicator>(tester).color, isNull);
    });
  });

  group("CatchFavoriteStar", () {
    testWidgets("Empty if Catch isFavorite isn't set", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => CatchFavoriteStar(
            Catch()..id = randomId(),
          ),
        ),
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
      await tester
          .pumpWidget(Testable((_) => NoneFormHeader(controller: controller)));

      expect(controller.hasValue, isTrue);

      await tapAndSettle(tester, find.text("None"));
      expect(controller.hasValue, isFalse);
    });
  });

  testWidgets("WatermarkLogo with title", (tester) async {
    await pumpContext(
      tester,
      (_) => const WatermarkLogo(
        icon: Icons.add,
        title: "Title",
      ),
    );
    expect(find.byType(TitleLabel), findsOneWidget);
  });

  testWidgets("WatermarkLogo without title", (tester) async {
    await pumpContext(
      tester,
      (_) => const WatermarkLogo(
        icon: Icons.add,
      ),
    );
    expect(find.byType(TitleLabel), findsNothing);
  });

  testWidgets("EmptyOr shows child", (tester) async {
    await pumpContext(
      tester,
      (_) => EmptyOr(
        isShowing: true,
        childBuilder: (_) => const Text("Test"),
      ),
    );
    expect(find.text("Test"), findsOneWidget);
  });

  testWidgets("EmptyOr hides child", (tester) async {
    await pumpContext(
      tester,
      (_) => EmptyOr(
        isShowing: false,
        childBuilder: (_) => const Text("Test"),
      ),
    );
    expect(find.text("Test"), findsNothing);
  });

  testWidgets("EmptyOr default padding", (tester) async {
    await pumpContext(
      tester,
      (_) => EmptyOr(
        childBuilder: (_) => const Text("Test"),
      ),
    );
    expect(findFirst<Padding>(tester).padding, insetsZero);
  });

  testWidgets("EmptyOr custom padding", (tester) async {
    await pumpContext(
      tester,
      (_) => EmptyOr(
        padding: insetsDefault,
        childBuilder: (_) => const Text("Test"),
      ),
    );
    expect(findFirst<Padding>(tester).padding, insetsDefault);
  });
}
