import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/photo_gallery_page.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/photo.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
    when(appManager.ioWrapper.isAndroid).thenReturn(false);
  });

  testWidgets("Initial page", (tester) async {
    await stubImage(appManager, tester, "flutter_logo.png");
    await stubImage(appManager, tester, "anglers_log_logo.png");
    await stubImage(appManager, tester, "android_logo.png");
    await stubImage(appManager, tester, "apple_logo.png");

    await tester.pumpWidget(Testable(
      (_) => PhotoGalleryPage(
        fileNames: const [
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
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    expect(find.byType(Photo), findsOneWidget);
    verify(appManager.imageManager.image(
      fileName: "apple_logo.png",
      size: anyNamed("size"),
      devicePixelRatio: anyNamed("devicePixelRatio"),
    )).called(1);
  });

  testWidgets("Swiping shows correct image", (tester) async {
    await stubImage(appManager, tester, "flutter_logo.png");
    await stubImage(appManager, tester, "anglers_log_logo.png");
    await stubImage(appManager, tester, "android_logo.png");
    await stubImage(appManager, tester, "apple_logo.png");

    await tester.pumpWidget(Testable(
      (_) => PhotoGalleryPage(
        fileNames: const [
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
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    verify(appManager.imageManager.image(
      fileName: "flutter_logo.png",
      size: anyNamed("size"),
      devicePixelRatio: anyNamed("devicePixelRatio"),
    )).called(1);

    // Swipe left.
    await tester.fling(
        find.byType(PhotoGalleryPage), const Offset(-300, 0), 800);
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    verify(appManager.imageManager.image(
      fileName: "anglers_log_logo.png",
      size: anyNamed("size"),
      devicePixelRatio: anyNamed("devicePixelRatio"),
    )).called(1);

    // Swipe back.
    await tester.fling(
        find.byType(PhotoGalleryPage), const Offset(300, 0), 800);
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    verify(appManager.imageManager.image(
      fileName: "flutter_logo.png",
      size: anyNamed("size"),
      devicePixelRatio: anyNamed("devicePixelRatio"),
    )).called(1);
  });

  testWidgets("Swiping while zoomed in doesn't change images", (tester) async {
    await stubImage(appManager, tester, "flutter_logo.png");
    await stubImage(appManager, tester, "anglers_log_logo.png");
    await stubImage(appManager, tester, "android_logo.png");
    await stubImage(appManager, tester, "apple_logo.png");

    await tester.pumpWidget(Testable(
      (_) => PhotoGalleryPage(
        fileNames: const [
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
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    // Verify correct image is loaded.
    verify(appManager.imageManager.image(
      fileName: "flutter_logo.png",
      size: anyNamed("size"),
      devicePixelRatio: anyNamed("devicePixelRatio"),
    )).called(1);

    final center = tester.getCenter(find.byType(Photo));

    // Create two touches.
    final touch1 = await tester.startGesture(center.translate(-10, 0));
    final touch2 = await tester.startGesture(center.translate(10, 0));

    // Zoom in.
    await touch1.moveBy(const Offset(-200, 0));
    await touch2.moveBy(const Offset(200, 0));
    await touch1.up();
    await touch2.up();

    await tester.pumpAndSettle();

    // Swipe left should not work.
    await tester.fling(
        find.byType(PhotoGalleryPage), const Offset(-300, 0), 800);
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    expect(
      findFirst<PageView>(tester).physics.runtimeType,
      NeverScrollableScrollPhysics,
    );
    verifyNever(appManager.imageManager.image(
      fileName: "anglers_log_logo.png",
      size: anyNamed("size"),
      devicePixelRatio: anyNamed("devicePixelRatio"),
    ));
  });

  testWidgets("Swipe gesture is null for multi-touch", (tester) async {
    await stubImage(appManager, tester, "flutter_logo.png");

    await tester.pumpWidget(Testable(
      (_) => PhotoGalleryPage(
        fileNames: const ["flutter_logo.png"],
        initialFileName: "flutter_logo.png",
      ),
      appManager: appManager,
    ));
    // Let image future settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    final center = tester.getCenter(find.byType(Photo));

    // Touch down once, verify swipe gesture exists.
    await tester.startGesture(center.translate(-10, 0));
    await tester.pumpAndSettle();
    expect(findFirst<GestureDetector>(tester).onVerticalDragEnd, isNotNull);

    // Touch down a second time, verify swipe gesture is null.
    var touch = await tester.startGesture(center.translate(10, 0));
    await tester.pumpAndSettle();
    expect(findFirst<GestureDetector>(tester).onVerticalDragEnd, isNull);

    // Remove one touch, verify swipe is back.
    await touch.up();
    await tester.pumpAndSettle();
    expect(findFirst<GestureDetector>(tester).onVerticalDragEnd, isNotNull);
  });

  testWidgets("Swiping down dismisses page", (tester) async {
    await stubImage(appManager, tester, "flutter_logo.png");

    await tester.pumpWidget(Testable(
      (context) => Button(
        text: "TEST",
        onPressed: () => push(
          context,
          PhotoGalleryPage(
            fileNames: const [
              "flutter_logo.png",
            ],
            initialFileName: "flutter_logo.png",
          ),
        ),
      ),
      appManager: appManager,
    ));
    // Let image future settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    // Show the page.
    await tapAndSettle(tester, find.text("TEST"));
    expect(find.byType(PhotoGalleryPage), findsOneWidget);

    // Swipe down without enough velocity.
    await tester.fling(find.byType(PhotoGalleryPage), const Offset(0, 300), 50);
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    expect(find.byType(PhotoGalleryPage), findsOneWidget);

    // Swipe down with enough velocity.
    await tester.fling(
        find.byType(PhotoGalleryPage), const Offset(0, 300), 800);
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    expect(find.byType(PhotoGalleryPage), findsNothing);
  });
}
