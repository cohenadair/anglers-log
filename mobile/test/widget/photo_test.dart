import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/photo_gallery_page.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/widgets/photo.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
  });

  testWidgets("Invalid image shows placeholder", (tester) async {
    await tester.pumpWidget(
      Testable((_) => const Photo(fileName: null, width: 50, height: 50)),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byIcon(CustomIcons.catches), findsOneWidget);
  });

  testWidgets("showPlaceholder set to false", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => const Photo(
          fileName: null,
          width: 50,
          height: 50,
          showPlaceholder: false,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byIcon(CustomIcons.catches), findsNothing);
  });

  testWidgets("Empty child", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => const Photo(
          fileName: null,
          width: 50,
          height: 50,
          showPlaceholder: false,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(Empty), findsOneWidget);
    expect(find.byType(Padding), findsNothing);
  });

  testWidgets("Invalid image no size shows empty placeholder", (tester) async {
    await tester.pumpWidget(Testable((_) => const Photo(fileName: null)));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byIcon(CustomIcons.catches), findsNothing);
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("Circular placeholder", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => const Photo(
          fileName: null,
          isCircular: true,
          width: 50,
          height: 50,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      (findFirst<Container>(tester).decoration as BoxDecoration).shape,
      BoxShape.circle,
    );
    expect(find.byType(ClipOval), findsOneWidget);
  });

  testWidgets("Rectangular placeholder", (tester) async {
    await tester.pumpWidget(
      Testable((_) => const Photo(fileName: null, width: 50, height: 50)),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      (findFirst<Container>(tester).decoration as BoxDecoration).shape,
      BoxShape.rectangle,
    );
    expect(find.byType(ClipOval), findsNothing);
  });

  testWidgets("No cache size uses default", (tester) async {
    await stubImage(managers, tester, "flutter_logo.png");

    await tester.pumpWidget(
      Testable((_) => const Photo(fileName: "flutter_logo.png")),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(RawImage), findsOneWidget);
  });

  testWidgets("Given cache size is honored", (tester) async {
    await tester.pumpWidget(
      Testable((_) => const Photo(fileName: "flutter_logo.png", cacheSize: 50)),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      verify(
        managers.imageManager.image(
          fileName: anyNamed("fileName"),
          size: captureAnyNamed("size"),
          devicePixelRatio: anyNamed("devicePixelRatio"),
        ),
      ).captured.single,
      50,
    );
  });

  testWidgets("If no cache size, widget size is used", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => const Photo(fileName: "flutter_logo.png", width: 50, height: 50),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      verify(
        managers.imageManager.image(
          fileName: anyNamed("fileName"),
          size: captureAnyNamed("size"),
          devicePixelRatio: anyNamed("devicePixelRatio"),
        ),
      ).captured.single,
      50,
    );
  });

  testWidgets("Tapping photo opens gallery", (tester) async {
    await stubImage(managers, tester, "flutter_logo.png", anyName: true);

    await tester.pumpWidget(
      Testable(
        (_) => const Photo(
          fileName: "flutter_logo.png",
          galleryImages: ["flutter_logo.png"],
        ),
      ),
    );
    // Wait for photo future to settle.
    await tester.pump(const Duration(milliseconds: 250));
    await tapAndSettle(tester, find.byType(Photo).first);
    expect(find.byType(PhotoGalleryPage), findsOneWidget);
  });

  testWidgets("showFullOnTap shows full screen image", (tester) async {
    await stubImage(managers, tester, "flutter_logo.png", anyName: true);

    await tester.pumpWidget(
      Testable(
        (_) => const Photo(fileName: "flutter_logo.png", showFullOnTap: true),
      ),
    );
    // Wait for photo future to settle.
    await tester.pump(const Duration(milliseconds: 250));
    await tapAndSettle(tester, find.byType(Photo).first);
    expect(find.byType(PhotoGalleryPage), findsOneWidget);
  });
}
