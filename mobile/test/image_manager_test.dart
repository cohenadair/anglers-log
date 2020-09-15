import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/image_manager.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

class MockDirectory extends Mock implements Directory {}
class MockFile extends Mock implements File {}
class MockImageManagerDelegate extends Mock implements ImageManagerDelegate {}

const _imagePath = "test/tmp_image";
const _cachePath = "test/tmp_cache";

void main() {
  MockAppManager appManager;
  MockDirectory directory;
  MockImageManagerDelegate imageManagerDelegate;

  ImageManager imageManager;

  setUp(() async {
    appManager = MockAppManager(
      mockCatchManager: true,
    );

    when(appManager.mockCatchManager.list()).thenReturn([]);

    directory = MockDirectory();
    when(directory.list()).thenAnswer((_) => Stream.empty());

    imageManagerDelegate = MockImageManagerDelegate();
    when(imageManagerDelegate.imagePath).thenReturn(_imagePath);
    when(imageManagerDelegate.cachePath).thenReturn(_cachePath);
    when(imageManagerDelegate.directory(any)).thenReturn(directory);
    when(imageManagerDelegate.file(any)).thenReturn(MockFile());
    when(imageManagerDelegate.compress(any, any, any)).thenAnswer((_) =>
        Future.value(Uint8List.fromList([10, 11, 12])));

    imageManager = ImageManager(appManager);
  });

  testWidgets("Invalid fileName input to image method", (WidgetTester tester)
      async
  {
    await imageManager.initialize(delegate: imageManagerDelegate);
    BuildContext context = await buildContext(tester);

    // Empty/null.
    expect(await imageManager.image(context, fileName: null), isNull);

    var img = MockFile();
    when(img.exists()).thenAnswer((_) => Future.value(false));
    when(imageManagerDelegate.file(any)).thenReturn(img);

    // File doesn't exist.
    expect(await imageManager.image(context,
      fileName: "file_name",
      size: null,
    ), isNull);
  });

  testWidgets("Error getting thumbnail returns full image",
      (WidgetTester tester) async
  {
    await imageManager.initialize(delegate: imageManagerDelegate);
    BuildContext context = await buildContext(tester);

    File img = MockFile();
    when(img.exists()).thenAnswer((_) => Future.value(true));
    when(img.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([1, 2, 3])));
    when(imageManagerDelegate.file(any)).thenReturn(img);

    // Empty/null.
    Uint8List bytes = await imageManager.image(context,
      fileName: "image.jpg",
      size: null, // Will cause _thumbnail method to return null.
    );
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));
  });

  testWidgets("Thumbnail cache", (WidgetTester tester) async {
    await imageManager.initialize(delegate: imageManagerDelegate);

    // Clear call counts.
    verify(imageManagerDelegate.cachePath).called(1);
    verify(imageManagerDelegate.imagePath).called(2);

    BuildContext context = await buildContext(tester);

    var img = MockFile();
    when(img.exists()).thenAnswer((_) => Future.value(true));
    when(img.writeAsBytes(any)).thenAnswer((_) => Future.value(img));
    when(img.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([1, 2, 3])));
    when(imageManagerDelegate.file("$_imagePath/image.jpg")).thenReturn(img);

    var thumb = MockFile();
    when(thumb.exists()).thenAnswer((_) => Future.value(false));
    when(thumb.writeAsBytes(any)).thenAnswer((_) => Future.value(thumb));
    when(thumb.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([1, 2, 3])));
    when(imageManagerDelegate.file("$_cachePath/50/image.jpg"))
        .thenReturn(thumb);

    // Cache does not include image; image should be compressed.
    Uint8List bytes = await imageManager.image(context,
      fileName: "image.jpg",
      size: 50,
    );
    verify(imageManagerDelegate.cachePath).called(1);
    verify(imageManagerDelegate.compress(any, any, any)).called(1);
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));

    // Cache now includes image in memory, verify the cache version is used.
    bytes = await imageManager.image(context,
      fileName: "image.jpg",
      size: 50,
    );
    verifyNever(imageManagerDelegate.cachePath);
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));

    // Clear memory cache and verify file cache is used.
    imageManager.clearMemoryCache(["image.jpg"]);

    // Ensure thumbnail exists.
    when(thumb.exists()).thenAnswer((_) => Future.value(true));

    bytes = await imageManager.image(context,
      fileName: "image.jpg",
      size: 50,
    );
    verify(imageManagerDelegate.cachePath).called(1);
    verifyNever(imageManagerDelegate.compress(any, any, any));
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));
  });

  testWidgets("Get images", (WidgetTester tester) async {
    await imageManager.initialize(delegate: imageManagerDelegate);
    BuildContext context = await buildContext(tester);

    // Invalid input.
    expect(await imageManager.images(context,
      imageNames: null,
      size: null,
    ), isEmpty);
    expect(await imageManager.images(context,
      imageNames: [],
      size: null,
    ), isEmpty);

    // One thumbnail doesn't exist or encountered an error.
    File img0 = MockFile();
    when(img0.exists()).thenAnswer((_) => Future.value(true));
    when(img0.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([1, 2, 3])));
    when(imageManagerDelegate.file("$_imagePath/image0.jpg")).thenReturn(img0);

    File img1 = MockFile();
    when(img1.exists()).thenAnswer((_) => Future.value(false));
    when(img1.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([3, 2, 1])));
    when(imageManagerDelegate.file("$_imagePath/image1.jpg")).thenReturn(img1);

    List<Uint8List> byteList = await imageManager.images(context,
        imageNames: ["image0.jpg", "image1.jpg"]);
    expect(byteList, isNotNull);
    expect(byteList.length, 1);

    // All thumbnails exist (normal case).
    when(img1.exists()).thenAnswer((_) => Future.value(true));
    when(img0.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([3, 2, 1])));

    byteList = await imageManager.images(context,
        imageNames: ["image0.jpg", "image1.jpg"]);
    expect(byteList, isNotNull);
    expect(byteList.length, 2);

    // No thumbnails exist.
    when(img0.exists()).thenAnswer((_) => Future.value(false));
    when(img1.exists()).thenAnswer((_) => Future.value(false));

    byteList = await imageManager.images(context,
        imageNames: ["image0.jpg", "image1.jpg"]);
    expect(byteList, isNotNull);
    expect(byteList.isEmpty, true);
  });

  test("Normal saving images", () async {
    await imageManager.initialize(delegate: imageManagerDelegate);

    // Verify there no images are saved.
    await imageManager.save([]);
    verifyNever(imageManagerDelegate.compress(any, any, any));

    // Add some images.
    var img0 = MockFile();
    when(img0.path).thenReturn("image0.jpg");
    when(img0.exists()).thenAnswer((_) => Future.value(true));
    when(img0.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([1, 2, 3])));
    when(imageManagerDelegate.compress("image0.jpg", any, any))
        .thenAnswer((_) => img0.readAsBytes());

    var img1 = MockFile();
    when(img1.path).thenReturn("image1.jpg");
    when(img1.exists()).thenAnswer((_) => Future.value(true));
    when(img1.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([3, 2, 1])));
    when(imageManagerDelegate.compress("image1.jpg", any, any))
        .thenAnswer((_) => img1.readAsBytes());

    List<MockFile> addedImages = [];
    when(imageManagerDelegate.file(any)).thenAnswer((invocation) {
      var newFile = MockFile();
      when(newFile.path).thenReturn(invocation.positionalArguments.first);
      when(newFile.exists()).thenAnswer((_) => Future.value(false));
      when(newFile.writeAsBytes(any)).thenAnswer((_) => Future.value(newFile));
      addedImages.add(newFile);
      return newFile;
    });

    await imageManager.save([img0, img1]);
    expect(addedImages.length, 2);
    addedImages.forEach((img) {
      verify(img.writeAsBytes(any, flush: true)).called(1);
    });
    verify(imageManagerDelegate.compress(any, any, any)).called(2);
  });

  test("Null image files are skipped when saving", () async {
    await imageManager.save([null, null]);
    verifyNever(imageManagerDelegate.compress(any, any, any));
  });

  test("Saving an empty list does nothing", () async {
    // TODO: Test that this actually works
    try {
      await imageManager.save([]);
      await imageManager.save(null);
    } catch (e) {
      fail("Invalid input should be handled gracefully");
    }
  });

  test("Saving an image that exists at the same path uses the existing image",
      () async
  {
    var img0 = MockFile();
    when(img0.path).thenReturn("$_imagePath/image.jpg");
    when(img0.exists()).thenAnswer((_) => Future.value(true));
    when(imageManagerDelegate.file(any)).thenReturn(img0);

    var img1 = MockFile();
    when(img1.path).thenReturn("$_imagePath/image.jpg");
    when(img1.exists()).thenAnswer((_) => Future.value(true));

    await imageManager.initialize(delegate: imageManagerDelegate);
    await imageManager.save([img1]);
    verifyNever(imageManagerDelegate.compress(any, any, any));
  });

  // TODO: Verify result of save method
  // TODO: Test stale images are deleted
}