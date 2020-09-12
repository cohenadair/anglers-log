import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/image_manager.dart';
import 'package:mockito/mockito.dart';

import 'test_utils.dart';

class MockDirectory extends Mock implements Directory {}
class MockFile extends Mock implements File {}
class MockImageManagerDelegate extends Mock implements ImageManagerDelegate {}

const _imagePath = "test/tmp_image";
const _cachePath = "test/tmp_cache";

void main() {
  MockImageManagerDelegate _imageManagerDelegate;

  ImageManager _imageManager;

  setUp(() async {
    _imageManagerDelegate = MockImageManagerDelegate();
    when(_imageManagerDelegate.imagePath).thenReturn(_imagePath);
    when(_imageManagerDelegate.cachePath).thenReturn(_cachePath);
    when(_imageManagerDelegate.directory(any)).thenReturn(MockDirectory());
    when(_imageManagerDelegate.file(any)).thenReturn(MockFile());
    when(_imageManagerDelegate.compress(any, any, any)).thenAnswer((_) =>
        Future.value(Uint8List.fromList([10, 11, 12])));

    _imageManager = ImageManager();
  });

  testWidgets("Invalid fileName input to image method", (WidgetTester tester)
      async
  {
    await _imageManager.initialize(delegate: _imageManagerDelegate);
    BuildContext context = await buildContext(tester);

    // Empty/null.
    expect(await _imageManager.image(context, fileName: null), isNull);

    var img = MockFile();
    when(img.exists()).thenAnswer((_) => Future.value(false));
    when(_imageManagerDelegate.file(any)).thenReturn(img);

    // File doesn't exist.
    expect(await _imageManager.image(context,
      fileName: "file_name",
      size: null,
    ), isNull);
  });

  testWidgets("Error getting thumbnail returns full image",
      (WidgetTester tester) async
  {
    await _imageManager.initialize(delegate: _imageManagerDelegate);
    BuildContext context = await buildContext(tester);

    File img = MockFile();
    when(img.exists()).thenAnswer((_) => Future.value(true));
    when(img.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([1, 2, 3])));
    when(_imageManagerDelegate.file(any)).thenReturn(img);

    // Empty/null.
    Uint8List bytes = await _imageManager.image(context,
      fileName: "image.jpg",
      size: null, // Will cause _thumbnail method to return null.
    );
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));
  });

  testWidgets("Thumbnail cache", (WidgetTester tester) async {
    await _imageManager.initialize(delegate: _imageManagerDelegate);

    // Clear call counts.
    verify(_imageManagerDelegate.cachePath).called(1);
    verify(_imageManagerDelegate.imagePath).called(1);

    BuildContext context = await buildContext(tester);

    var img = MockFile();
    when(img.exists()).thenAnswer((_) => Future.value(true));
    when(img.writeAsBytes(any)).thenAnswer((_) => Future.value(img));
    when(img.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([1, 2, 3])));
    when(_imageManagerDelegate.file("$_imagePath/image.jpg")).thenReturn(img);

    var thumb = MockFile();
    when(thumb.exists()).thenAnswer((_) => Future.value(false));
    when(thumb.writeAsBytes(any)).thenAnswer((_) => Future.value(thumb));
    when(thumb.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([1, 2, 3])));
    when(_imageManagerDelegate.file("$_cachePath/50/image.jpg"))
        .thenReturn(thumb);

    // Cache does not include image; image should be compressed.
    Uint8List bytes = await _imageManager.image(context,
      fileName: "image.jpg",
      size: 50,
    );
    verify(_imageManagerDelegate.cachePath).called(1);
    verify(_imageManagerDelegate.compress(any, any, any)).called(1);
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));

    // Cache now includes image in memory, verify the cache version is used.
    bytes = await _imageManager.image(context,
      fileName: "image.jpg",
      size: 50,
    );
    verifyNever(_imageManagerDelegate.cachePath);
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));

    // Clear memory cache and verify file cache is used.
    _imageManager.clearMemoryCache(["image.jpg"]);

    // Ensure thumbnail exists.
    when(thumb.exists()).thenAnswer((_) => Future.value(true));

    bytes = await _imageManager.image(context,
      fileName: "image.jpg",
      size: 50,
    );
    verify(_imageManagerDelegate.cachePath).called(1);
    verifyNever(_imageManagerDelegate.compress(any, any, any));
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));
  });

  testWidgets("Get images", (WidgetTester tester) async {
    await _imageManager.initialize(delegate: _imageManagerDelegate);
    BuildContext context = await buildContext(tester);

    // Invalid input.
    expect(await _imageManager.images(context,
      imageNames: null,
      size: null,
    ), isEmpty);
    expect(await _imageManager.images(context,
      imageNames: [],
      size: null,
    ), isEmpty);

    // One thumbnail doesn't exist or encountered an error.
    File img0 = MockFile();
    when(img0.exists()).thenAnswer((_) => Future.value(true));
    when(img0.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([1, 2, 3])));
    when(_imageManagerDelegate.file("$_imagePath/image0.jpg")).thenReturn(img0);

    File img1 = MockFile();
    when(img1.exists()).thenAnswer((_) => Future.value(false));
    when(img1.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([3, 2, 1])));
    when(_imageManagerDelegate.file("$_imagePath/image1.jpg")).thenReturn(img1);

    List<Uint8List> byteList = await _imageManager.images(context,
        imageNames: ["image0.jpg", "image1.jpg"]);
    expect(byteList, isNotNull);
    expect(byteList.length, 1);

    // All thumbnails exist (normal case).
    when(img1.exists()).thenAnswer((_) => Future.value(true));
    when(img0.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([3, 2, 1])));

    byteList = await _imageManager.images(context,
        imageNames: ["image0.jpg", "image1.jpg"]);
    expect(byteList, isNotNull);
    expect(byteList.length, 2);

    // No thumbnails exist.
    when(img0.exists()).thenAnswer((_) => Future.value(false));
    when(img1.exists()).thenAnswer((_) => Future.value(false));

    byteList = await _imageManager.images(context,
        imageNames: ["image0.jpg", "image1.jpg"]);
    expect(byteList, isNotNull);
    expect(byteList.isEmpty, true);
  });

  test("Normal saving images", () async {
    await _imageManager.initialize(delegate: _imageManagerDelegate);

    // Verify there no images are saved.
    await _imageManager.save([]);
    verifyNever(_imageManagerDelegate.compress(any, any, any));

    // Add some images.
    var img0 = MockFile();
    when(img0.path).thenReturn("image0.jpg");
    when(img0.exists()).thenAnswer((_) => Future.value(true));
    when(img0.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([1, 2, 3])));
    when(_imageManagerDelegate.compress("image0.jpg", any, any))
        .thenAnswer((_) => img0.readAsBytes());

    var img1 = MockFile();
    when(img1.path).thenReturn("image1.jpg");
    when(img1.exists()).thenAnswer((_) => Future.value(true));
    when(img1.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([3, 2, 1])));
    when(_imageManagerDelegate.compress("image1.jpg", any, any))
        .thenAnswer((_) => img1.readAsBytes());

    List<MockFile> addedImages = [];
    when(_imageManagerDelegate.file(any)).thenAnswer((invocation) {
      var newFile = MockFile();
      when(newFile.path).thenReturn(invocation.positionalArguments.first);
      when(newFile.exists()).thenAnswer((_) => Future.value(false));
      when(newFile.writeAsBytes(any)).thenAnswer((_) => Future.value(newFile));
      addedImages.add(newFile);
      return newFile;
    });

    await _imageManager.save([img0, img1]);
    expect(addedImages.length, 2);
    addedImages.forEach((img) {
      verify(img.writeAsBytes(any, flush: true)).called(1);
    });
    verify(_imageManagerDelegate.compress(any, any, any)).called(2);
  });

  test("Null image files are skipped when saving", () async {
    await _imageManager.save([null, null]);
    verifyNever(_imageManagerDelegate.compress(any, any, any));
  });

  test("Saving an empty list does nothing", () async {
    // TODO: Test that this actually works
    try {
      await _imageManager.save([]);
      await _imageManager.save(null);
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
    when(_imageManagerDelegate.file(any)).thenReturn(img0);

    var img1 = MockFile();
    when(img1.path).thenReturn("$_imagePath/image.jpg");
    when(img1.exists()).thenAnswer((_) => Future.value(true));

    await _imageManager.initialize(delegate: _imageManagerDelegate);
    await _imageManager.save([img1]);
    verifyNever(_imageManagerDelegate.compress(any, any, any));
  });
}