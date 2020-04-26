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

  /// A function for compressing the image at [sourcePath]. The compressed
  /// image is saved to [destPath] and returned.
  final Future<File> Function(String sourcePath, String destPath) compress;

  ImageManagerProvider({
    @required this.directory,
    @required this.compress,
  }) : assert(directory != null),
       assert(compress != null);
}

class ImageManager {
  static ImageManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).imageManager;

  static ImageManager _instance;
  factory ImageManager.get(AppManager app) {
    if (_instance == null) {
      _instance = ImageManager._internal(app);
    }
    return _instance;
  }
  ImageManager._internal(AppManager app) : _dataManager = app.dataManager;

  final Log _log = Log("ImageManager");
  final String _tableName = "entity_image";
  final int _imageCompressionQuality = 80;

  final DataManager _dataManager;

  /// Memory cache of entity ID to image files.
  final Map<String, Set<File>> _entityImages = {};

  ImageManagerProvider _provider;

  String get _path => _provider.directory.path;

  Future<void> initialize({ImageManagerProvider provider}) async {
    _provider = provider ?? ImageManagerProvider(
      directory: Directory(
          (await getApplicationDocumentsDirectory()).path + "/images"),
      // TODO: Compression freezes UI until finished.
      // https://github.com/OpenFlutter/flutter_image_compress/issues/131
      compress: (source, dest) => FlutterImageCompress
          .compressAndGetFile(source, dest, quality: _imageCompressionQuality),
    );

    // Create images directory if it doesn't already exist.
    if (!(await _provider.directory.exists())) {
      _provider.directory.createSync();
    }

    // Fetch image map into memory.
    (await _fetchAll()).forEach((image) async => _addToMemoryCache(image));
  }

  String fullPath(String imageName) => "$_path/$imageName";

  List<File> imageFiles({String entityId}) {
    if (isEmpty(entityId)) {
      return [];
    }
    return List.unmodifiable(_entityImages[entityId] ?? []);
  }

  File _file(String imageName) => File(fullPath(imageName));

  void _addToMemoryCache(EntityImage image) {
    if (_entityImages[image.entityId] == null) {
      _entityImages[image.entityId] = <File>[].toSet();
    }
    _entityImages[image.entityId].add(_file(image.imageName));
  }

  /// Compresses the given image files, converts them to JPG format, and saves
  /// them to the app's sandbox.
  ///
  /// Files are named by the image's MD5 hash value to ensure uniqueness, and
  /// that the same image isn't saved multiple times.
  Future<void> save({String entityId, List<File> files}) async {
    if (files.isEmpty) {
      return;
    }

    List<EntityImage> dbImages = [];

    for (File file in files) {
      // Use MD5 hash in file name to ensure unique names, and to prevent
      // unnecessary writing to the file system.
      Digest fileMd5 = md5.convert(file.readAsBytesSync().toList());
      var fileName = "${fileMd5.toString()}.jpg";
      var newFile = _file(fileName);

      // Only copy the file if it doesn't already exist.
      if (!(await newFile.exists())) {
        // Compress and copy to app's sandbox.
        if (await _provider.compress(file.path, newFile.path) != null) {
          _log.d("Copied image to ${newFile.path}");
        } else {
          _log.e("Error copying image to ${newFile.path}");
        }
      }

      // Cache database entries so they can be committed in a batch.
      dbImages.add(EntityImage(
        entityId: entityId,
        imageName: fileName,
      ));
    }

    // Create database entries.
    List<dynamic> batchResult = await _dataManager.commitBatch((batch) {
      dbImages.forEach((i) => batch.insert(_tableName, i.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace));
    });

    // Update memory cache if database commit was successful.
    if (batchResult.isNotEmpty && batchResult.length == dbImages.length) {
      dbImages.forEach((i) async => _addToMemoryCache(i));
    } else {
      _log.e("Error saving image to database");
    }
  }

  Future<List<EntityImage>> _fetchAll() async {
    var results = await _dataManager.fetchAll(_tableName);
    return results.map((map) => EntityImage.fromMap(map)).toList();
  }
}