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

void main() {
  MockAppManager _appManager;
  MockDataManager _dataManager;

  ImageManager _imageManager;

  setUp(() {
    _appManager = MockAppManager();
    _dataManager = MockDataManager();
    when(_appManager.dataManager).thenReturn(_dataManager);

    _imageManager = ImageManager.get(_appManager);
  });

  test("Initialize", () async {
    var mockDirectory = MockDirectory();
    var provider = ImageManagerProvider(
      directory: mockDirectory,
      compress: (_, __) => null,
    );
    when(mockDirectory.exists()).thenAnswer((_) => Future.value(false));
    when(mockDirectory.createSync()).thenAnswer((_) {});
    when(_dataManager.fetchAll(any)).thenAnswer((_) => Future.value([]));

    // Create directory.
    await _imageManager.initialize(provider: provider);
    verify(mockDirectory.createSync()).called(1);
    verify(_dataManager.fetchAll(any)).called(1);
    expect(_imageManager.imageFiles(), []);

    // Directory already exists.
    when(mockDirectory.exists()).thenAnswer((_) => Future.value(true));
    await _imageManager.initialize(provider: provider);
    verifyNever(mockDirectory.createSync());

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
    await _imageManager.initialize(provider: provider);
    expect(_imageManager.imageFiles(entityId: "ID").length, 1);
    expect(_imageManager.imageFiles(entityId: "ID2").length, 1);
  });

  test("Saving images", () async {
    var compressCount = 0;
    var mockDirectory = MockDirectory();
    var provider = ImageManagerProvider(
      directory: mockDirectory,
      compress: (_, dest) {
        compressCount++;
        return Future.value(File(dest));
      },
    );
    when(mockDirectory.exists()).thenAnswer((_) => Future.value(true));
    when(mockDirectory.path).thenReturn("test");
    when(_dataManager.fetchAll(any)).thenAnswer((_) => Future.value([]));
    await _imageManager.initialize(provider: provider);

    // No image files.
    await _imageManager.save(entityId: "ID", files: []);
    expect(compressCount, 0);
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
    await _imageManager.save(entityId: "ID", files: [image1, image2]);
    expect(compressCount, 2);
    expect(_imageManager.imageFiles(entityId: "ID").length, 2);
    verify(_dataManager.commitBatch(any)).called(1);
    image1.delete();
    image2.delete();
  });
}