import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/entity_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/photo.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;

  Future<ui.Image> image(tester, String name) async {
    var image = await loadImage(tester, "test/resources/$name");
    when(appManager.mockImageManager.dartImage(any, name, any))
        .thenAnswer((_) => Future.value(image));
    return image;
  }

  setUp(() {
    appManager = MockAppManager(
      mockImageManager: true,
      mockCustomEntityManager: true,
    );
  });

  group("Images", () {
    testWidgets("No images", (tester) async {
      await tester.pumpWidget(Testable((_) => EntityPage(children: [])));
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets("Image scrolling", (tester) async {
      await image(tester, "flutter_logo.png");
      await image(tester, "anglers_log_logo.png");
      await image(tester, "android_logo.png");
      await image(tester, "apple_logo.png");

      BuildContext context;
      await tester.pumpWidget(Testable(
        (buildContext) {
          context = buildContext;
          return EntityPage(
            imageNames: [
              "flutter_logo.png",
              "anglers_log_logo.png",
              "android_logo.png",
              "apple_logo.png"
            ],
            children: [],
          );
        },
        appManager: appManager,
        mediaQueryData: MediaQueryData(
          size: Size(800, 800),
        ),
      ));

      // Verify initial images state.
      expect(find.byType(PageView), findsOneWidget);
      var carouselDots = tester
          .widgetList(find.byWidgetPredicate((widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle))
          .toList();
      expect(carouselDots.length, 4);
      expect(((carouselDots[0] as Container).decoration as BoxDecoration).color,
          Theme.of(context).primaryColor);
      expect(((carouselDots[1] as Container).decoration as BoxDecoration).color,
          Colors.white.withOpacity(0.5));
      expect(((carouselDots[2] as Container).decoration as BoxDecoration).color,
          Colors.white.withOpacity(0.5));
      expect(((carouselDots[3] as Container).decoration as BoxDecoration).color,
          Colors.white.withOpacity(0.5));
      expect(find.byType(Photo), findsOneWidget);
      expect(findFirst<Photo>(tester).fileName, "flutter_logo.png");

      // Swipe to the next image.
      await tester.fling(find.byType(Photo), Offset(-300, 0), 800);
      await tester.pumpAndSettle(Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      expect(findFirst<Photo>(tester).fileName, "anglers_log_logo.png");
      carouselDots = tester
          .widgetList(find.byWidgetPredicate((widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle))
          .toList();
      expect(((carouselDots[0] as Container).decoration as BoxDecoration).color,
          Colors.white.withOpacity(0.5));
      expect(((carouselDots[1] as Container).decoration as BoxDecoration).color,
          Theme.of(context).primaryColor);
      expect(((carouselDots[2] as Container).decoration as BoxDecoration).color,
          Colors.white.withOpacity(0.5));
      expect(((carouselDots[3] as Container).decoration as BoxDecoration).color,
          Colors.white.withOpacity(0.5));
    });

    testWidgets("Image carousel hidden for only 1 image",
        (tester) async {
      await image(tester, "flutter_logo.png");
      await tester.pumpWidget(Testable(
        (_) => EntityPage(
          imageNames: [
            "flutter_logo.png",
          ],
          children: [],
        ),
        appManager: appManager,
        mediaQueryData: MediaQueryData(
          size: Size(800, 800),
        ),
      ));

      expect(
        find.byWidgetPredicate((widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle),
        findsNothing,
      );
    });
  });

  testWidgets("No custom entities hide separator", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => EntityPage(
        children: [],
      ),
    ));
    expect(find.text("Custom Fields"), findsNothing);
  });

  testWidgets("Custom entities are shown with separator", (tester) async {
    var customEntityId = randomId();
    when(appManager.mockCustomEntityManager.entity(customEntityId)).thenReturn(
      CustomEntity()
        ..id = randomId()
        ..name = "Test Name"
        ..type = CustomEntity_Type.TEXT,
    );
    await tester.pumpWidget(Testable(
      (_) => EntityPage(
        children: [],
        customEntityValues: [
          CustomEntityValue()
            ..customEntityId = customEntityId
            ..value = "Test Value",
        ],
      ),
      appManager: appManager,
    ));

    expect(find.text("Custom Fields"), findsOneWidget);
    expect(find.text("Test Name"), findsOneWidget);
    expect(find.text("Test Value"), findsOneWidget);
  });

  testWidgets("Static page does not show edit and delete buttons",
      (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => EntityPage(
          children: [],
          static: true,
        ),
      ),
    );

    expect(find.text("EDIT"), findsNothing);
    expect(find.byIcon(Icons.delete), findsNothing);
  });

  testWidgets("Dynamic page shows edit and delete buttons",
      (tester) async {
    await tester.pumpWidget(Testable((_) => EntityPage(children: [])));

    expect(find.text("EDIT"), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });

  testWidgets("Delete confirmation shown when deleteMessage != null",
      (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => EntityPage(
          children: [],
          deleteMessage: "This is a delete message.",
        ),
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.delete));
    expect(find.text("This is a delete message."), findsOneWidget);
    expect(find.text("DELETE"), findsOneWidget);
  });

  testWidgets("Delete confirmation not shown when deleteMessage == null",
      (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => EntityPage(
          children: [],
        ),
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.delete));
    expect(find.text("DELETE"), findsNothing);
  });

  testWidgets("All children rendered", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => EntityPage(
          children: [
            Text("Child 1"),
            Text("Child 2"),
          ],
        ),
      ),
    );

    expect(find.text("Child 1"), findsOneWidget);
    expect(find.text("Child 2"), findsOneWidget);
  });
}
