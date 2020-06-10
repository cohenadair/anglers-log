import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/entity_image.dart';
import 'package:mockito/mockito.dart';

class MockAppManager extends Mock implements AppManager {}
class MockDataManager extends Mock implements DataManager {}
class MockDirectory extends Mock implements Directory {}
class MockImageProvider extends Mock implements ImageManagerProvider {}

void main() {
  MockAppManager _appManager;
  MockDataManager _dataManager;
  MockDirectory _directory;
  MockImageProvider _imageProvider;

  ImageManager _imageManager;

  setUp(() async {
    _appManager = MockAppManager();

    _dataManager = MockDataManager();
    when(_appManager.dataManager).thenReturn(_dataManager);
    when(_dataManager.fetchAll(any)).thenAnswer((_) => Future.value([]));

    _directory = MockDirectory();
    when(_directory.exists()).thenAnswer((_) => Future.value(true));
    when(_directory.path).thenReturn("test");

    _imageProvider = MockImageProvider();
    when(_imageProvider.directory).thenReturn(_directory);

    _imageManager = ImageManager(_appManager);
    await _imageManager.initialize(provider: _imageProvider);
    verify(_dataManager.fetchAll(any)).called(1);
  });

  tearDown(() async {
    _imageManager.allFiles().forEach((file) async {
      try {
        await file.delete();
      } on Exception {
        // Do nothing.
      }
    });
  });

  test("Initialize", () async {
    when(_imageProvider.compress).thenAnswer((_) => (_) => null);
    when(_directory.exists()).thenAnswer((_) => Future.value(false));
    when(_directory.createSync()).thenAnswer((_) {});
    when(_dataManager.fetchAll(any)).thenAnswer((_) => Future.value([]));

    // Create directory.
    await _imageManager.initialize(provider: _imageProvider);
    verify(_directory.createSync()).called(1);
    verify(_dataManager.fetchAll(any)).called(1);
    expect(_imageManager.images(), []);

    // Directory already exists.
    when(_directory.exists()).thenAnswer((_) => Future.value(true));
    await _imageManager.initialize(provider: _imageProvider);
    verifyNever(_directory.createSync());

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
    await _imageManager.initialize(provider: _imageProvider);
    expect(_imageManager.images(entityId: "ID").length, 1);
    expect(_imageManager.images(entityId: "ID2").length, 1);
  });

  test("Normal saving images", () async {
    when(_imageProvider.compress).thenAnswer((_) =>
        (source) => Future.value(File(source).readAsBytesSync().toList()));
    when(_dataManager.fetchAll(any)).thenAnswer((_) => Future.value([]));
    await _imageManager.initialize(provider: _imageProvider);

    // No image files.
    await _imageManager.save("ID", []);
    verifyNever(_imageProvider.compress);
    verifyNever(_dataManager.commitBatch(any));

    // Some files
    when(_dataManager.commitBatch(any)).thenAnswer((_) {
      // Return list doesn't matter here as long as it's of length 2.
      return Future.value([1, 2]);
    });
    File image1 = File("IDIMAGE1.jpg");
    image1.writeAsBytesSync([1, 2, 3]);
    File image2 = File("IDIMAGE2.jpg");
    image2.writeAsBytesSync([3, 2, 1]);
    await _imageManager.save("ID", [image1, image2]);
    expect(_imageManager.images(entityId: "ID").length, 2);
    expect(_imageManager.allFiles().length, 2);
    verify(_imageProvider.compress).called(2);
    verify(_dataManager.commitBatch(any)).called(1);
    image1.delete();
    image2.delete();
  });

  test("Save empty list, nothing to delete", () async {
    await _imageManager.save("1", []);
    verifyNever(_dataManager.commitBatch(any));

    await _imageManager.save("1", null);
    verifyNever(_dataManager.commitBatch(any));
  });

  test("Save empty list, clear existing images", () async {
    // Setup some existing images.
    var entity1 = EntityImage(entityId: "ID", imageName: "NAME").toMap();
    var entity2 = EntityImage(entityId: "ID2", imageName: "NAME2").toMap();
    when(_dataManager.fetchAll(any)).thenAnswer((_) =>
        Future.value([entity1, entity2]));
    await _imageManager.initialize(provider: _imageProvider);
    expect(_imageManager.allFiles().length, 2);

    // Set images to empty list.
    when(_dataManager.commitBatch(any)).thenAnswer((_) => Future.value([1]));
    await _imageManager.save("ID", []);
    verify(_dataManager.commitBatch(any)).called(1);
    expect(_imageManager.allFiles().length, 1);
  });

  test("Save file that already exists", () async {
    File image = File("test/IDIMAGE1.jpg");
    image.writeAsBytesSync([1, 2, 3]);

    await _imageManager.save("1", [File("test/IDIMAGE1.jpg")]);
    verifyNever(_imageProvider.compress);

    image.delete();
  });

  test("Save duplicate image (different path; same image bytes)", () async {
    File image = File("test/IDIMAGE1.jpg");
    image.writeAsBytesSync([1, 2, 3]);

    when(_imageProvider.compress).thenAnswer((_) =>
        (_) => Future.value([1, 2, 3]));
    when(_dataManager.commitBatch(any)).thenAnswer((_) => Future.value([1]));
    await _imageManager.save("1", [File("dir/IDIMAGE1.jpg")]);
    verify(_imageProvider.compress).called(1);

    image.delete();
  });

  test("Error saving images to database still updates memory", () async {
    when(_imageProvider.compress).thenAnswer((_) =>
        (_) => Future.value([1, 2, 3]));

    // Empty batch result.
    when(_dataManager.commitBatch(any)).thenAnswer((_) => Future.value([]));
    await _imageManager.save("1", [File("test/IDIMAGE1.jpg")]);
    expect(_imageManager.allFiles().length, 1);

    // Non-empty batch result.
    when(_dataManager.commitBatch(any)).thenAnswer((_) => Future.value([4]));
    await _imageManager.save("2", [File("test/IDIMAGE2.jpg")]);
    expect(_imageManager.allFiles().length, 2);
  });
}