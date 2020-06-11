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

/// A function for compressing and scaling thumbnails.
typedef Future<Uint8List> ImageManagerCompressionCallback(String path,
    int quality, int size);

/// A class used for dependency injection for non-Anglers' Log dependencies.
class ImageManagerDelegate {
  /// The directory in which to save images. If it doesn't exist, it will be
  /// created.
  final Directory imageDir;

  /// The director in which to save thumbnails. If it doesn't exist, it will be
  /// created.
  final Directory cacheDir;

  /// See [ImageManagerCompressionCallback].
  final ImageManagerCompressionCallback compress;

  ImageManagerDelegate({
    @required this.imageDir,
    @required this.cacheDir,
    @required this.compress,
  }) : assert(imageDir != null),
       assert(cacheDir != null),
       assert(compress != null);
}

class ImageManager {
  static ImageManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).imageManager;

  ImageManager(AppManager app) : _appManager = app;

  static final _debug = true;
  static final _log = Log("ImageManager");

  static final _tableName = "entity_image";
  static final _memoryCacheCapacity = 250;
  static final _imagesDirName = "images";
  static final _imageCompressionQuality = 80;
  static final _thumbnailsDirName = "thumbs";
  static final _thumbnailCompressionQuality = 50;

  final AppManager _appManager;

  /// Memory cache of entity ID to image names.
  final Map<String, Set<String>> _entityImageNames = {};

  /// A file name to [_CachedThumbnail] map.
  final Map<String, _CachedThumbnail> _thumbnails =
      LinkedLruHashMap(maximumSize: _memoryCacheCapacity);

  ImageManagerDelegate _provider;

  DataManager get _dataManager => _appManager.dataManager;

  Future<void> initialize({
    ImageManagerDelegate provider,
  }) async {
    _provider = provider;
    if (_provider == null) {
      _provider = await _defaultDelegate;
    }

    // Create cache directory if it doesn't already exist.
    if (!await _provider.cacheDir.exists()) {
      await _provider.cacheDir.create();
    }

    // Create image directory if it doesn't already exist.
    if (!await _provider.imageDir.exists()) {
      await _provider.imageDir.create();
    }

    // Fetch image map from database.
    (await _fetchAll()).forEach((image) => _addToCache(image));
  }

  File _imageFile(String imageName) =>
      File("${_provider.imageDir.path}/$imageName");

  /// Returns a list of image names associated with the given [entityId].
  List<String> imageNames({
    @required String entityId,
  }) {
    return List.unmodifiable(_entityImageNames[entityId] ?? []);
  }

  /// Returns encoded image data with the given [fileName] at the given [size].
  /// The an image of [size] does not exist in the cache, the full image is
  /// returned.
  Future<Uint8List> image(BuildContext context, {
    @required String fileName,
    double size,
  }) async {
    return (await _thumbnail(context, fileName, size))
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

    _entityImageNames[entityId]?.forEach((fileName) async {
      Uint8List image = await _thumbnail(context, fileName, size);

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
      if (file.path.contains(_provider.imageDir.path) &&
          await file.exists()) {
        _log.d("File exists, nothing to do");
        continue;
      }

      // Compress first, so image MD5 hashes are equal to existing files.
      List<int> jpgBytes;
      if (compress) {
        jpgBytes = await _compress(null, file.path, _imageCompressionQuality,
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
        dbImages.forEach((i) =>
            batch.insert(_tableName, i.toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace));
      });

      if (batchResult.isEmpty || batchResult.length != dbImages.length) {
        _log.e("Error saving images to database");
      }
    }
  }

  Future<Uint8List> _compress(BuildContext context, String path,
      int quality, double size) async
  {
    List<int> intBytes;

    if (await File(path).exists()) {
      double pixels;
      if (size != null) {
        double pixelRatio = MediaQuery.of(context).devicePixelRatio;
        pixels = size == null ? null : pixelRatio * size;
      }
      intBytes = await _provider.compress(path, quality, pixels.round());
    } else {
      _log.e("Attempting to compress file that doesn't exist: $path");
    }

    return Uint8List.fromList(intBytes);
  }

  /// Returns the image of a given [size] for the given [fileName], or null
  /// if one doesn't exist or an error occurs.
  ///
  /// If the image doesn't exist in the memory or file system cache,
  /// [_provider.compress] is invoked and the result is saved to the file system
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

    // Create the sized directory if it doesn't exist.
    var sizeDir = Directory("${_provider.cacheDir.path}/${size.round()}");
    if (!await sizeDir.exists()) {
      await sizeDir.create();
    }

    var thumbnail = File("${sizeDir.path}/$fileName");

    if (!await thumbnail.exists()) {
      if (_debug) {
        _log.d("Thumbnail does not exist in file system, writing to file...");
      }

      try {
        await thumbnail.writeAsBytes(
          await _compress(context, _imageFile(fileName).path,
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

  Future<ImageManagerDelegate> get _defaultDelegate async {
    var imagePath = (await getApplicationDocumentsDirectory()).path;
    var cachePath = (await getTemporaryDirectory()).path;

    return ImageManagerDelegate(
      imageDir: Directory("$imagePath/$_imagesDirName"),
      cacheDir: Directory("$cachePath/$_thumbnailsDirName"),
      compress: (path, quality, size) async {
        List<int> intBytes;

        // TODO: Compression freezes UI until finished.
        // https://github.com/OpenFlutter/flutter_image_compress/issues/131
        if (size == null) {
          // Note that passing null minWidth/minHeight will not use the
          // default values in compressWithFile, so we have to explicitly
          // exclude minWidth/minHeight when we don't have a size.
          intBytes = await FlutterImageCompress.compressWithFile(path,
            quality: quality,
          );
        } else {
          intBytes = await FlutterImageCompress.compressWithFile(path,
            quality: quality,
            minWidth: size.round(),
            minHeight: size.round(),
          );
        }

        return Uint8List.fromList(intBytes);
      },
    );
  }
}

class _CachedThumbnail {
  final String name;
  final Map<double, Uint8List> _thumbnails = {};

  _CachedThumbnail(this.name);

  void put(double size, Uint8List bytes) {
    _thumbnails[size] = bytes;
  }

  Uint8List thumbnail(double size) => _thumbnails[size];

  int get numberOfBytes => _thumbnails.values.fold<int>(
      0, (previousValue, bytes) => previousValue += bytes.length);

  int get numberOfImages => _thumbnails.length;
}