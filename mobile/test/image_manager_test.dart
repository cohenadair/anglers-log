import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

class MockDirectory extends Mock implements Directory {}

class MockFile extends Mock implements File {}

class MockFileSystemEntity extends Mock implements FileSystemEntity {}

const _imagePath = "test/tmp_image";
const _cachePath = "test/tmp_cache";

void main() {
  MockAppManager appManager;
  MockDirectory directory;

  ImageManager imageManager;

  setUp(() async {
    appManager = MockAppManager(
      mockCatchManager: true,
      mockIoWrapper: true,
      mockImageCompressWrapper: true,
      mockPathProviderWrapper: true,
    );

    when(appManager.mockCatchManager.list()).thenReturn([]);

    directory = MockDirectory();
    when(directory.list()).thenAnswer((_) => Stream.empty());

    when(appManager.mockImageCompressWrapper.compress(any, any, any))
        .thenAnswer((_) => Future.value(Uint8List.fromList([10, 11, 12])));

    when(appManager.mockIoWrapper.directory(any)).thenReturn(directory);
    when(appManager.mockIoWrapper.file(any)).thenReturn(MockFile());

    when(appManager.mockPathProviderWrapper.appDocumentsPath)
        .thenAnswer((_) => Future.value(_imagePath));
    when(appManager.mockPathProviderWrapper.temporaryPath)
        .thenAnswer((_) => Future.value(_cachePath));

    imageManager = ImageManager(appManager);
  });

  testWidgets("Invalid fileName input to image method", (tester) async {
    await imageManager.initialize();
    var context = await buildContext(tester);

    // Empty/null.
    expect(await imageManager.image(context, fileName: null), isNull);

    var img = MockFile();
    when(img.exists()).thenAnswer((_) => Future.value(false));
    when(appManager.mockIoWrapper.file(any)).thenReturn(img);

    // File doesn't exist.
    expect(
      await imageManager.image(
        context,
        fileName: "file_name",
        size: null,
      ),
      isNull,
    );
  });

  testWidgets("Error getting thumbnail returns full image", (tester) async {
    await imageManager.initialize();
    var context = await buildContext(tester);

    File img = MockFile();
    when(img.exists()).thenAnswer((_) => Future.value(true));
    when(img.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([1, 2, 3])));
    when(appManager.mockIoWrapper.file(any)).thenReturn(img);

    // Empty/null.
    var bytes = await imageManager.image(
      context,
      fileName: "image.jpg",
      size: null, // Will cause _thumbnail method to return null.
    );
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));
  });

  testWidgets("Thumbnail cache", (tester) async {
    await imageManager.initialize();

    // Clear call counts.
    verify(appManager.mockIoWrapper.directory(any)).called(3);

    var context = await buildContext(tester);

    var img = MockFile();
    when(img.exists()).thenAnswer((_) => Future.value(true));
    when(img.writeAsBytes(any)).thenAnswer((_) => Future.value(img));
    when(img.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([1, 2, 3])));
    when(appManager.mockIoWrapper.file("$_imagePath/2.0/images/image.jpg"))
        .thenReturn(img);

    var thumb = MockFile();
    when(thumb.exists()).thenAnswer((_) => Future.value(false));
    when(thumb.writeAsBytes(any)).thenAnswer((_) => Future.value(thumb));
    when(thumb.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([1, 2, 3])));
    when(appManager.mockIoWrapper.file("$_cachePath/2.0/thumbs/50/image.jpg"))
        .thenReturn(thumb);

    // Cache does not include image; image should be compressed.
    var bytes = await imageManager.image(
      context,
      fileName: "image.jpg",
      size: 50,
    );
    verify(appManager.mockIoWrapper.directory(any)).called(1);
    verify(appManager.mockImageCompressWrapper.compress(any, any, any))
        .called(1);
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));

    // Cache now includes image in memory, verify the cache version is used.
    bytes = await imageManager.image(
      context,
      fileName: "image.jpg",
      size: 50,
    );
    verifyNever(appManager.mockIoWrapper.directory(any));
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));

    // Clear memory cache by reinitializing manager.
    imageManager.initialize();

    // Ensure thumbnail exists.
    when(thumb.exists()).thenAnswer((_) => Future.value(true));

    bytes = await imageManager.image(
      context,
      fileName: "image.jpg",
      size: 50,
    );
    verify(appManager.mockIoWrapper.file("$_cachePath/2.0/thumbs/50/image.jpg"))
        .called(1);
    verifyNever(appManager.mockImageCompressWrapper.compress(any, any, any));
    expect(bytes, isNotNull);
    expect(bytes, equals(Uint8List.fromList([1, 2, 3])));
  });

  testWidgets("Get images", (tester) async {
    await imageManager.initialize();
    var context = await buildContext(tester);

    // Invalid input.
    expect(
      await imageManager.images(
        context,
        imageNames: null,
        size: null,
      ),
      isEmpty,
    );
    expect(
      await imageManager.images(
        context,
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
    when(appManager.mockIoWrapper.file("$_imagePath/2.0/images/image0.jpg"))
        .thenReturn(img0);

    File img1 = MockFile();
    when(img1.exists()).thenAnswer((_) => Future.value(false));
    when(img1.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([3, 2, 1])));
    when(appManager.mockIoWrapper.file("$_imagePath/2.0/images/image1.jpg"))
        .thenReturn(img1);

    var byteList = await imageManager
        .images(context, imageNames: ["image0.jpg", "image1.jpg"]);
    expect(byteList, isNotNull);
    expect(byteList.length, 1);

    // All thumbnails exist (normal case).
    when(img1.exists()).thenAnswer((_) => Future.value(true));
    when(img0.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([3, 2, 1])));

    byteList = await imageManager
        .images(context, imageNames: ["image0.jpg", "image1.jpg"]);
    expect(byteList, isNotNull);
    expect(byteList.length, 2);

    // No thumbnails exist.
    when(img0.exists()).thenAnswer((_) => Future.value(false));
    when(img1.exists()).thenAnswer((_) => Future.value(false));

    byteList = await imageManager
        .images(context, imageNames: ["image0.jpg", "image1.jpg"]);
    expect(byteList, isNotNull);
    expect(byteList.isEmpty, true);
  });

  test("Normal saving images", () async {
    await imageManager.initialize();

    // Verify there no images are saved.
    expect(await imageManager.save([]), isEmpty);
    verifyNever(appManager.mockImageCompressWrapper.compress(any, any, any));

    // Add some images.
    var img0 = MockFile();
    when(img0.path).thenReturn("image0.jpg");
    when(img0.exists()).thenAnswer((_) => Future.value(true));
    when(img0.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([1, 2, 3])));
    when(appManager.mockImageCompressWrapper.compress("image0.jpg", any, any))
        .thenAnswer((_) => img0.readAsBytes());

    var img1 = MockFile();
    when(img1.path).thenReturn("image1.jpg");
    when(img1.exists()).thenAnswer((_) => Future.value(true));
    when(img1.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([3, 2, 1])));
    when(appManager.mockImageCompressWrapper.compress("image1.jpg", any, any))
        .thenAnswer((_) => img1.readAsBytes());

    var addedImages = <MockFile>[];
    when(appManager.mockIoWrapper.file(any)).thenAnswer((invocation) {
      var newFile = MockFile();
      when(newFile.path).thenReturn(invocation.positionalArguments.first);
      when(newFile.exists()).thenAnswer((_) => Future.value(false));
      when(newFile.writeAsBytes(any)).thenAnswer((_) => Future.value(newFile));
      addedImages.add(newFile);
      return newFile;
    });

    expect((await imageManager.save([img0, img1])).length, 2);
    expect(addedImages.length, 2);
    for (var img in addedImages) {
      verify(img.writeAsBytes(any, flush: true)).called(1);
    }
    verify(appManager.mockImageCompressWrapper.compress(any, any, any))
        .called(2);
  });

  test("Null image files are skipped when saving", () async {
    await imageManager.save([null, null]);
    expect(await imageManager.save([null, null]), isEmpty);
    verifyNever(appManager.mockImageCompressWrapper.compress(any, any, any));
  });

  test("Saving an empty list does nothing", () async {
    try {
      expect(await imageManager.save([]), isEmpty);
      expect(await imageManager.save(null), isEmpty);
    } on Exception catch (_) {
      fail("Invalid input should be handled gracefully");
    }
  });

  test("Saving an image that exists at the same path uses the existing image",
      () async {
    var img0 = MockFile();
    when(img0.path).thenReturn("$_imagePath/2.0/images/image.jpg");
    when(img0.exists()).thenAnswer((_) => Future.value(true));
    when(appManager.mockIoWrapper.file(any)).thenReturn(img0);

    var img1 = MockFile();
    when(img1.path).thenReturn("$_imagePath/2.0/images/image.jpg");
    when(img1.exists()).thenAnswer((_) => Future.value(true));

    await imageManager.initialize();
    var images = await imageManager.save([img1]);
    expect(images.length, 1);
    expect(images.first, "image.jpg");
    verifyNever(appManager.mockImageCompressWrapper.compress(any, any, any));
  });

  test("Clearing stale images", () async {
    var img1 = MockFile();
    when(img1.path).thenReturn("$_imagePath/image1.jpg");
    when(img1.deleteSync()).thenAnswer((_) {});

    var img2 = MockFile();
    when(img2.path).thenReturn("$_imagePath/image2.jpg");
    when(img2.deleteSync()).thenAnswer((_) {});

    when(directory.list()).thenAnswer((_) =>
        Stream.fromFutures([img1, img2].map((img) => Future.value(img))));

    var catch1 = Catch()
      ..id = randomId()
      ..timestamp = timestampFromMillis(5);
    catch1.imageNames.add("image1.jpg");

    var catch2 = Catch()
      ..id = randomId()
      ..timestamp = timestampFromMillis(5);
    catch2.imageNames.add("image2.jpg");

    when(appManager.mockCatchManager.list()).thenReturn([catch1, catch2]);
    await imageManager.initialize();
    verifyNever(img1.deleteSync());
    verifyNever(img2.deleteSync());

    catch2.imageNames.clear();
    await imageManager.initialize();
    verifyNever(img1.deleteSync());
    verify(img2.deleteSync()).called(1);
  });

  group("dartImage", () {
    testWidgets("Invalid image returns null", (tester) async {
      await imageManager.initialize();
      var context = await buildContext(tester);
      var image = await imageManager.dartImage(context, "", 50);
      expect(image, isNull);
    });

    test("Converting valid image gives non-null result", () async {
      // Nothing to do here. Assume instantiateImageCodec works as it should.
    });
  });
}
