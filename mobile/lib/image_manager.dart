import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/entity_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/strings.dart';
import 'package:sqflite/sqflite.dart';

class ImageManager {
  static ImageManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).imageManager;

  static final _debug = false;
  static final _log = Log("ImageManager");

  static final _tableName = "entity_image";
  static final _memoryCacheCapacity = 250;
  static final _imageCompressionQuality = 80;
  static final _thumbnailCompressionQuality = 50;

  ImageManager(AppManager app) : _appManager = app;

  final AppManager _appManager;

  /// Memory cache of entity ID to image names, synced with the database.
  final Map<String, Set<String>> _entityImageNames = {};

  /// A memory cache map of file name to [_CachedThumbnail] objects.
  final Map<String, _CachedThumbnail> _thumbnails =
      LinkedLruHashMap(maximumSize: _memoryCacheCapacity);

  ImageManagerDelegate _delegate;

  DataManager get _dataManager => _appManager.dataManager;

  Future<void> initialize({
    ImageManagerDelegate delegate,
  }) async {
    _delegate = delegate;
    if (_delegate == null) {
      _delegate = await ImageManagerDelegate.create();
    }

    // Create directories if needed.
    await _delegate.directory(_delegate.imagePath).create(recursive: true);
    await _delegate.directory(_delegate.cachePath).create(recursive: true);

    // Fetch image map from database.
    (await _fetchAll()).forEach((image) => _addToCache(image));
  }

  File _imageFile(String imageName) =>
      _delegate.file("${_delegate.imagePath}/$imageName");

  /// Returns a list of image names associated with the given [entityId].
  List<String> imageNames({
    @required String entityId,
  }) {
    return List.unmodifiable(_entityImageNames[entityId] ?? []);
  }

  /// Returns encoded image data with the given [fileName] at the given [size].
  /// If an image of [size] does not exist in the cache, the full image is
  /// returned.
  Future<Uint8List> image(BuildContext context, {
    @required String fileName,
    double size,
  }) async {
    if (isEmpty(fileName)) {
      return null;
    }

    Uint8List thumb = await _thumbnail(context, fileName, size);
    if (thumb == null) {
      File file = _imageFile(fileName);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    }
    return thumb;
  }

  /// Returns a list of encoded images for the given [entityId] of the given
  /// [size]. This method will attempt to get the image from thumbnail cache
  /// before falling back on the full image.
  ///
  /// If there are no images associated with the given [entityId], an empty list
  /// is returned.
  Future<List<Uint8List>> images(BuildContext context, {
    @required String entityId,
    double size,
  }) async {
    if (isEmpty(entityId)) {
      _log.w("Attempting to fetch images for an empty entity ID");
      return [];
    }

    List<Uint8List> result = [];
    if (_entityImageNames[entityId] == null) {
      return result;
    }

    for (var fileName in _entityImageNames[entityId]) {
      Uint8List bytes = await image(context,
        fileName: fileName,
        size: size,
      );

      if (bytes != null) {
        result.add(bytes);
      } else {
        _log.e("Image $fileName doesn't exist in cache, and couldn't be "
            "created");
      }
    }

    return result;
  }

  void _addToCache(EntityImage image) {
    if (_entityImageNames[image.entityId] == null) {
      _entityImageNames[image.entityId] = <String>[].toSet();
    }
    _entityImageNames[image.entityId].add(image.imageName);
    _thumbnails[image.imageName] = _CachedThumbnail(image.imageName);
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
      if (file.path.contains(_delegate.imagePath) && await file.exists()) {
        _log.d("File exists, nothing to do");
        continue;
      }

      // Compress first, so image MD5 hashes are equal to existing files.
      List<int> jpgBytes;
      if (compress) {
        jpgBytes = await _compress(null, file, _imageCompressionQuality,
            null);
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
          await newFile.writeAsBytes(jpgBytes, flush: true);
        } on FileSystemException catch (e) {
          _log.e("Error copying image to ${newFile.path}: $e}");
          continue;
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

      // Create database entries.
      List<dynamic> batchResult = await _dataManager.commitBatch((batch) {
        dbImages.forEach((i) =>
            batch.insert(_tableName, i.toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace));
      });

      if (batchResult.isEmpty || batchResult.length != dbImages.length) {
        _log.e("Error saving images to database");
      } else {
        // Database write was successful, update memory cache.
        dbImages.forEach((i) async => _addToCache(i));
      }
    }
  }

  Future<Uint8List> _compress(BuildContext context, File source, int quality,
      double size) async
  {
    List<int> intBytes = [];

    if (await source.exists()) {
      double pixels;
      if (size != null) {
        double pixelRatio = MediaQuery.of(context).devicePixelRatio;
        pixels = size == null ? null : pixelRatio * size;
      }
      intBytes = await _delegate.compress(source.path, quality,
          pixels?.round());
    } else {
      _log.e("Attempting to compress file that doesn't exist: "
          "${source.path}");
    }

    return Uint8List.fromList(intBytes);
  }

  /// Returns the image of a given [size] for the given [fileName], or null
  /// if one doesn't exist or an error occurs.
  ///
  /// If the image doesn't exist in the memory or file system cache,
  /// [_delegate.compress] is invoked and the result is saved to the file system
  /// and added to the memory cache.
  Future<Uint8List> _thumbnail(BuildContext context, String fileName,
      double size) async
  {
    if (isEmpty(fileName) || size == null) {
      return null;
    }

    _CachedThumbnail cachedImage = _thumbnails[fileName];

    // If image exists in memory cache, return it.
    if (cachedImage != null && cachedImage.thumbnail(size) != null) {
      if (_debug) {
        _log.d("Thumbnail exists in memory cache");
      }
      return cachedImage.thumbnail(size);
    }

    if (cachedImage == null) {
      cachedImage = _CachedThumbnail(fileName);
    }

    // Create sized directory if it doesn't exist.
    var sizePath = "${_delegate.cachePath}/${size.round()}";
    await _delegate.directory(sizePath).create(recursive: true);

    var thumbnail = _delegate.file("$sizePath/$fileName");
    if (!await thumbnail.exists()) {
      if (_debug) {
        _log.d("Thumbnail does not exist in file system, writing to file...");
      }

      try {
        await thumbnail.writeAsBytes(
          await _compress(context, _imageFile(fileName),
              _thumbnailCompressionQuality, size),
          flush: true,
        );
      } on FileSystemException catch (e) {
        _log.e("Error writing thumbnail to ${thumbnail.path}: $e}");
        return null;
      }

      if (_debug) {
        _log.d("Thumbnail $fileName($size) written to file");
      }
    } else {
      if (_debug) {
        _log.d("Thumbnail exists in file system");
      }
    }

    // Update memory cache.
    cachedImage.put(size, await thumbnail.readAsBytes());
    _thumbnails[fileName] = cachedImage;

    // Log some useful memory impact data.
    if (_debug) {
      int totalBytes = 0;
      int totalImages = 0;
      _thumbnails.values.forEach((cachedThumb) {
        totalBytes += cachedThumb.numberOfBytes;
        totalImages += cachedThumb.numberOfImages;
      });
      _log.d("Cache size: images($totalImages), "
          "memory(${totalBytes / 1000 / 1000} MB)");
    }

    return cachedImage.thumbnail(size);
  }

  /// Deletes all images associated with the given entity ID. This applies
  /// only to the database and memory cache; not the file system. Any given
  /// file could be used in other entities.
  Future<void> _delete(String entityId) async {
    Set<String> imageNames = _entityImageNames[entityId] ?? {};
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
    _entityImageNames[entityId].forEach((fileName) =>
        _thumbnails.remove(fileName));
    _entityImageNames[entityId].clear();
  }

  Future<List<EntityImage>> _fetchAll() async {
    var results = await _dataManager.fetchAll(_tableName);
    return results.map((map) => EntityImage.fromMap(map)).toList();
  }
}

