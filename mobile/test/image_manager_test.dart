import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/image_manager.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.dart';
import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';

const _imagePath = "test/tmp_image";
const _cachePath = "test/tmp_cache";

void main() {
  late StubbedAppManager appManager;

  late ImageManager imageManager;

  setUp(() async {
    appManager = StubbedAppManager();

    when(appManager.catchManager.list()).thenReturn([]);

    var directory = MockDirectory();
    when(directory.create(recursive: anyNamed("recursive")))
        .thenAnswer((realInvocation) => Future.value(directory));
    when(directory.list()).thenAnswer((_) => const Stream.empty());

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    when(appManager.imageCompressWrapper.compress(any, any, any))
        .thenAnswer((_) => Future.value(Uint8List.fromList([10, 11, 12])));

    when(appManager.ioWrapper.directory(any)).thenReturn(directory);
    when(appManager.ioWrapper.file(any)).thenReturn(MockFile());

    when(appManager.pathProviderWrapper.appDocumentsPath)
        .thenAnswer((_) => Future.value(_imagePath));
    when(appManager.pathProviderWrapper.temporaryPath)
        .thenAnswer((_) => Future.value(_cachePath));

    imageManager = ImageManager(appManager.app);
    await imageManager.initialize();
    verify(appManager.ioWrapper.directory(any)).called(2);
  });

  testWidgets("Invalid fileName input to image method", (tester) async {
    // Empty/null.
    expect(await imageManager.image(fileName: ""), isNull);

    var img = MockFile();
    when(img.exists()).thenAnswer((_) => Future.value(false));
    when(appManager.ioWrapper.file(any)).thenReturn(img);

    // File doesn't exist.
    expect(
      await imageManager.image(fileName: "file_name"),
      isNull,
    );
  });

  testWidgets("Error getting thumbnail returns full image", (tester) async {
    File img = MockFile();
    when(img.exists()).thenAnswer((_) => Future.value(true));
    when(img.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([1, 2, 3])));
    when(appManager.ioWrapper.file(any)).thenReturn(img);

    // Empty/null.
    var bytes = await imageManager.image(
      fileName: "image.jpg",
      size: null, // Will cause _thumbnail method to return null.
    );
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));
  });

  testWidgets("Thumbnail cache", (tester) async {
    var img = MockFile();
    when(img.path).thenReturn("$_imagePath/2.0/images/image.jpg");
    when(img.exists()).thenAnswer((_) => Future.value(true));
    when(img.writeAsBytes(any)).thenAnswer((_) => Future.value(img));
    when(img.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([1, 2, 3])));
    when(appManager.ioWrapper.file("$_imagePath/2.0/images/image.jpg"))
        .thenReturn(img);

    var thumb = MockFile();
    when(img.path).thenReturn("$_cachePath/2.0/thumbs/50/image.jpg");
    when(thumb.exists()).thenAnswer((_) => Future.value(false));
    when(thumb.writeAsBytes(any, flush: anyNamed("flush")))
        .thenAnswer((_) => Future.value(thumb));
    when(thumb.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([1, 2, 3])));
    when(appManager.ioWrapper.file("$_cachePath/2.0/thumbs/50/image.jpg"))
        .thenReturn(thumb);

    // Cache does not include image; image should be compressed.
    var bytes = await imageManager.image(
      fileName: "image.jpg",
      size: 50,
    );
    verify(appManager.ioWrapper.directory(any)).called(1);
    verify(appManager.imageCompressWrapper.compress(any, any, any)).called(1);
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));

    // Cache now includes image in memory, verify the cache version is used.
    bytes = await imageManager.image(
      fileName: "image.jpg",
      size: 50,
    );
    verifyNever(appManager.ioWrapper.directory(any));
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));

    // Clear memory cache by reinitializing manager.
    imageManager.initialize();

    // Ensure thumbnail exists.
    when(thumb.exists()).thenAnswer((_) => Future.value(true));

    bytes = await imageManager.image(
      fileName: "image.jpg",
      size: 50,
    );
    verify(appManager.ioWrapper.file("$_cachePath/2.0/thumbs/50/image.jpg"))
        .called(1);
    verifyNever(appManager.imageCompressWrapper.compress(any, any, any));
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));
  });

  testWidgets("Thumbnail can't be created when file doesn't exist",
      (tester) async {
    var file = MockFile();
    when(file.exists()).thenAnswer((_) => Future.value(false));
    when(appManager.ioWrapper.file("$_imagePath/2.0/images/image.jpg"))
        .thenReturn(file);

    var thumb = MockFile();
    when(thumb.exists()).thenAnswer((_) => Future.value(false));
    when(appManager.ioWrapper.file("$_cachePath/2.0/thumbs/50/image.jpg"))
        .thenReturn(thumb);

    await imageManager.image(
      fileName: "image.jpg",
      size: 50,
    );

    verifyNever(thumb.writeAsBytes(any));
  });

  testWidgets("Get images", (tester) async {
    // Invalid input.
    expect(
      await imageManager.images(
        imageNames: [],
        size: null,
      ),
      isEmpty,
    );

    // One thumbnail doesn't exist or encountered an error.
    File img0 = MockFile();
    when(img0.exists()).thenAnswer((_) => Future.value(true));
    when(img0.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([1, 2, 3])));
    when(img0.hashCode).thenReturn(0);
    when(appManager.ioWrapper.file("$_imagePath/2.0/images/image0.jpg"))
        .thenReturn(img0);

    File img1 = MockFile();
    when(img1.exists()).thenAnswer((_) => Future.value(false));
    when(img1.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([3, 2, 1])));
    when(img1.hashCode).thenReturn(1);
    when(appManager.ioWrapper.file("$_imagePath/2.0/images/image1.jpg"))
        .thenReturn(img1);

    var images =
        await imageManager.images(imageNames: ["image0.jpg", "image1.jpg"]);
    expect(images.length, 1);

    // All thumbnails exist (normal case).
    when(img1.exists()).thenAnswer((_) => Future.value(true));
    when(img0.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([3, 2, 1])));

    images =
        await imageManager.images(imageNames: ["image0.jpg", "image1.jpg"]);
    expect(images.length, 2);

    // No thumbnails exist.
    when(img0.exists()).thenAnswer((_) => Future.value(false));
    when(img1.exists()).thenAnswer((_) => Future.value(false));

    images =
        await imageManager.images(imageNames: ["image0.jpg", "image1.jpg"]);
    expect(images.isEmpty, isTrue);
  });

  test("Normal saving images", () async {
    // Verify there no images are saved.
    expect(await imageManager.save([]), isEmpty);
    verifyNever(appManager.imageCompressWrapper.compress(any, any, any));

    // Add some images.
    var img0 = MockFile();
    when(img0.path).thenReturn("image0.jpg");
    when(img0.exists()).thenAnswer((_) => Future.value(true));
    when(img0.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([1, 2, 3])));
    when(img0.writeAsBytes(any, flush: anyNamed("flush")))
        .thenAnswer((_) => Future.value(img0));
    when(appManager.imageCompressWrapper.compress("image0.jpg", any, any))
        .thenAnswer((_) => img0.readAsBytes());

    var img1 = MockFile();
    when(img1.path).thenReturn("image1.jpg");
    when(img1.exists()).thenAnswer((_) => Future.value(true));
    when(img1.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([3, 2, 1])));
    when(img1.writeAsBytes(any, flush: anyNamed("flush")))
        .thenAnswer((_) => Future.value(img1));
    when(appManager.imageCompressWrapper.compress("image1.jpg", any, any))
        .thenAnswer((_) => img1.readAsBytes());

    var addedImages = <MockFile>[];
    when(appManager.ioWrapper.file(any)).thenAnswer((invocation) {
      var newFile = MockFile();
      when(newFile.path).thenReturn(invocation.positionalArguments.first);
      when(newFile.exists()).thenAnswer((_) => Future.value(false));
      when(newFile.writeAsBytes(any, flush: anyNamed("flush")))
          .thenAnswer((_) => Future.value(newFile));
      addedImages.add(newFile);
      return newFile;
    });

    expect((await imageManager.save([img0, img1])).length, 2);
    expect(addedImages.length, 2);
    for (var img in addedImages) {
      verify(img.writeAsBytes(any, flush: true)).called(1);
    }
    verify(appManager.imageCompressWrapper.compress(any, any, any)).called(2);
  });

  test("Saving an empty list does nothing", () async {
    try {
      expect(await imageManager.save([]), isEmpty);
    } on Exception catch (_) {
      fail("Invalid input should be handled gracefully");
    }
  });

  test("Saving an image that exists at the same path uses the existing image",
      () async {
    var img0 = MockFile();
    when(img0.path).thenReturn("$_imagePath/2.0/images/image.jpg");
    when(img0.exists()).thenAnswer((_) => Future.value(true));
    when(appManager.ioWrapper.file(any)).thenReturn(img0);

    var img1 = MockFile();
    when(img1.path).thenReturn("$_imagePath/2.0/images/image.jpg");
    when(img1.exists()).thenAnswer((_) => Future.value(true));

    await imageManager.initialize();
    var images = await imageManager.save([img1]);
    expect(images.length, 1);
    expect(images.first, "image.jpg");
    verifyNever(appManager.imageCompressWrapper.compress(any, any, any));
  });

  test("Writing file that already exists exits early", () async {
    var img0 = MockFile();
    when(img0.path).thenReturn("$_imagePath/2.0/images/image.jpg");
    when(img0.exists()).thenAnswer((_) => Future.value(true));
    when(appManager.ioWrapper.file(any)).thenReturn(img0);

    await imageManager.saveImageBytes(Uint8List(0), "dummy");
    verifyNever(img0.writeAsBytes(any, flush: anyNamed("flush")));
  });

  test("Writing file throws exception", () async {
    var img0 = MockFile();
    when(img0.path).thenReturn("$_imagePath/2.0/images/image.jpg");
    when(img0.exists()).thenAnswer((_) => Future.value(false));
    when(img0.writeAsBytes(any, flush: anyNamed("flush")))
        .thenThrow(const FileSystemException());
    when(appManager.ioWrapper.file(any)).thenReturn(img0);

    expect(await imageManager.saveImageBytes(Uint8List(0), "dummy"), isFalse);
  });
}
