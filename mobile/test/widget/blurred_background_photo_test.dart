import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/blurred_background_photo.dart';
import 'package:mobile/widgets/photo.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
  });

  testWidgets("Blurred background is rendered", (tester) async {
    await stubImage(appManager, tester, "flutter_logo.png");

    await pumpContext(
      tester,
      (_) => BlurredBackgroundPhoto(
        imageName: "flutter_logo.png",
        height: 200,
      ),
      appManager: appManager,
      mediaQueryData: const MediaQueryData(
        size: Size(600, 600),
      ),
    );

    expect(find.byType(ImageFiltered), findsOneWidget);
    expect(findLast<Photo>(tester).width, 500);
  });

  testWidgets("Blurred background is not rendered", (tester) async {
    await stubImage(appManager, tester, "flutter_logo.png");

    await pumpContext(
      tester,
      (_) => BlurredBackgroundPhoto(
        imageName: "flutter_logo.png",
        height: 200,
      ),
      appManager: appManager,
      mediaQueryData: const MediaQueryData(
        size: Size(400, 600),
      ),
    );

    expect(find.byType(ImageFiltered), findsNothing);
    expect(findLast<Photo>(tester).width, 400);
  });

  testWidgets("Custom border radius", (tester) async {
    await stubImage(appManager, tester, "flutter_logo.png");

    var radius = const BorderRadius.all(Radius.circular(30));
    await pumpContext(
      tester,
      (_) => BlurredBackgroundPhoto(
        imageName: "flutter_logo.png",
        height: 200,
        borderRadius: radius,
      ),
      appManager: appManager,
      mediaQueryData: const MediaQueryData(
        size: Size(600, 600),
      ),
    );

    expect(findFirst<ClipRRect>(tester).borderRadius, radius);
    expect(
      find.byWidgetPredicate((w) =>
          w is Container &&
          w.child is Stack &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).borderRadius == radius),
      findsOneWidget,
    );
  });

  testWidgets("Custom padding", (tester) async {
    await stubImage(appManager, tester, "flutter_logo.png");
    await pumpContext(
      tester,
      (_) => BlurredBackgroundPhoto(
        imageName: "flutter_logo.png",
        height: 200,
        padding: insetsDefault,
      ),
      appManager: appManager,
      mediaQueryData: const MediaQueryData(
        size: Size(600, 600),
      ),
    );

    expect(
      find.byWidgetPredicate((w) => w is Padding && w.padding == insetsDefault),
      findsOneWidget,
    );
  });
}
