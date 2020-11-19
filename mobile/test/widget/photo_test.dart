import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/widgets/photo.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockImageManager: true,
    );
  });

  testWidgets("Invalid image shows placeholder", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => Photo(
        fileName: null,
        width: 50,
        height: 50,
      ),
      appManager: appManager,
    ));
    await tester.pump(Duration(milliseconds: 250));

    expect(find.byIcon(CustomIcons.catches), findsOneWidget);
  });

  testWidgets("Invalid image no size shows empty placeholder",
      (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => Photo(
        fileName: null,
      ),
      appManager: appManager,
    ));
    await tester.pump(Duration(milliseconds: 250));

    expect(find.byIcon(CustomIcons.catches), findsNothing);
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("Circular placeholder", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => Photo(
        fileName: null,
        circular: true,
        width: 50,
        height: 50,
      ),
      appManager: appManager,
    ));
    await tester.pump(Duration(milliseconds: 250));

    expect((findFirst<Container>(tester).decoration as BoxDecoration).shape,
        BoxShape.circle);
    expect(find.byType(ClipOval), findsOneWidget);
  });

  testWidgets("Rectangular placeholder", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => Photo(
        fileName: null,
        width: 50,
        height: 50,
      ),
      appManager: appManager,
    ));
    await tester.pump(Duration(milliseconds: 250));

    expect((findFirst<Container>(tester).decoration as BoxDecoration).shape,
        BoxShape.rectangle);
    expect(find.byType(ClipOval), findsNothing);
  });

  testWidgets("No cache size uses default", (WidgetTester tester) async {
    ui.Image image = await loadImage(tester, "test/resources/flutter_logo.png");
    when(appManager.mockImageManager.dartImage(any, any, any))
        .thenAnswer((_) => Future.value(image));

    await tester.pumpWidget(Testable(
      (_) => Photo(
        fileName: "flutter_logo.png",
      ),
      appManager: appManager,
    ));
    await tester.pump(Duration(milliseconds: 250));

    expect(find.byType(RawImage), findsOneWidget);
  });

  testWidgets("Given cache size is honored", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => Photo(
        fileName: "flutter_logo.png",
        cacheSize: 50,
      ),
      appManager: appManager,
    ));
    await tester.pump(Duration(milliseconds: 250));

    expect(
      verify(appManager.mockImageManager.dartImage(any, any, captureAny))
          .captured
          .single,
      50,
    );
  });

  testWidgets("If no cache size, widget size is used",
      (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => Photo(
        fileName: "flutter_logo.png",
        width: 50,
        height: 50,
      ),
      appManager: appManager,
    ));
    await tester.pump(Duration(milliseconds: 250));

    expect(
      verify(appManager.mockImageManager.dartImage(any, any, captureAny))
          .captured
          .single,
      50,
    );
  });
}
