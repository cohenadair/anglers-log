import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

const _imagePath = "test/tmp_image";
const _cachePath = "test/tmp_cache";

void main() {
  MockAppManager appManager;
  MockDirectory directory;

  ImageManager imageManager;

  setUp(() async {
    appManager = MockAppManager(
      mockAuthManager: true,
      mockCatchManager: true,
      mockSubscriptionManager: true,
      mockFirebaseStorageWrapper: true,
      mockIoWrapper: true,
      mockImageCompressWrapper: true,
      mockPathProviderWrapper: true,
    );

    when(appManager.mockCatchManager.list()).thenReturn([]);

    directory = MockDirectory();
    when(directory.list(recursive: anyNamed("recursive")))
        .thenAnswer((_) => Stream.empty());

    when(appManager.mockSubscriptionManager.stream)
        .thenAnswer((_) => MockStream<void>());
    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

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

  testWidgets("Thumbnail can't be created when file doesn't exist",
      (tester) async {
    await imageManager.initialize();
    var context = await buildContext(tester);

    var file = MockFile();
    when(file.exists()).thenAnswer((_) => Future.value(false));
    when(appManager.mockIoWrapper.file("$_imagePath/2.0/images/image.jpg"))
        .thenReturn(file);

    var thumb = MockFile();
    when(thumb.exists()).thenAnswer((_) => Future.value(false));
    when(appManager.mockIoWrapper.file("$_cachePath/2.0/thumbs/50/image.jpg"))
        .thenReturn(thumb);

    await imageManager.image(
      context,
      fileName: "image.jpg",
      size: 50,
    );

    verifyNever(thumb.writeAsBytes(any));
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

  testWidgets("Get image downloads file if it doesn't already exist",
      (tester) async {
    await imageManager.initialize();
    var context = await buildContext(tester);

    var file = MockFile();
    when(appManager.mockIoWrapper.file(any)).thenReturn(file);

    // File exists.
    when(file.exists()).thenAnswer((_) => Future.value(true));
    expect(await imageManager.image(context, fileName: "test.jpg"), isNull);
    verifyNever(appManager.mockFirebaseStorageWrapper.ref(any));
    verifyNever(appManager.mockSubscriptionManager.isPro);

    // File doesn't exist, but user isn't pro.
    when(appManager.mockSubscriptionManager.stream)
        .thenAnswer((_) => MockStream<void>());
    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);
    when(file.exists()).thenAnswer((_) => Future.value(false));
    expect(await imageManager.image(context, fileName: "test.jpg"), isNull);
    verifyNever(appManager.mockFirebaseStorageWrapper.ref(any));
    verify(appManager.mockSubscriptionManager.isPro).called(1);

    // File doesn't exist, and user is pro.
    when(appManager.mockFirebaseStorageWrapper.ref(any))
        .thenReturn(MockReference());
    when(appManager.mockSubscriptionManager.isPro).thenReturn(true);
    when(file.exists()).thenAnswer((_) => Future.value(false));
    expect(await imageManager.image(context, fileName: "test.jpg"), isNull);
    verify(appManager.mockFirebaseStorageWrapper.ref(any)).called(1);
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

  test("Uploading images", () async {
    await imageManager.initialize();

    var file = MockFile();
    when(file.exists()).thenAnswer((_) => Future.value(true));
    when(file.path).thenReturn("test/path/to/img/test.jpg");
    when(file.readAsBytes())
        .thenAnswer((_) => Future.value(Uint8List.fromList([3, 2, 1])));
    when(appManager.mockIoWrapper.file(any)).thenReturn(file);

    // Not pro.
    await imageManager.save([file], compress: false);
    verify(appManager.mockSubscriptionManager.isPro).called(1);
    verifyNever(file.existsSync());

    // Upload file doesn't exist.
    when(appManager.mockSubscriptionManager.isPro).thenReturn(true);
    when(file.existsSync()).thenReturn(false);
    await imageManager.save([file], compress: false);
    verify(file.existsSync()).called(1);
    verifyNever(appManager.mockFirebaseStorageWrapper.ref(any));

    // Upload sent to Firebase.
    var ref = MockReference();
    when(appManager.mockSubscriptionManager.isPro).thenReturn(true);
    when(appManager.mockFirebaseStorageWrapper.ref(any)).thenReturn(ref);
    when(file.existsSync()).thenReturn(true);
    await imageManager.save([file], compress: false);
    verify(ref.putFile(any)).called(1);
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

    var imgDir = MockDirectory();
    when(imgDir.list()).thenAnswer((_) =>
        Stream.fromFutures([img1, img2].map((img) => Future.value(img))));
    when(appManager.mockIoWrapper.directory("$_imagePath/2.0/images"))
        .thenReturn(imgDir);

    var thumb1 = MockFile();
    when(thumb1.path).thenReturn("$_cachePath/50/image1.jpg");
    when(thumb1.deleteSync()).thenAnswer((_) {});

    var thumb2 = MockFile();
    when(thumb2.path).thenReturn("$_cachePath/50/image2.jpg");
    when(thumb2.deleteSync()).thenAnswer((_) {});

    // Directories should not be deleted.
    var dir = MockDirectory();
    when(dir.path).thenReturn("$_cachePath");

    var thumbDir = MockDirectory();
    when(thumbDir.list(recursive: true)).thenAnswer((_) => Stream.fromFutures(
        [thumb1, thumb2, dir].map((img) => Future.value(img))));
    when(appManager.mockIoWrapper.directory("$_cachePath/2.0/thumbs"))
        .thenReturn(thumbDir);

    var catch1 = Catch()
      ..id = randomId()
      ..timestamp = Int64(5);
    catch1.imageNames.add("image1.jpg");

    var catch2 = Catch()
      ..id = randomId()
      ..timestamp = Int64(5);
    catch2.imageNames.add("image2.jpg");

    when(appManager.mockCatchManager.list()).thenReturn([catch1, catch2]);
    await imageManager.initialize();
    verifyNever(img1.deleteSync());
    verifyNever(img2.deleteSync());

    catch2.imageNames.clear();
    await imageManager.initialize();
    verifyNever(img1.deleteSync());
    verifyNever(thumb1.deleteSync());
    verifyNever(dir.deleteSync());
    verify(img2.deleteSync()).called(1);
    verify(thumb2.deleteSync()).called(1);
    verifyNever(appManager.mockFirebaseStorageWrapper.ref(any));
    verify(appManager.mockSubscriptionManager.isPro).called(1);

    // Reset catches.
    catch1 = Catch()
      ..id = randomId()
      ..timestamp = Int64(5);
    catch1.imageNames.add("image1.jpg");

    catch2 = Catch()
      ..id = randomId()
      ..timestamp = Int64(5);
    catch2.imageNames.add("image2.jpg");

    when(appManager.mockCatchManager.list()).thenReturn([catch1, catch2]);
    when(appManager.mockSubscriptionManager.isPro).thenReturn(true);
    when(appManager.mockFirebaseStorageWrapper.ref(any))
        .thenReturn(MockReference());
    catch1.imageNames.clear();
    await imageManager.initialize();
    verifyNever(img2.deleteSync());
    verifyNever(thumb2.deleteSync());
    verifyNever(dir.deleteSync());
    verify(img1.deleteSync()).called(1);
    verify(thumb1.deleteSync()).called(1);
    verify(appManager.mockFirebaseStorageWrapper.ref(any)).called(1);
    verify(appManager.mockSubscriptionManager.isPro).called(1);
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

  group("On subscription stream updates", () {
    test("Free user is a no-op", () {
      var controller = StreamController.broadcast();
      when(appManager.mockSubscriptionManager.stream)
          .thenAnswer((_) => controller.stream);
      when(appManager.mockSubscriptionManager.isFree).thenReturn(true);

      imageManager = ImageManager(appManager);
      controller.add(null);
      verifyNever(appManager.mockIoWrapper.directory(any));
    });

    test("No images is a no-op", () async {
      var controller = StreamController.broadcast();
      when(appManager.mockSubscriptionManager.stream)
          .thenAnswer((_) => controller.stream);
      when(appManager.mockSubscriptionManager.isFree).thenReturn(false);

      var directory = MockDirectory();
      when(directory.list()).thenAnswer((_) => MockStream());
      when(appManager.mockIoWrapper.directory(any)).thenReturn(directory);

      imageManager = ImageManager(appManager);
      controller.add(null);

      // Wait for callback to finish.
      await Future.delayed(Duration(milliseconds: 50));
      verify(appManager.mockIoWrapper.directory(any)).called(1);
      verifyNever(appManager.mockFirebaseStorageWrapper.ref(any));
    });

    test("Images already exist in the cloud", () async {
      var subController = StreamController.broadcast();
      when(appManager.mockSubscriptionManager.stream)
          .thenAnswer((_) => subController.stream);
      when(appManager.mockSubscriptionManager.isFree).thenReturn(false);

      // Add a couple files to directory stream.
      var dirController = StreamController<FileSystemEntity>();
      var file1 = MockFile();
      when(file1.path).thenReturn("test/path1.png");
      var file2 = MockFile();
      when(file2.path).thenReturn("test/path2.png");
      dirController.add(file1);
      dirController.add(file2);

      var directory = MockDirectory();
      when(directory.list()).thenAnswer((_) => dirController.stream);
      when(appManager.mockIoWrapper.directory(any)).thenReturn(directory);

      var reference = MockReference();
      when(reference.getMetadata())
          .thenAnswer((_) => Future.value(MockFullMetadata()));
      when(appManager.mockFirebaseStorageWrapper.ref(any))
          .thenAnswer((_) => reference);

      imageManager = ImageManager(appManager);
      subController.add(null);

      // Wait for callback to finish.
      await Future.delayed(Duration(milliseconds: 50));
      verify(appManager.mockIoWrapper.directory(any)).called(1);
      verify(appManager.mockFirebaseStorageWrapper.ref(any)).called(2);
      verifyNever(appManager.mockSubscriptionManager.isPro);
    });

    test("Images are uploaded", () async {
      var subController = StreamController.broadcast();
      when(appManager.mockSubscriptionManager.stream)
          .thenAnswer((_) => subController.stream);
      when(appManager.mockSubscriptionManager.isFree).thenReturn(false);

      // Add a couple files to directory stream.
      var dirController = StreamController<FileSystemEntity>();
      var file1 = MockFile();
      when(file1.path).thenReturn("test/path1.png");
      var file2 = MockFile();
      when(file2.path).thenReturn("test/path2.png");
      dirController.add(file1);
      dirController.add(file2);

      var directory = MockDirectory();
      when(directory.list()).thenAnswer((_) => dirController.stream);
      when(appManager.mockIoWrapper.directory(any)).thenReturn(directory);

      var reference = MockReference();
      when(reference.getMetadata()).thenThrow(FirebaseException(plugin: ""));
      when(appManager.mockFirebaseStorageWrapper.ref(any))
          .thenAnswer((_) => reference);

      imageManager = ImageManager(appManager);
      subController.add(null);

      // Wait for callback to finish.
      await Future.delayed(Duration(milliseconds: 50));
      verify(appManager.mockIoWrapper.directory(any)).called(1);
      verify(appManager.mockFirebaseStorageWrapper.ref(any)).called(2);
      verify(appManager.mockSubscriptionManager.isPro).called(2);
    });
  });
}
