import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/empty_list_placeholder.dart';
import 'package:mobile/widgets/widget.dart';
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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(EmptyListPlaceholder), findsOneWidget);
  });

  testWidgets("Empty all album shows placeholder", (tester) async {
    when(allAlbum.getAssetListPaged(
      page: anyNamed("page"),
      size: anyNamed("size"),
    )).thenAnswer((_) => Future.value([]));
    when(allAlbum.assetCountAsync).thenAnswer((_) => Future.value(0));

    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(EmptyListPlaceholder), findsOneWidget);
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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("Gallery"));
    await tapAndSettle(tester, find.text("Camera").last);

    verify(appManager.imagePickerWrapper.pickImage(any)).called(1);
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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    when(appManager.imagePickerWrapper.pickImage(any))
        .thenAnswer((_) => Future.value(XFile("")));

    await tapAndSettle(tester, find.text("Gallery"));
    await tapAndSettle(tester, find.text("Camera").last);

    verify(appManager.imagePickerWrapper.pickImage(any)).called(1);
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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

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
    )).thenAnswer((_) => Future.value(const FilePickerResult([])));

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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    when(appManager.filePickerWrapper.pickFiles(
      type: anyNamed("type"),
      allowMultiple: anyNamed("allowMultiple"),
    )).thenAnswer(
      (_) => Future.value(
        FilePickerResult([
          PlatformFile(path: "test.jpg", name: "test.jpg", size: 100),
          PlatformFile(path: "test2.png", name: "test2.png", size: 100),
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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("DONE"), findsNothing);
  });

  testWidgets("Done button for multi picker", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
        actionText: "DONE",
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("DONE"), findsOneWidget);
  });

  testWidgets("Done button disabled when pick is required", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
        requiresPick: true,
        actionText: "DONE",
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(findFirstWithText<ActionButton>(tester, "DONE").onPressed, isNull);
  });

  testWidgets("Done button enabled when pick is not required", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
        requiresPick: false,
        actionText: "DONE",
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(
        findFirstWithText<ActionButton>(tester, "DONE").onPressed, isNotNull);
  });

  testWidgets("Done button invokes callback", (tester) async {
    var called = false;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) => called = true,
        requiresPick: false,
        actionText: "DONE",
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("DONE"));

    expect(called, isTrue);
  });

  testWidgets("Clear button clears selected for multi picker", (tester) async {
    var called = false;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) => called = true,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.byType(Image).last);
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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("CLEAR"));
    expect(called, isTrue);
  });

  testWidgets("X/Y label shows for multi picker", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    expect(find.text("0 / 0 Selected"), findsOneWidget);

    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.byType(Image).last);

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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    expect(called, isTrue);
  });

  testWidgets("Do not pop picker if popsOnFinish is false", (tester) async {
    var called = false;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) => called = true,
        popsOnFinish: false,
        actionText: "DONE",
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

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
    when(allAlbum.getAssetListPaged(
      page: anyNamed("page"),
      size: anyNamed("size"),
    )).thenAnswer((_) => Future.value([entity]));

    PickedImage? result;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage.single(
        onImagePicked: (_, image) => result = image,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    expect(result!.position, isNull);
    expect(entity.latLngAsyncCalls, 1);
  });

  testWidgets("Picked image with valid legacy coordinates", (tester) async {
    var entity = createMockAssetEntity(
      fileName: "android_logo.png",
      latLngAsync: null,
      latLngLegacy: const LatLng(latitude: 0.654321, longitude: 0.123456),
    );
    when(allAlbum.getAssetListPaged(
      page: anyNamed("page"),
      size: anyNamed("size"),
    )).thenAnswer((_) => Future.value([entity]));

    PickedImage? result;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage.single(
        onImagePicked: (_, image) => result = image,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    expect(result!.position, isNotNull);
    expect(entity.latLngAsyncCalls, 0);
  });

  testWidgets("Picked image with valid OS coordinates", (tester) async {
    var entity = createMockAssetEntity(
      fileName: "android_logo.png",
      latLngAsync: const LatLng(latitude: 0.654321, longitude: 0.123456),
      latLngLegacy: null,
    );
    when(allAlbum.getAssetListPaged(
      page: anyNamed("page"),
      size: anyNamed("size"),
    )).thenAnswer((_) => Future.value([entity]));

    PickedImage? result;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage.single(
        onImagePicked: (_, image) => result = image,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("OPEN SETTINGS"), findsOneWidget);
  });

  testWidgets("Pagination", (tester) async {
    // Stub many more assets than can be shown at once.
    when(allAlbum.assetCountAsync)
        .thenAnswer((_) => Future.value(mockAssets.length * 100));

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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Verify initial load.
    verify(allAlbum.getAssetListPaged(
      page: 0,
      size: anyNamed("size"),
    )).called(1);

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
    var gesture = await tester.startGesture(const Offset(0, 300));
    await gesture.moveBy(const Offset(0, -300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Verify another page load.
    verify(allAlbum.getAssetListPaged(
      page: 1,
      size: anyNamed("size"),
    )).called(1);

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
    gesture = await tester.startGesture(const Offset(0, 300));
    await gesture.moveBy(const Offset(0, -300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Verify another page load.
    verify(allAlbum.getAssetListPaged(
      page: 2,
      size: anyNamed("size"),
    )).called(1);
  });

  testWidgets("Loading widget shows in AppBar, then cleared", (tester) async {
    await pumpContext(
      tester,
      (context) => Button(
        text: "Test",
        onPressed: () => push(
          context,
          ImagePickerPage(
            onImagesPicked: (_, __) {},
          ),
        ),
      ),
      appManager: appManager,
    );
    await tapAndSettle(tester, find.text("TEST"));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(Image), findsNWidgets(4));

    // Stub image loading taking some time.
    mockAssets[0].originFileStub =
        Future.delayed(const Duration(milliseconds: 500), () => null);

    await tapAndSettle(tester, find.byType(Image).first);

    // Tap and pump once, so loading widget shows.
    await tester.tap(find.byType(BackButton));
    await tester.pump();

    expect(find.byType(Loading), findsOneWidget);
    expect(find.byType(ImagePickerPage), findsOneWidget);

    // Cancel loading by clearing the selection.
    await tester.tap(find.text("CLEAR"));
    await tester.pump();

    expect(find.byType(Loading), findsNothing);

    // Ensure stubbed future above finishes before test ends.
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets("Multi-picker with no action", (tester) async {
    await pumpContext(
      tester,
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
        actionText: null,
      ),
      appManager: appManager,
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // The only action button is the CLEAR button.
    expect(find.widgetWithText(ActionButton, "CLEAR"), findsOneWidget);
    expect(find.byType(ActionButton), findsOneWidget);
  });

  testWidgets("Error shown for single picker", (tester) async {
    await pumpContext(
      tester,
      (context) => Scaffold(
        body: Button(
          text: "Test",
          onPressed: () => push(
            context,
            ImagePickerPage.single(
              onImagePicked: (_, __) {},
            ),
          ),
        ),
      ),
      appManager: appManager,
    );
    await tapAndSettle(tester, find.text("TEST"));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(Image), findsNWidgets(4));

    // Stub invalid origin image.
    mockAssets[0].originFileStub = Future.value(null);

    // Select photo and wait for SnackBar to show.
    await tapAndSettle(tester, find.byType(Image).first);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.substring("Failed to attach photo"), findsOneWidget);
  });

  testWidgets("Error shown for multi-picker", (tester) async {
    await pumpContext(
      tester,
      (context) => Scaffold(
        body: Button(
          text: "Test",
          onPressed: () => push(
            context,
            ImagePickerPage(
              onImagesPicked: (_, __) {},
              allowsMultipleSelection: true,
            ),
          ),
        ),
      ),
      appManager: appManager,
    );
    await tapAndSettle(tester, find.text("TEST"));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(Image), findsNWidgets(4));

    // Stub invalid origin image.
    mockAssets[0].originFileStub = Future.value(null);

    // Select photo and wait for SnackBar to show.
    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.byType(BackButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.substring("Failed to attach one or more photos"),
      findsOneWidget,
    );
  });

  testWidgets(
      "Loading cancelled when user navigates back when popsOnFinish=false",
      (tester) async {
    await pumpContext(
      tester,
      (context) => ImagePickerPage(
        onImagesPicked: (_, __) {},
        popsOnFinish: false,
        actionText: "NEXT",
      ),
      appManager: appManager,
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Stub image loading taking some time.
    mockAssets[0].originFileStub =
        Future.delayed(const Duration(milliseconds: 500), () => null);

    // Navigate to the "next" page.
    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.text("NEXT"));

    // Verify loading widget is not shown.
    expect(find.byType(Loading), findsNothing);

    // Ensure stubbed future above finishes before test ends.
    await tester.pump(const Duration(milliseconds: 500));
  });
}
