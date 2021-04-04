import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/widgets/image_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.permissionHandlerWrapper.requestPhotos())
        .thenAnswer((_) => Future.value(true));

    when(appManager.photoManagerWrapper.getAllAssetPathEntity(any))
        .thenAnswer((_) => Future.value(null));
  });

  testWidgets("Enabled", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ImageInput(
        onImagesPicked: (_) => {},
      ),
      appManager: appManager,
    ));

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(find.byType(ImagePickerPage), findsOneWidget);
  });

  testWidgets("Disabled", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImageInput(
          onImagesPicked: (_) => {},
          enabled: false,
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(find.byType(ImagePickerPage), findsNothing);
  });

  testWidgets("Single selection", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImageInput.single(
          onImagePicked: (_) => {},
          requestPhotoPermission: () => Future.value(true),
        ),
      ),
    );
    expect(find.text("Photo"), findsOneWidget);
    expect(find.text("Photos"), findsNothing);
  });

  testWidgets("Multiple selection", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImageInput(
          onImagesPicked: (_) => {},
        ),
      ),
    );
    expect(find.text("Photos"), findsOneWidget);
    expect(find.text("Photo"), findsNothing);
  });

  testWidgets("No images", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImageInput(
          onImagesPicked: (_) => {},
        ),
      ),
    );
    expect(find.byType(Image), findsNothing);
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("At least one image, enabled", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImageInput(
          onImagesPicked: (_) => {},
          initialImages: [
            PickedImage(originalFile: File("test/resources/flutter_logo.png")),
            PickedImage(originalFile: File("test/resources/flutter_logo.png")),
          ],
        ),
      ),
    );

    expect(find.byType(Image), findsNWidgets(2));
    expect(findFirst<ListView>(tester).physics, isNull);
  });

  testWidgets("At least one image, disabled", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImageInput(
          onImagesPicked: (_) => {},
          initialImages: [
            PickedImage(originalFile: File("test/resources/flutter_logo.png")),
            PickedImage(originalFile: File("test/resources/flutter_logo.png")),
          ],
          enabled: false,
        ),
      ),
    );

    expect(find.byType(Image), findsNWidgets(2));
    expect(findFirst<ListView>(tester).physics, isNotNull);
  });

  testWidgets("Load from file", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImageInput(
          onImagesPicked: (_) => {},
          initialImages: [
            PickedImage(originalFile: File("test/resources/flutter_logo.png")),
          ],
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets("Load from memory", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImageInput(
          onImagesPicked: (_) => {},
          initialImages: [
            PickedImage(
              thumbData:
                  File("test/resources/flutter_logo.png").readAsBytesSync(),
            ),
          ],
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });
}
