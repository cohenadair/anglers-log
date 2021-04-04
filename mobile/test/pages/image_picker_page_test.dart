import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/empty_list_placeholder.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_manager/photo_manager.dart';

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

  testWidgets("No device photos empty result", (tester) async {
    when(appManager.photoManagerWrapper.getAllAssetPathEntity(any))
        .thenAnswer((_) => Future.value(null));

    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.byType(EmptyListPlaceholder), findsOneWidget);
  });

  testWidgets("Empty all album shows placeholder", (tester) async {
    when(allAlbum.assetCount).thenReturn(0);
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.byType(EmptyListPlaceholder), findsOneWidget);
  });

  testWidgets("Null all album shows placeholder", (tester) async {
    when(appManager.photoManagerWrapper.getAllAssetPathEntity(any))
        .thenAnswer((_) => Future.value(null));
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.byType(EmptyListPlaceholder), findsOneWidget);
  });

  testWidgets("Photos already selected", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
        initialImages: [
          PickedImage(originalFileId: "android_logo.png"),
          PickedImage(originalFileId: "flutter_logo.png"),
        ],
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
  });

  testWidgets("Null result from camera does not invoke callback",
      (tester) async {
    var called = false;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) => called = true,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("Gallery"));
    await tapAndSettle(tester, find.text("Camera").last);

    verify(appManager.imagePickerWrapper.getImage(any)).called(1);
    expect(called, isFalse);
  });

  testWidgets("Result from camera invokes callback", (tester) async {
    var called = false;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) => called = true,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    when(appManager.imagePickerWrapper.getImage(any))
        .thenAnswer((_) => Future.value(PickedFile("")));

    await tapAndSettle(tester, find.text("Gallery"));
    await tapAndSettle(tester, find.text("Camera").last);

    verify(appManager.imagePickerWrapper.getImage(any)).called(1);
    expect(called, isTrue);
  });

  testWidgets("Doc single picker nothing picked", (tester) async {
    var called = false;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage.single(
        onImagePicked: (_, __) => called = true,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    when(appManager.filePickerWrapper.pickFiles(
      type: anyNamed("type"),
      allowMultiple: anyNamed("allowMultiple"),
    )).thenAnswer((_) => Future.value(null));

    await tapAndSettle(tester, find.text("Gallery"));
    await tapAndSettle(tester, find.text("Browse").last);

    expect(called, isFalse);
    expect(find.text("Must select an image file."), findsNothing);
    expect(find.text("Must select image files."), findsNothing);
  });

  testWidgets("Doc multi picker nothing picked", (tester) async {
    var called = false;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) => called = true,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    when(appManager.filePickerWrapper.pickFiles(
      type: anyNamed("type"),
      allowMultiple: anyNamed("allowMultiple"),
    )).thenAnswer((_) => Future.value(null));

    await tapAndSettle(tester, find.text("Gallery"));
    await tapAndSettle(tester, find.text("Browse").last);

    expect(called, isFalse);
    expect(find.text("Must select an image file."), findsNothing);
    expect(find.text("Must select image files."), findsNothing);

    when(appManager.filePickerWrapper.pickFiles(
      type: anyNamed("type"),
      allowMultiple: anyNamed("allowMultiple"),
    )).thenAnswer((_) => Future.value(FilePickerResult([])));

    await tapAndSettle(tester, find.text("Gallery"));
    await tapAndSettle(tester, find.text("Browse").last);

    expect(called, isFalse);
    expect(find.text("Must select an image file."), findsNothing);
    expect(find.text("Must select image files."), findsNothing);
  });

  testWidgets("Doc multi picker valid picks invokes callback", (tester) async {
    var called = false;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) => called = true,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    when(appManager.filePickerWrapper.pickFiles(
      type: anyNamed("type"),
      allowMultiple: anyNamed("allowMultiple"),
    )).thenAnswer(
      (_) => Future.value(
        FilePickerResult([
          PlatformFile(path: "test.jpg"),
          PlatformFile(path: "test2.png"),
        ]),
      ),
    );

    await tapAndSettle(tester, find.text("Gallery"));
    await tapAndSettle(tester, find.text("Browse").last);

    expect(find.text("Must select image files."), findsNothing);
    expect(called, isTrue);
  });

  testWidgets("No done button for single picker", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage.single(
        onImagePicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.text("DONE"), findsNothing);
  });

  testWidgets("Done button for multi picker", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.text("DONE"), findsOneWidget);
  });

  testWidgets("Done button disabled when pick is required", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
        requiresPick: true,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(findFirstWithText<ActionButton>(tester, "DONE").onPressed, isNull);
  });

  testWidgets("Done button enabled when pick is not required", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
        requiresPick: false,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(
        findFirstWithText<ActionButton>(tester, "DONE").onPressed, isNotNull);
  });

  testWidgets("Done button invokes callback", (tester) async {
    var called = false;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) => called = true,
        requiresPick: false,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("DONE"));

    expect(called, isTrue);
  });

  testWidgets("Clear button clears selected for multi picker", (tester) async {
    var called = false;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) => called = true,
        initialImages: [
          PickedImage(originalFileId: "android_logo.png"),
          PickedImage(originalFileId: "flutter_logo.png"),
        ],
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));

    await tapAndSettle(tester, find.text("CLEAR"));

    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(called, isFalse);
  });

  testWidgets("Clear button invokes callback for single picker",
      (tester) async {
    var called = false;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage.single(
        onImagePicked: (_, __) => called = true,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("CLEAR"));
    expect(called, isTrue);
  });

  testWidgets("X/Y label shows for multi picker", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
        initialImages: [
          PickedImage(originalFileId: "android_logo.png"),
          PickedImage(originalFileId: "flutter_logo.png"),
        ],
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
    expect(find.text("2 / 4 Selected"), findsOneWidget);
  });

  testWidgets("Selecting/deselecting photo updates state for multi picker",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tapAndSettle(tester, find.byType(Image).first);
    expect(find.byIcon(Icons.check_circle), findsNothing);
  });

  testWidgets("Selecting photo invokes callback for single picker",
      (tester) async {
    var called = false;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage.single(
        onImagePicked: (_, __) => called = true,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    expect(called, isTrue);
  });

  testWidgets("Do not pop picker if popsOnFinish is false", (tester) async {
    var called = false;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) => called = true,
        popsOnFinish: false,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.text("DONE"));
    expect(called, isTrue);
    expect(find.text("DONE"), findsOneWidget);
  });

  testWidgets("Picked image with invalid coordinates", (tester) async {
    var entity = createMockAssetEntity(
      fileName: "android_logo.png",
      latLngAsync: null,
      latLngLegacy: null,
    );
    when(allAlbum.getAssetListPaged(any, any))
        .thenAnswer((_) => Future.value([entity]));

    PickedImage? result;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage.single(
        onImagePicked: (_, image) => result = image,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    expect(result!.position, isNull);
    expect(entity.latLngAsyncCalls, 1);
  });

  testWidgets("Picked image with valid legacy coordinates", (tester) async {
    var entity = createMockAssetEntity(
      fileName: "android_logo.png",
      latLngAsync: null,
      latLngLegacy: LatLng(latitude: 0.654321, longitude: 0.123456),
    );
    when(allAlbum.getAssetListPaged(any, any))
        .thenAnswer((_) => Future.value([entity]));

    PickedImage? result;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage.single(
        onImagePicked: (_, image) => result = image,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    expect(result!.position, isNotNull);
    expect(entity.latLngAsyncCalls, 0);
  });

  testWidgets("Picked image with valid OS coordinates", (tester) async {
    var entity = createMockAssetEntity(
      fileName: "android_logo.png",
      latLngAsync: LatLng(latitude: 0.654321, longitude: 0.123456),
      latLngLegacy: null,
    );
    when(allAlbum.getAssetListPaged(any, any))
        .thenAnswer((_) => Future.value([entity]));

    PickedImage? result;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage.single(
        onImagePicked: (_, image) => result = image,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    expect(result!.position, isNotNull);
    expect(entity.latLngAsyncCalls, 1);
  });

  testWidgets("Placeholder grid shown when waiting for permission future",
      (tester) async {
    when(appManager.permissionHandlerWrapper.requestPhotos())
        .thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
      ),
      appManager: appManager,
    ));

    // Placeholder grid.
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets("Placeholder grid shown when waiting for gallery future",
      (tester) async {
    // Stub getting the "all" asset, such that the app will show a placeholder
    // when the future finishes.
    when(appManager.photoManagerWrapper.getAllAssetPathEntity(any))
        .thenAnswer((_) => Future.value(null));

    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
      ),
      appManager: appManager,
    ));

    // Placeholder grid.
    expect(find.byType(GridView), findsOneWidget);

    // Pump and settle, to complete the future.
    await tester.pumpAndSettle(Duration(milliseconds: 50));
    expect(find.byType(EmptyListPlaceholder), findsOneWidget);
  });

  testWidgets("Placeholder grid shown when waiting for assets future",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
      ),
      appManager: appManager,
    ));

    // No images are rendered, but a placeholder grid is.
    expect(find.byType(Image), findsNothing);
    expect(find.byType(GridView), findsOneWidget);

    // Pump and settle, to complete the future.
    await tester.pumpAndSettle(Duration(milliseconds: 50));
    expect(find.byType(Image), findsNWidgets(4));
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets("No permission placeholder shown", (tester) async {
    when(appManager.permissionHandlerWrapper.requestPhotos())
        .thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.text("OPEN SETTINGS"), findsOneWidget);
  });

  testWidgets("Pagination", (tester) async {
    // Stub many more assets than can be shown at once.
    when(allAlbum.assetCount).thenReturn(mockAssets.length * 100);

    var w = galleryMaxThumbSize * 4;
    var h = galleryMaxThumbSize * 8;

    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
      ),
      appManager: appManager,
      mediaQueryData: MediaQueryData(
        size: Size(w, h),
      ),
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    // Verify initial load.
    verify(allAlbum.getAssetListPaged(0, any)).called(1);

    // Stub new images.
    mockAssets = [
      createMockAssetEntity(
        id: randomId().toString(),
        fileName: "android_logo.png",
      ),
      createMockAssetEntity(
        id: randomId().toString(),
        fileName: "anglers_log_logo.png",
      ),
      createMockAssetEntity(
        id: randomId().toString(),
        fileName: "apple_logo.png",
      ),
      createMockAssetEntity(
        id: randomId().toString(),
        fileName: "flutter_logo.png",
      ),
    ];

    // Scroll enough to load a new page.
    var gesture = await tester.startGesture(Offset(0, 300));
    await gesture.moveBy(Offset(0, -300));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    // Verify another page load.
    verify(allAlbum.getAssetListPaged(1, any)).called(1);

    // Stub new images.
    mockAssets = [
      createMockAssetEntity(
        id: randomId().toString(),
        fileName: "android_logo.png",
      ),
      createMockAssetEntity(
        id: randomId().toString(),
        fileName: "anglers_log_logo.png",
      ),
      createMockAssetEntity(
        id: randomId().toString(),
        fileName: "apple_logo.png",
      ),
      createMockAssetEntity(
        id: randomId().toString(),
        fileName: "flutter_logo.png",
      ),
    ];

    // Repeat.
    gesture = await tester.startGesture(Offset(0, 300));
    await gesture.moveBy(Offset(0, -300));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    // Verify another page load.
    verify(allAlbum.getAssetListPaged(2, any)).called(1);
  });
}
