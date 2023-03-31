import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/widgets/image_input.dart';
import 'package:mobile/widgets/image_picker.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late MockAssetPathEntity allAlbum;

  late List<MockAssetEntity> mockAssets;

  setUp(() {
    appManager = StubbedAppManager();

    mockAssets = [
      createMockAssetEntity(fileName: "android_logo.png"),
      createMockAssetEntity(fileName: "anglers_log_logo.png"),
      createMockAssetEntity(fileName: "apple_logo.png"),
      createMockAssetEntity(fileName: "flutter_logo.png"),
    ];
    allAlbum = MockAssetPathEntity();
    when(allAlbum.assetCountAsync)
        .thenAnswer((_) => Future.value(mockAssets.length));
    when(allAlbum.getAssetListPaged(
      page: anyNamed("page"),
      size: anyNamed("size"),
    )).thenAnswer((_) => Future.value(mockAssets));
    when(appManager.imagePickerWrapper.pickImage(any))
        .thenAnswer((_) => Future.value(null));
    when(appManager.photoManagerWrapper.getAllAssetPathEntity(any))
        .thenAnswer((_) => Future.value(allAlbum));
    when(appManager.permissionHandlerWrapper.requestPhotos(any, any))
        .thenAnswer((_) => Future.value(true));

    var exif = MockExif();
    when(exif.getLatLong()).thenAnswer((_) => Future.value(null));
    when(exif.getOriginalDate()).thenAnswer((_) => Future.value(null));
    when(appManager.exifWrapper.fromPath(any))
        .thenAnswer((_) => Future.value(exif));
  });

  testWidgets("Controller updated when images picked", (tester) async {
    var controller = ImagesInputController();
    await pumpContext(
      tester,
      (_) => ImageInput(
        controller: controller,
        initialImageNames: const [],
      ),
      appManager: appManager,
    );
    // Wait for futures.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(ImagePicker));

    // Wait for futures.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(ImagePickerPage), findsOneWidget);
    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.byType(BackButton));

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(ImagePickerPage), findsNothing);
    expect(controller.value.length, 1);
  });

  testWidgets("Controller updated when images deleted", (tester) async {
    var controller = ImagesInputController();
    await pumpContext(
      tester,
      (_) => ImageInput(
        controller: controller,
      ),
      appManager: appManager,
    );
    // Wait for futures.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(ImagePicker));

    // Wait for futures.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(ImagePickerPage), findsOneWidget);
    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.byType(BackButton));

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(ImagePickerPage), findsNothing);
    expect(controller.value.length, 1);

    // Delete photo.
    await tapAndSettle(tester, find.byIcon(Icons.close));
    await tapAndSettle(tester, find.text("DELETE"));
    expect(controller.value.isEmpty, isTrue);
  });

  testWidgets("No initial images", (tester) async {
    await pumpContext(
      tester,
      (_) => ImageInput(
        controller: ImagesInputController(),
        initialImageNames: const [],
      ),
      appManager: appManager,
    );

    verifyNever(appManager.imageManager.images(
      imageNames: anyNamed("imageNames"),
      size: anyNamed("size"),
      devicePixelRatio: anyNamed("devicePixelRatio"),
    ));
  });

  testWidgets("ImageManager returns no results", (tester) async {
    when(appManager.imageManager.images(
      imageNames: anyNamed("imageNames"),
      size: anyNamed("size"),
      devicePixelRatio: anyNamed("devicePixelRatio"),
    )).thenAnswer((_) => Future.value({}));

    var controller = ImagesInputController();
    await pumpContext(
      tester,
      (_) => ImageInput(
        controller: controller,
        initialImageNames: const ["flutter_logo.png"],
      ),
      appManager: appManager,
    );

    verify(appManager.imageManager.images(
      imageNames: anyNamed("imageNames"),
      size: anyNamed("size"),
      devicePixelRatio: anyNamed("devicePixelRatio"),
    )).called(1);
    expect(controller.value.isEmpty, isTrue);
  });

  testWidgets("SingleImageInput controller updated when image is picked",
      (tester) async {
    var controller = InputController<PickedImage>();
    await pumpContext(
      tester,
      (_) => SingleImageInput(controller: controller),
      appManager: appManager,
    );
    // Wait for futures.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(ImagePicker));

    // Wait for futures.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(ImagePickerPage), findsOneWidget);
    await tapAndSettle(tester, find.byType(Image).first);

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(ImagePickerPage), findsNothing);
    expect(controller.hasValue, isTrue);
  });

  testWidgets("didUpdateWidget updates images future", (tester) async {
    String? initialImage;
    var controller = InputController<PickedImage>();
    await pumpContext(
      tester,
      (_) => DidUpdateWidgetTester<InputController<PickedImage>>(
        controller,
        (context, controller) => SingleImageInput(
          controller: controller,
          initialImageName: initialImage,
        ),
      ),
      appManager: appManager,
    );
    // Wait for futures.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Stub image.
    await stubImage(appManager, tester, "flutter_logo.png");
    initialImage = "flutter_logo.png";

    await tapAndSettle(tester, find.text("DID UPDATE WIDGET BUTTON"), 50);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.byType(Image), findsOneWidget);
  });
}
