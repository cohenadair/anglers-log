import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/photo_gallery_page.dart';
import 'package:mobile/widgets/photo.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
  });

  testWidgets("Initial page", (tester) async {
    await stubImage(appManager, tester, "flutter_logo.png");
    await stubImage(appManager, tester, "anglers_log_logo.png");
    await stubImage(appManager, tester, "android_logo.png");
    await stubImage(appManager, tester, "apple_logo.png");

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
    verify(appManager.imageManager.image(
      any,
      fileName: "apple_logo.png",
      size: anyNamed("size"),
    )).called(1);
  });

  testWidgets("Swiping shows correct image", (tester) async {
    await stubImage(appManager, tester, "flutter_logo.png");
    await stubImage(appManager, tester, "anglers_log_logo.png");
    await stubImage(appManager, tester, "android_logo.png");
    await stubImage(appManager, tester, "apple_logo.png");

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

    verify(appManager.imageManager.image(
      any,
      fileName: "flutter_logo.png",
      size: anyNamed("size"),
    )).called(1);

    // Swipe left.
    await tester.fling(find.byType(Photo), Offset(-300, 0), 800);
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    verify(appManager.imageManager.image(
      any,
      fileName: "anglers_log_logo.png",
      size: anyNamed("size"),
    )).called(1);

    // Swipe back.
    await tester.fling(find.byType(Photo), Offset(300, 0), 800);
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    verify(appManager.imageManager.image(
      any,
      fileName: "flutter_logo.png",
      size: anyNamed("size"),
    )).called(1);
  });
}
