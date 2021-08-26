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
    when(allAlbum.assetCount).thenReturn(mockAssets.length);
    when(allAlbum.getAssetListPaged(any, any))
        .thenAnswer((_) => Future.value(mockAssets));
    when(appManager.imagePickerWrapper.getImage(any))
        .thenAnswer((_) => Future.value(null));
    when(appManager.photoManagerWrapper.getAllAssetPathEntity(any))
        .thenAnswer((_) => Future.value(allAlbum));
    when(appManager.permissionHandlerWrapper.requestPhotos())
        .thenAnswer((_) => Future.value(true));
  });

  testWidgets("Controller updated when images picked", (tester) async {
    var controller = ListInputController<PickedImage>();
    await pumpContext(
      tester,
      (_) => ImageInput(
        controller: controller,
        initialImageNames: [],
      ),
      appManager: appManager,
    );
    // Wait for futures.
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(ImagePicker));

    // Wait for futures.
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.byType(ImagePickerPage), findsOneWidget);
    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.text("DONE"));

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(ImagePickerPage), findsNothing);
    expect(controller.value.length, 1);
  });

  testWidgets("No initial images", (tester) async {
    await pumpContext(
      tester,
      (_) => ImageInput(
        controller: ListInputController<PickedImage>(),
        initialImageNames: [],
      ),
      appManager: appManager,
    );

    verifyNever(appManager.imageManager.images(
      any,
      imageNames: anyNamed("imageNames"),
      size: anyNamed("size"),
    ));
  });

  testWidgets("ImageManager returns no results", (tester) async {
    when(appManager.imageManager.images(
      any,
      imageNames: anyNamed("imageNames"),
      size: anyNamed("size"),
    )).thenAnswer((_) => Future.value({}));

    var controller = ListInputController<PickedImage>();
    await pumpContext(
      tester,
      (_) => ImageInput(
        controller: controller,
        initialImageNames: ["flutter_logo.png"],
      ),
      appManager: appManager,
    );

    verify(appManager.imageManager.images(
      any,
      imageNames: anyNamed("imageNames"),
      size: anyNamed("size"),
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
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(ImagePicker));

    // Wait for futures.
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.byType(ImagePickerPage), findsOneWidget);
    await tapAndSettle(tester, find.byType(Image).first);

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(ImagePickerPage), findsNothing);
    expect(controller.hasValue, isTrue);
  });
}
