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

    // TODO: This shouldn't actually be called. There's an issue loading images
    //  in widget tests that causes them to have no size. So unless an image
    //  size is explicitly set (which is isn't for the gallery), pinch zooming
    //  will not work. Some workarounds are detailed on GitHub, but none of
    //  them seem to work.
    //
    //  https://github.com/flutter/flutter/issues/38997
    verify(appManager.imageManager.image(
      fileName: "anglers_log_logo.png",
      size: anyNamed("size"),
      devicePixelRatio: anyNamed("devicePixelRatio"),
    )).called(1);
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
