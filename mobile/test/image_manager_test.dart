import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/entity_image.dart';
import 'package:mockito/mockito.dart';

import 'test_utils.dart';

class MockAppManager extends Mock implements AppManager {}
class MockDataManager extends Mock implements DataManager {}
class MockDirectory extends Mock implements Directory {}
class MockFile extends Mock implements File {}
class MockImageManagerDelegate extends Mock implements ImageManagerDelegate {}

const _imagePath = "test/tmp_image";
const _cachePath = "test/tmp_cache";

void main() {
  MockAppManager _appManager;
  MockDataManager _dataManager;
  MockImageManagerDelegate _imageManagerDelegate;

  ImageManager _imageManager;

  setUp(() async {
    _appManager = MockAppManager();

    _dataManager = MockDataManager();
    when(_dataManager.fetchAll(any)).thenAnswer((_) => Future.value([]));
    when(_appManager.dataManager).thenReturn(_dataManager);

    _imageManagerDelegate = MockImageManagerDelegate();
    when(_imageManagerDelegate.imagePath).thenReturn(_imagePath);
    when(_imageManagerDelegate.cachePath).thenReturn(_cachePath);
    when(_imageManagerDelegate.directory(any)).thenReturn(MockDirectory());
    when(_imageManagerDelegate.file(any)).thenReturn(MockFile());
    when(_imageManagerDelegate.compress(any, any, any)).thenAnswer((_) =>
        Future.value(Uint8List.fromList([10, 11, 12])));

    _imageManager = ImageManager(_appManager);
  });

  test("Initialize", () async {
    // Load from database.
    var entity1 = EntityImage(
      entityId: "ID",
      imageName: "NAME",
    ).toMap();
    var entity2 = EntityImage(
      entityId: "ID2",
      imageName: "NAME2",
    ).toMap();
    when(_dataManager.fetchAll(any)).thenAnswer((_) => Future.value([
      entity1, entity2,
    ]));
    await _imageManager.initialize(delegate: _imageManagerDelegate);
    expect(_imageManager.imageNames(entityId: "ID").length, 1);
    expect(_imageManager.imageNames(entityId: "ID2").length, 1);
  });

  test("imageNames returns empty list when none exist", () async {
    await _imageManager.initialize(delegate: _imageManagerDelegate);
    List<String> names = _imageManager.imageNames(entityId: "ID");
    expect(names, isNotNull);
    expect(names, isEmpty);
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
    when(_dataManager.fetchAll(any)).thenAnswer((_) => Future.value([
      EntityImage(
        entityId: "id",
        imageName: "image.jpg",
      ).toMap(),
    ]));
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
    when(_dataManager.commitBatch(any)).thenAnswer((_) => Future.value([]));
    await _imageManager.save("id", null); // Clears memory cache.

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

  testWidgets("Get images for entity ID", (WidgetTester tester) async {
    when(_dataManager.fetchAll(any)).thenAnswer((_) => Future.value([
      EntityImage(
        entityId: "id",
        imageName: "image0.jpg",
      ).toMap(),
      EntityImage(
        entityId: "id",
        imageName: "image1.jpg",
      ).toMap(),
    ]));
    await _imageManager.initialize(delegate: _imageManagerDelegate);
    BuildContext context = await buildContext(tester);

    // Invalid input.
    expect(await _imageManager.images(context,
      entityId: null,
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

    List<Uint8List> byteList =
        await _imageManager.images(context, entityId: "id");
    expect(byteList, isNotNull);
    expect(byteList.length, 1);

    // All thumbnails exist (normal case).
    when(img1.exists()).thenAnswer((_) => Future.value(true));
    when(img0.readAsBytes()).thenAnswer((_) =>
        Future.value(Uint8List.fromList([3, 2, 1])));

    byteList = await _imageManager.images(context, entityId: "id");
    expect(byteList, isNotNull);
    expect(byteList.length, 2);

    // No thumbnails exist.
    when(img0.exists()).thenAnswer((_) => Future.value(false));
    when(img1.exists()).thenAnswer((_) => Future.value(false));

    byteList = await _imageManager.images(context, entityId: "id");
    expect(byteList, isNotNull);
    expect(byteList.isEmpty, true);
  });

  test("Normal saving images", () async {
    when(_dataManager.fetchAll(any)).thenAnswer((_) => Future.value([]));
    await _imageManager.initialize(delegate: _imageManagerDelegate);

    // Verify there no images are saved.
    await _imageManager.save("ID", []);
    verifyNever(_imageManagerDelegate.compress(any, any, any));
    verifyNever(_dataManager.commitBatch(any));

    // Add some images to the database.
    when(_dataManager.commitBatch(any)).thenAnswer((_) {
      // Return list doesn't matter here as long as it's of length 2.
      return Future.value([1, 2]);
    });

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

    await _imageManager.save("ID", [img0, img1]);
    expect(addedImages.length, 2);
    addedImages.forEach((img) {
      verify(img.writeAsBytes(any, flush: true)).called(1);
    });
    verify(_imageManagerDelegate.compress(any, any, any)).called(2);
    verify(_dataManager.commitBatch(any)).called(1);
    expect(_imageManager.imageNames(entityId: "ID").length, 2);
  });

  test("Null image files are skipped when saving", () async {
    await _imageManager.save("1", [null, null]);
    verifyNever(_dataManager.commitBatch(any));
  });

  test("Saving an empty list does nothing if entity ID doesn't have any "
      "associated images", () async
  {
    await _imageManager.save("1", []);
    verifyNever(_dataManager.commitBatch(any));

    await _imageManager.save("1", null);
    verifyNever(_dataManager.commitBatch(any));
  });

  test("Saving an empty image list clears existing images", () async {
    // Setup some existing images.
    var entity1 = EntityImage(entityId: "ID", imageName: "NAME").toMap();
    var entity2 = EntityImage(entityId: "ID2", imageName: "NAME2").toMap();
    when(_dataManager.fetchAll(any)).thenAnswer((_) =>
        Future.value([entity1, entity2]));
    await _imageManager.initialize(delegate: _imageManagerDelegate);

    // Set images to empty list.
    when(_dataManager.commitBatch(any)).thenAnswer((_) => Future.value([1]));
    await _imageManager.save("ID", []);
    verify(_dataManager.commitBatch(any)).called(1);
    expect(_imageManager.imageNames(entityId: "ID"), isEmpty);
    expect(_imageManager.imageNames(entityId: "ID2").length, 1);
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
    await _imageManager.save("1", [img1]);
    verifyNever(_imageManagerDelegate.compress(any, any, any));
  });

  test("Error saving images to database does not update memory cache",
      () async
  {
    when(_imageManagerDelegate.compress(any, any, any)).thenAnswer((_) =>
        Future.value(Uint8List.fromList([1, 2, 3])));
    await _imageManager.initialize(delegate: _imageManagerDelegate);

    // Empty batch result.
    var img0 = MockFile();
    when(img0.path).thenReturn("image0.jpg");
    when(img0.exists()).thenAnswer((_) => Future.value(true));

    when(_imageManagerDelegate.file(any)).thenReturn(img0);
    when(_dataManager.commitBatch(any)).thenAnswer((_) => Future.value([]));

    await _imageManager.save("1", [img0]);
    verify(_imageManagerDelegate.compress(any, any, any)).called(1);
    expect(_imageManager.imageNames(entityId: "1"), isEmpty);

    // Non-empty batch result.
    var img1 = MockFile();
    when(img1.path).thenReturn("image1.jpg");
    when(img1.exists()).thenAnswer((_) => Future.value(true));

    when(_imageManagerDelegate.file(any)).thenReturn(img1);
    when(_dataManager.commitBatch(any)).thenAnswer((_) => Future.value([4]));

    await _imageManager.save("2", [img1]);
    expect(_imageManager.imageNames(entityId: "2").length, 1);
  });
}