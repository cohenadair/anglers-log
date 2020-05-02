import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/entity_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:sqflite/sqflite.dart';

/// A class used for dependency injection for non-Anglers' Log dependencies.
class ImageManagerProvider {
  /// The directory in which to save images. If it doesn't exist, it will be
  /// created.
  final Directory directory;

  /// A function for compressing the image at [sourcePath].
  final Future<List<int>> Function(String sourcePath) compress;

  ImageManagerProvider({
    @required this.directory,
    @required this.compress,
  }) : assert(directory != null),
       assert(compress != null);
}

class ImageManager {
  static ImageManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).imageManager;

  ImageManager(AppManager app) : _dataManager = app.dataManager;

  final Log _log = Log("ImageManager");
  final String _tableName = "entity_image";
  final int _imageCompressionQuality = 80;

  final DataManager _dataManager;

  /// Memory cache of entity ID to image names.
  final Map<String, Set<String>> _entityImages = {};

  ImageManagerProvider _provider;

  String get _path => _provider.directory.path;

  Future<void> initialize({ImageManagerProvider provider}) async {
    _provider = provider ?? ImageManagerProvider(
      directory: Directory(
          (await getApplicationDocumentsDirectory()).path + "/images"),
      // TODO: Compression freezes UI until finished.
      // https://github.com/OpenFlutter/flutter_image_compress/issues/131
      compress: (source) => FlutterImageCompress.compressWithFile(
          source, quality: _imageCompressionQuality),
    );

    // Create images directory if it doesn't already exist.
    if (!(await _provider.directory.exists())) {
      _provider.directory.createSync();
    }

    // Fetch image map into memory.
    (await _fetchAll()).forEach((image) async => _addToMemoryCache(image));
  }

  String _fullPath(String imageName) => "$_path/$imageName";

  List<File> imageFiles({String entityId}) {
    if (isEmpty(entityId)) {
      return [];
    }
    return List.unmodifiable(_entityImages[entityId] ?? [])
        .map((name) => _file(name)).toList();
  }

  /// Returns a list of all images in the log.
  Set<File> allFiles() {
    Set<File> result = {};
    _entityImages.values.forEach((imageList) {
      result.addAll(imageList.map((name) => _file(name)));
    });
    return result;
  }

  File _file(String imageName) => File(_fullPath(imageName));

  void _addToMemoryCache(EntityImage image) {
    if (_entityImages[image.entityId] == null) {
      _entityImages[image.entityId] = <String>[].toSet();
    }
    _entityImages[image.entityId].add(image.imageName);
  }

  /// Compresses the given image files, converts them to JPG format, and saves
  /// them to the app's sandbox if the file doesn't already exit.
  ///
  /// This method will update the database such that the given entity ID will
  /// only be associated with the given image files. Any previous association
  /// will be overridden.
  ///
  /// Files are named by the image's MD5 hash value to ensure uniqueness, and
  /// that the same image isn't saved multiple times.
  Future<void> save({String entityId, List<File> files}) async {
    if (files == null || files.isEmpty) {
      await _delete(entityId);
      return;
    }

    List<EntityImage> dbImages = [];

    for (var file in files) {
      // If the file already exists in the app's sandbox, don't copy it again.
      if (file.path.contains(_provider.directory.path) && await file.exists()) {
        _log.d("File exists, nothing to do");
        continue;
      }

      // Compress first, so image MD5 hashes are equal to existing files.
      List<int> jpgBytes = await _provider.compress(file.path);

      Digest digest = md5.convert(jpgBytes);
      var fileName = "${digest.toString()}.jpg";
      var newFile = _file(fileName);

      if (await newFile.exists()) {
        _log.d("Using existing file");
      } else {
        _log.d("New file doesn't exist, copying to ${newFile.path}");
        try {
          newFile.writeAsBytesSync(jpgBytes, flush: true);
        } on FileSystemException catch (e) {
          _log.e("Error copying image to ${newFile.path}: $e}");
        }
      }

      // Cache database entries so they can be committed in a batch.
      dbImages.add(EntityImage(
        entityId: entityId,
        imageName: fileName,
      ));
    }

    if (dbImages.isNotEmpty) {
      _delete(entityId);
      dbImages.forEach((i) async => _addToMemoryCache(i));

      // Create database entries.
      List<dynamic> batchResult = await _dataManager.commitBatch((batch) {
        dbImages.forEach((i) => batch.insert(_tableName, i.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace));
      });

      if (batchResult.isEmpty || batchResult.length != dbImages.length) {
        _log.e("Error saving images to database");
      }
    }
  }

  /// Deletes all images associated with the given entity ID. This applies
  /// only to the database and memory cache; not the file system. Any given
  /// file could be used in other entities.
  Future<void> _delete(String entityId) async {
    Set<String> imageNames = _entityImages[entityId] ?? {};
    if (imageNames.isEmpty) {
      return;
    }

    // Update database.
    List<dynamic> batchResults = await _dataManager.commitBatch((batch) async {
      for (var imageName in imageNames) {
        batch.rawDelete(
            "DELETE FROM $_tableName WHERE entity_id = ? AND image_name = ?",
            [entityId, imageName]);
      }
    });

    var numberDeleted = 0;
    batchResults.forEach((result) => numberDeleted += result);
    _log.d("Deleted $numberDeleted database images");

    // Update memory cache.
    _entityImages[entityId].clear();
  }

  Future<List<EntityImage>> _fetchAll() async {
    var results = await _dataManager.fetchAll(_tableName);
    return results.map((map) => EntityImage.fromMap(map)).toList();
  }
}