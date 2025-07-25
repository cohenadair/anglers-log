import 'dart:io';

import 'package:adair_flutter_lib/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/entity_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/photo.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
  });

  group("Images", () {
    testWidgets("No images", (tester) async {
      await tester.pumpWidget(
        Testable((_) => EntityPage(isStatic: true, children: const [])),
      );
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets("Image scrolling", (tester) async {
      await stubImage(managers, tester, "flutter_logo.png");
      await stubImage(managers, tester, "anglers_log_logo.png");
      await stubImage(managers, tester, "android_logo.png");
      await stubImage(managers, tester, "apple_logo.png");

      await tester.pumpWidget(
        Testable((_) {
          return EntityPage(
            imageNames: const [
              "flutter_logo.png",
              "anglers_log_logo.png",
              "android_logo.png",
              "apple_logo.png",
            ],
            isStatic: true,
            children: const [],
          );
        }, mediaQueryData: const MediaQueryData(size: Size(800, 800))),
      );

      // Verify initial images state.
      expect(find.byType(PageView), findsOneWidget);
      var carouselDots = tester
          .widgetList(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration as BoxDecoration).shape ==
                      BoxShape.circle &&
                  (widget.decoration as BoxDecoration).color != Colors.white,
            ),
          )
          .toList();
      expect(carouselDots.length, 4);
      expect(
        ((carouselDots[0] as Container).decoration as BoxDecoration).color,
        AppConfig.get.colorAppTheme,
      );
      expect(
        ((carouselDots[1] as Container).decoration as BoxDecoration).color,
        Colors.white.withValues(alpha: 0.5),
      );
      expect(
        ((carouselDots[2] as Container).decoration as BoxDecoration).color,
        Colors.white.withValues(alpha: 0.5),
      );
      expect(
        ((carouselDots[3] as Container).decoration as BoxDecoration).color,
        Colors.white.withValues(alpha: 0.5),
      );
      expect(find.byType(Photo), findsNWidgets(2));
      expect(findFirst<Photo>(tester).fileName, "flutter_logo.png");
      expect(findLast<Photo>(tester).fileName, "flutter_logo.png");

      // Swipe to the next image.
      await tester.fling(find.byType(Photo).first, const Offset(-300, 0), 800);
      await tester.pumpAndSettle(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      expect(findFirst<Photo>(tester).fileName, "anglers_log_logo.png");
      carouselDots = tester
          .widgetList(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration as BoxDecoration).shape ==
                      BoxShape.circle &&
                  (widget.decoration as BoxDecoration).color != Colors.white,
            ),
          )
          .toList();
      expect(
        ((carouselDots[0] as Container).decoration as BoxDecoration).color,
        Colors.white.withValues(alpha: 0.5),
      );
      expect(
        ((carouselDots[1] as Container).decoration as BoxDecoration).color,
        AppConfig.get.colorAppTheme,
      );
      expect(
        ((carouselDots[2] as Container).decoration as BoxDecoration).color,
        Colors.white.withValues(alpha: 0.5),
      );
      expect(
        ((carouselDots[3] as Container).decoration as BoxDecoration).color,
        Colors.white.withValues(alpha: 0.5),
      );
    });

    testWidgets("Image carousel hidden for only 1 image", (tester) async {
      await stubImage(managers, tester, "flutter_logo.png");
      await tester.pumpWidget(
        Testable(
          (_) => EntityPage(
            imageNames: const ["flutter_logo.png"],
            isStatic: true,
            children: const [],
          ),
          mediaQueryData: const MediaQueryData(size: Size(800, 800)),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle &&
              (widget.decoration as BoxDecoration).color != Colors.white,
        ),
        findsNothing,
      );
    });
  });

  testWidgets("No custom entities hide separator", (tester) async {
    await tester.pumpWidget(
      Testable((_) => EntityPage(isStatic: true, children: const [])),
    );
    expect(find.text("Custom Fields"), findsNothing);
  });

  testWidgets("Custom entities are shown with separator", (tester) async {
    var customEntityId = randomId();
    when(managers.customEntityManager.entity(customEntityId)).thenReturn(
      CustomEntity()
        ..id = randomId()
        ..name = "Test Name"
        ..type = CustomEntity_Type.text,
    );
    await tester.pumpWidget(
      Testable(
        (_) => EntityPage(
          customEntityValues: [
            CustomEntityValue()
              ..customEntityId = customEntityId
              ..value = "Test Value",
          ],
          isStatic: true,
          children: const [],
        ),
      ),
    );

    expect(find.text("Custom Fields"), findsOneWidget);
    expect(find.text("Test Name"), findsOneWidget);
    expect(find.text("Test Value"), findsOneWidget);
  });

  testWidgets("Static page does not show edit and delete buttons", (
    tester,
  ) async {
    await tester.pumpWidget(
      Testable((_) => EntityPage(isStatic: true, children: const [])),
    );

    expect(find.text("EDIT"), findsNothing);
    expect(find.byIcon(Icons.delete), findsNothing);
  });

  testWidgets(
    "Static page does not show edit and delete buttons (with images)",
    (tester) async {
      when(
        managers.imageManager.image(
          fileName: anyNamed("fileName"),
          size: anyNamed("size"),
          devicePixelRatio: anyNamed("devicePixelRatio"),
        ),
      ).thenAnswer((_) => File("test/resources/apple_logo.png").readAsBytes());

      await tester.pumpWidget(
        Testable(
          (_) => EntityPage(
            isStatic: true,
            imageNames: const ["apple_logo.png"],
            children: const [],
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(find.byType(FloatingButton), findsOneWidget);
    },
  );

  testWidgets("Dynamic page shows edit and delete buttons", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => EntityPage(
          onEdit: () {},
          onDelete: () {},
          deleteMessage: "Test",
          children: const [],
        ),
      ),
    );

    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });

  testWidgets("Dynamic page shows action buttons (with images)", (
    tester,
  ) async {
    when(
      managers.imageManager.image(
        fileName: anyNamed("fileName"),
        size: anyNamed("size"),
        devicePixelRatio: anyNamed("devicePixelRatio"),
      ),
    ).thenAnswer((_) => File("test/resources/apple_logo.png").readAsBytes());

    await tester.pumpWidget(
      Testable(
        (_) => EntityPage(
          imageNames: const ["apple_logo.png"],
          onEdit: () {},
          onDelete: () {},
          deleteMessage: "Test",
          children: const [],
        ),
        platform: TargetPlatform.android,
      ),
    );

    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets("Delete confirmation shown when deleteMessage != null", (
    tester,
  ) async {
    await tester.pumpWidget(
      Testable(
        (_) => EntityPage(
          deleteMessage: "This is a delete message.",
          onDelete: () {},
          onEdit: () {},
          children: const [],
        ),
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.delete));
    expect(find.text("This is a delete message."), findsOneWidget);
    expect(find.text("DELETE"), findsOneWidget);
  });

  testWidgets("All children rendered", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => EntityPage(
          isStatic: true,
          children: const [Text("Child 1"), Text("Child 2")],
        ),
      ),
    );

    expect(find.text("Child 1"), findsOneWidget);
    expect(find.text("Child 2"), findsOneWidget);
  });

  testWidgets("Scrolling shows new action buttons", (tester) async {
    await stubImage(managers, tester, "flutter_logo.png");

    await tester.pumpWidget(
      Testable(
        (_) => EntityPage(
          onEdit: () {},
          onDelete: () {},
          deleteMessage: "Delete",
          imageNames: const ["flutter_logo.png"],
          children: const [
            ListItem(title: Text("Child")),
            ListItem(title: Text("Child")),
            ListItem(title: Text("Child")),
            ListItem(title: Text("Child")),
            ListItem(title: Text("Child")),
            ListItem(title: Text("Child")),
            ListItem(title: Text("Child")),
            ListItem(title: Text("Child")),
            ListItem(title: Text("Child")),
            ListItem(title: Text("Child")),
            ListItem(title: Text("Child")),
            ListItem(title: Text("Child")),
            ListItem(title: Text("Child")),
            ListItem(title: Text("Child")),
            ListItem(title: Text("Child")),
            ListItem(title: Text("Last")),
          ],
        ),
        mediaQueryData: const MediaQueryData(size: Size(300, 500)),
      ),
    );

    // Verify buttons are floating.
    expect(find.byType(Photo), findsOneWidget);
    expect(find.byType(FloatingButton), findsNWidgets(3));
    expect(find.byIcon(Icons.edit), findsOneWidget);
    tester.widgetList<FloatingButton>(find.byType(FloatingButton)).forEach((
      button,
    ) {
      expect(button.transparentBackground, isFalse);
    });

    // Scroll enough for the buttons to change.
    await tester.scrollUntilVisible(
      find.text("Last"),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.byType(FloatingButton), findsNWidgets(3));
    expect(find.byIcon(Icons.edit), findsOneWidget);
    tester.widgetList<FloatingButton>(find.byType(FloatingButton)).forEach((
      button,
    ) {
      expect(button.transparentBackground, isTrue);
    });
  });

  testWidgets("Null onShare hides share button", (tester) async {
    await pumpContext(
      tester,
      (_) => EntityPage(
        onShare: null,
        onEdit: () {},
        onDelete: () {},
        deleteMessage: "Delete",
        children: const [],
      ),
    );

    // Back, edit, and delete buttons. Share button is hidden.
    expect(find.byType(FloatingButton), findsNWidgets(3));
    expect(find.byIcon(Icons.ios_share), findsNothing);
    expect(find.byIcon(Icons.share), findsNothing);
  });

  testWidgets("Non-null onShare shows share button", (tester) async {
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);

    await pumpContext(
      tester,
      (_) => EntityPage(
        onShare: () {},
        onEdit: () {},
        onDelete: () {},
        deleteMessage: "Delete",
        children: const [],
      ),
    );

    // Back, edit, delete, and share buttons.
    expect(find.byType(FloatingButton), findsNWidgets(4));

    var deleteButton = findFirstWithIcon<FloatingButton>(tester, Icons.delete);
    expect(deleteButton.padding!.right, 0);

    expect(find.byIcon(Icons.ios_share), findsOneWidget);
  });

  testWidgets("Copy button hidden", (tester) async {
    await pumpContext(
      tester,
      (_) => EntityPage(
        onShare: () {},
        onEdit: () {},
        onDelete: () {},
        onCopy: null,
        deleteMessage: "Delete",
        children: const [],
      ),
    );
    expect(find.text("COPY"), findsNothing);
  });

  testWidgets("Copy button shown", (tester) async {
    var invoked = false;

    await pumpContext(
      tester,
      (_) => EntityPage(
        onShare: () {},
        onEdit: () {},
        onDelete: () {},
        onCopy: () => invoked = true,
        deleteMessage: "Delete",
        children: const [],
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.copy));
    expect(invoked, isTrue);
  });
}
