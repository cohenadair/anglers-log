import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/entity_image.dart';
import 'package:mobile/utils/thumbnail_cache.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:sqflite/sqflite.dart';

/// A class used for dependency injection for non-Anglers' Log dependencies.
class ImageManagerProvider {
  /// The directory in which to save images. If it doesn't exist, it will be
  /// created.
  final Directory directory;

  /// The director in which to save thumbnails. If it doesn't exist, it will be
  /// created.
  final Directory cacheDirectory;

  /// A function for compressing the image at [sourcePath].
  final CompressCallback compress;

  ImageManagerProvider({
    @required this.directory,
    @required this.cacheDirectory,
    @required this.compress,
  }) : assert(directory != null),
       assert(cacheDirectory != null),
       assert(compress != null);
}

class ImageManager {
  static ImageManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).imageManager;

  ImageManager(AppManager app) : _appManager = app;

  final Log _log = Log("ImageManager");
  final String _tableName = "entity_image";
  final String _imagesDirName = "images";
  final int _imageCompressionQuality = 80;

  final AppManager _appManager;

  /// Memory cache of entity ID to image names.
  final Map<String, Set<String>> _entityImages = {};
  ThumbnailCache _thumbnailCache;
  ImageManagerProvider _provider;

  DataManager get _dataManager => _appManager.dataManager;

  Future<void> initialize({
    ImageManagerProvider provider,
  }) async {
    Directory imagesDir = Directory(
        (await getApplicationDocumentsDirectory()).path + "/$_imagesDirName");

    _provider = provider ?? ImageManagerProvider(
      directory: imagesDir,
      cacheDirectory: await getTemporaryDirectory(),
      compress: (context, fileName, quality, size) async {
        // TODO: this function should only be a wrapper for FlutterImageCompress
        // TODO: move pixel logic, etc. to instance method so it can be unit tested
        List<int> intBytes;
        String path = "${imagesDir.path}/$fileName";

        if (await File(path).exists()) {
          // TODO: Compression freezes UI until finished.
          // https://github.com/OpenFlutter/flutter_image_compress/issues/131
          if (size == null) {
            intBytes = await FlutterImageCompress.compressWithFile(path,
              quality: quality,
            );
          } else {
            int pixels = (MediaQuery.of(context).devicePixelRatio * size)
                .round();

            // Note that passing null minWidth/Height will not use the default
            // values in compressWithFile.
            intBytes = await FlutterImageCompress.compressWithFile(path,
              quality: quality,
              minWidth: pixels,
              minHeight: pixels,
            );
          }
        } else {
          _log.e("Attempting to compress file that doesn't exist: $path");
        }

        return Uint8List.fromList(intBytes);
      },
    );

    _thumbnailCache = await ThumbnailCache.create(
      rootCacheDir: _provider.cacheDirectory,
      compress: _provider.compress,
    );

    // Create images directory if it doesn't already exist.
    if (!await _provider.directory.exists()) {
      await _provider.directory.create();
    }

    // Fetch image map into memory.
    (await _fetchAll()).forEach((image) => _addToCache(image));
  }

  File _imageFile(String imageName) =>
      File("${_provider.directory.path}/$imageName");

  /// Returns a list of image names associated with the given [entityId].
  List<String> imageNames({
    @required String entityId,
  }) {
    return List.unmodifiable(_entityImages[entityId] ?? []);
  }

  /// Returns encoded image data with the given [fileName] at the given [size].
  /// The an image of [size] does not exist in the cache, the full image is
  /// returned.
  Future<Uint8List> image(BuildContext context, {
    @required String fileName,
    double size,
  }) async {
    return (await _thumbnailCache.image(context, fileName, size))
        ?? (await _imageFile(fileName).readAsBytes());
  }

  /// Returns a list of encoded images for the given [entityId] of the given
  /// [size]. This method will attempt to get the image from thumbnail cache
  /// before falling back on the full image.
  ///
  /// If there are no images associated with the given [entityId], an empty list
  /// is returned.
  Future<List<Uint8List>> images(BuildContext context, {
    @required String entityId,
    @required double size,
  }) async {
    if (isEmpty(entityId)) {
      _log.w("Attempting to fetch images for an empty entity ID");
      return [];
    }

    List<Uint8List> result = [];

    _entityImages[entityId]?.forEach((fileName) async {
      Uint8List image = await _thumbnailCache.image(context, fileName, size);

      if (image == null) {
        _log.e("Image $fileName doesn't exist in cache, and couldn't be "
            "created");
        image = await _imageFile(fileName).readAsBytes();
      }

      if (image != null) {
        result.add(image);
      }
    });

    return result;
  }

  void _addToCache(EntityImage image) {
    if (_entityImages[image.entityId] == null) {
      _entityImages[image.entityId] = <String>[].toSet();
    }
    _entityImages[image.entityId].add(image.imageName);
    _thumbnailCache.put(image.imageName);
  }

  /// Compresses the given image files, converts them to JPG format, and saves
  /// them to the app's sandbox if the file doesn't already exit.
  ///
  /// This method will update the database such that the given entity ID will
  /// only be associated with the given image files. Any previous association
  /// will be overridden.
  ///
  /// Files are named by the image's MD5 hash value to ensure uniqueness, and so
  /// that the same image isn't saved multiple times.
  Future<void> save(String entityId, List<File> files, {
    bool compress = true,
  }) async {
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
      List<int> jpgBytes;
      if (compress) {
        jpgBytes = await _provider.compress(null, basename(file.path),
            _imageCompressionQuality, null);
      } else {
        jpgBytes = await file.readAsBytes();
      }

      Digest digest = md5.convert(jpgBytes);
      var fileName = "${digest.toString()}.jpg";
      var newFile = _imageFile(fileName);

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
      // Remove old references.
      await _delete(entityId);

      // Update memory cache.
      dbImages.forEach((i) async => _addToCache(i));

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

    // Clear cache.
    _entityImages[entityId].forEach((fileName) =>
        _thumbnailCache.evict(fileName));
    _entityImages[entityId].clear();
  }

  Future<List<EntityImage>> _fetchAll() async {
    var results = await _dataManager.fetchAll(_tableName);
    return results.map((map) => EntityImage.fromMap(map)).toList();
  }
}