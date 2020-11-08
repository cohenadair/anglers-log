import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/photo_gallery_page.dart';
import 'package:mobile/widgets/photo.dart';
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

  Future<ui.Image> image(WidgetTester tester, String name) async {
    ui.Image image = await loadImage(tester, "test/resources/$name");
    when(appManager.mockImageManager.dartImage(any, name, any))
        .thenAnswer((_) => Future.value(image));
    return image;
  }

  testWidgets("Initial page", (WidgetTester tester) async {
    await image(tester, "flutter_logo.png");
    await image(tester, "anglers_log_logo.png");
    await image(tester, "android_logo.png");
    await image(tester, "apple_logo.png");

    await tester.pumpWidget(Testable(
      (_) => PhotoGalleryPage(
        fileNames: [
          "flutter_logo.png",
          "anglers_log_logo.png",
          "apple_logo.png",
          "android_logo.png",
        ],
        initialFileName: "apple_logo.png",
      ),
      appManager: appManager,
    ));
    // Let image future settle.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.byType(Photo), findsOneWidget);
    verify(appManager.mockImageManager.dartImage(any, "apple_logo.png", any))
        .called(1);
  });

  testWidgets("Swiping shows correct image", (WidgetTester tester) async {
    await image(tester, "flutter_logo.png");
    await image(tester, "anglers_log_logo.png");
    await image(tester, "android_logo.png");
    await image(tester, "apple_logo.png");

    await tester.pumpWidget(Testable(
      (_) => PhotoGalleryPage(
        fileNames: [
          "flutter_logo.png",
          "anglers_log_logo.png",
          "apple_logo.png",
          "android_logo.png",
        ],
        initialFileName: "flutter_logo.png",
      ),
      appManager: appManager,
    ));
    // Let image future settle.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    verify(appManager.mockImageManager.dartImage(any, "flutter_logo.png", any))
        .called(1);

    // Swipe left.
    await tester.fling(find.byType(Photo), Offset(-300, 0), 800);
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    verify(appManager.mockImageManager.dartImage(any, "anglers_log_logo.png",
        any)).called(1);

    // Swipe back.
    await tester.fling(find.byType(Photo), Offset(300, 0), 800);
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    verify(appManager.mockImageManager.dartImage(any, "flutter_logo.png", any))
        .called(1);
  });
}