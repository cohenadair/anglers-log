import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/no_results.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_manager/photo_manager.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;
  MockAssetPathEntity allAlbum;

  setUp(() {
    appManager = MockAppManager(
      mockFilePickerWrapper: true,
      mockImagePickerWrapper: true,
      mockPhotoManagerWrapper: true,
    );

    allAlbum = MockAssetPathEntity();
    when(allAlbum.isAll).thenReturn(true);
    when(allAlbum.assetList).thenAnswer(
      (_) => Future.value([
        createMockAssetEntity(fileName: "android_logo.png"),
        createMockAssetEntity(fileName: "anglers_log_logo.png"),
        createMockAssetEntity(fileName: "apple_logo.png"),
        createMockAssetEntity(fileName: "flutter_logo.png"),
      ]),
    );
    when(appManager.mockPhotoManagerWrapper.getAssetPathList(any))
        .thenAnswer((_) => Future.value([allAlbum]));
  });

  testWidgets("No device photos empty result", (tester) async {
    when(appManager.mockPhotoManagerWrapper.getAssetPathList(any))
        .thenAnswer((_) => Future.value([]));

    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.byType(NoResults), findsOneWidget);
  });

  testWidgets("No device photos empty all album", (tester) async {
    when(allAlbum.assetList).thenAnswer((_) => Future.value([]));
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.byType(NoResults), findsOneWidget);
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

    verify(appManager.mockImagePickerWrapper.pickImage(any)).called(1);
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

    when(appManager.mockImagePickerWrapper.pickImage(any))
        .thenAnswer((_) => Future.value(File("")));

    await tapAndSettle(tester, find.text("Gallery"));
    await tapAndSettle(tester, find.text("Camera").last);

    verify(appManager.mockImagePickerWrapper.pickImage(any)).called(1);
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

    when(appManager.mockFilePickerWrapper.getFile(type: anyNamed("type")))
        .thenAnswer((_) => Future.value(null));

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

    when(appManager.mockFilePickerWrapper.getMultiFile(any))
        .thenAnswer((_) => Future.value(null));

    await tapAndSettle(tester, find.text("Gallery"));
    await tapAndSettle(tester, find.text("Browse").last);

    expect(called, isFalse);
    expect(find.text("Must select an image file."), findsNothing);
    expect(find.text("Must select image files."), findsNothing);

    when(appManager.mockFilePickerWrapper.getMultiFile(any))
        .thenAnswer((_) => Future.value([]));

    await tapAndSettle(tester, find.text("Gallery"));
    await tapAndSettle(tester, find.text("Browse").last);

    expect(called, isFalse);
    expect(find.text("Must select an image file."), findsNothing);
    expect(find.text("Must select image files."), findsNothing);
  });

  testWidgets("Doc single picker unsupported format",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage.single(
        onImagePicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    when(appManager.mockFilePickerWrapper.getFile(type: anyNamed("type")))
        .thenAnswer((_) => Future.value(File("file.invalid")));

    await tapAndSettle(tester, find.text("Gallery"));
    await tapAndSettle(tester, find.text("Browse").last);

    expect(find.text("Must select an image file."), findsOneWidget);
  });

  testWidgets("Doc multi picker unsupported format",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    when(appManager.mockFilePickerWrapper.getMultiFile(any)).thenAnswer(
      (_) => Future.value([
        File("test.invalid"),
        File("test2.invalid"),
      ]),
    );

    await tapAndSettle(tester, find.text("Gallery"));
    await tapAndSettle(tester, find.text("Browse").last);

    expect(find.text("Must select image files."), findsOneWidget);
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

    when(appManager.mockFilePickerWrapper.getMultiFile(any)).thenAnswer(
      (_) => Future.value([
        File("test.jpg"),
        File("test2.png"),
      ]),
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

  testWidgets("Done button disabled when pick is required",
      (tester) async {
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

  testWidgets("Done button enabled when pick is not required",
      (tester) async {
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

  testWidgets("Do not pop picker if popsOnFinish is false",
      (tester) async {
    var navObserver = MockNavigatorObserver();
    var called = false;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage(
        onImagesPicked: (_, __) => called = true,
        popsOnFinish: false,
      ),
      appManager: appManager,
      navigatorObserver: navObserver,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.text("DONE"));
    expect(called, isTrue);
    verifyNever(navObserver.didPop(any, any));
  });

  testWidgets("Picked image with invalid coordinates", (tester) async {
    var entity = createMockAssetEntity(
      fileName: "android_logo.png",
      latLngAsync: null,
      latLngLegacy: null,
    );
    when(allAlbum.assetList).thenAnswer(
      (_) => Future.value([
        entity,
      ]),
    );

    PickedImage result;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage.single(
        onImagePicked: (_, image) => result = image,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    expect(result.position, isNull);
    verify(entity.latlngAsync()).called(1);
  });

  testWidgets("Picked image with valid legacy coordinates", (tester) async {
    var entity = createMockAssetEntity(
      fileName: "android_logo.png",
      latLngAsync: null,
      latLngLegacy: LatLng()
        ..latitude = 0.654321
        ..longitude = 0.123456,
    );
    when(allAlbum.assetList).thenAnswer(
      (_) => Future.value([
        entity,
      ]),
    );

    PickedImage result;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage.single(
        onImagePicked: (_, image) => result = image,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    expect(result.position, isNotNull);
    verifyNever(entity.latlngAsync());
  });

  testWidgets("Picked image with valid OS coordinates", (tester) async {
    var entity = createMockAssetEntity(
      fileName: "android_logo.png",
      latLngAsync: LatLng()
        ..latitude = 0.654321
        ..longitude = 0.123456,
      latLngLegacy: null,
    );
    when(allAlbum.assetList).thenAnswer(
      (_) => Future.value([
        entity,
      ]),
    );

    PickedImage result;
    await tester.pumpWidget(Testable(
      (_) => ImagePickerPage.single(
        onImagePicked: (_, image) => result = image,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    expect(result.position, isNotNull);
    verify(entity.latlngAsync()).called(1);
  });
}