class ImageManagerDelegate {
  static final _imagesDirName = "images";
  static final _thumbnailsDirName = "thumbs";

  static Future<ImageManagerDelegate> create() async {
    var imagePath = (await getApplicationDocumentsDirectory()).path;
    var cachePath = (await getTemporaryDirectory()).path;
    return ImageManagerDelegate._("$cachePath/$_thumbnailsDirName",
        "$imagePath/$_imagesDirName");
  }

  final String cachePath;
  final String imagePath;

  ImageManagerDelegate._(this.cachePath, this.imagePath);

  Directory directory(String path) => Directory(path);
  File file(String path) => File(path);

  Future<Uint8List> compress(String path, int quality, int size) async {
    // TODO: Compression freezes UI until finished.
    // https://github.com/OpenFlutter/flutter_image_compress/issues/131
    if (size == null) {
      // Note that passing null minWidth/minHeight will not use the
      // default values in compressWithFile, so we have to explicitly
      // exclude minWidth/minHeight when we don't have a size.
      return Uint8List.fromList(await FlutterImageCompress
          .compressWithFile(path, quality: quality));
    }

    return Uint8List.fromList(await FlutterImageCompress.compressWithFile(
      path,
      quality: quality,
      minWidth: size.round(),
      minHeight: size.round(),
    ));
  }
}

/// Stores image thumbnails of various sizes in memory as [Uint8List] objects.
class _CachedThumbnail {
  final String name;
  final Map<double, Uint8List> _thumbnails = {};

  _CachedThumbnail(this.name);

  void put(double size, Uint8List bytes) {
    _thumbnails[size] = bytes;
  }

  Uint8List thumbnail(double size) => _thumbnails[size];

  int get numberOfBytes => _thumbnails.values.fold<int>(
      0, (previousValue, bytes) => previousValue += bytes?.length ?? 0);

  int get numberOfImages => _thumbnails.length;
}