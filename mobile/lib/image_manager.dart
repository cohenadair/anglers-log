import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'catch_manager.dart';
import 'log.dart';
import 'wrappers/image_compress_wrapper.dart';
import 'wrappers/io_wrapper.dart';
import 'wrappers/path_provider_wrapper.dart';

class ImageManager {
  static ImageManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).imageManager;

  static final _dirNameImages = "images";
  static final _dirNameThumbs = "thumbs";

  static const _debug = false;
  static const _log = Log("ImageManager");

  static const _memoryCacheCapacity = 250;
  static const _imageCompressionQuality = 80;
  static const _thumbnailCompressionQuality = 50;

  /// A memory cache map of file name to [_CachedThumbnail] objects.
  final Map<String, _CachedThumbnail> _thumbnails =
      LinkedLruHashMap(maximumSize: _memoryCacheCapacity);

  final AppManager _appManager;

  String _imagePath;
  String _cachePath;

  CatchManager get _catchManager => _appManager.catchManager;
  ImageCompressWrapper get _imageCompressWrapper =>
      _appManager.imageCompressWrapper;
  IoWrapper get _ioWrapper => _appManager.ioWrapper;
  PathProviderWrapper get _pathProviderWrapper =>
      _appManager.pathProviderWrapper;

  ImageManager(this._appManager);

  Future<void> initialize() async {
    var imagesPath = await _pathProviderWrapper.appDocumentsPath;
    _imagePath = "$imagesPath/$_dirNameImages";

    var cachePath = await _pathProviderWrapper.temporaryPath;
    _cachePath = "$cachePath/$_dirNameThumbs";

    // Create directories if needed.
    await _ioWrapper.directory(_imagePath).create(recursive: true);
    await _ioWrapper.directory(_cachePath).create(recursive: true);

    // Cleanup images that are no longer used.
    await _clearStaleImages();
  }

  File _imageFile(String imageName) =>
      _ioWrapper.file("$_imagePath/$imageName");

  /// Returns encoded image data with the given [fileName] at the given [size].
  /// If an image of [size] does not exist in the cache, the full image is
  /// returned.
  Future<Uint8List> image(
    BuildContext context, {
    @required String fileName,
    double size,
  }) async {
    if (isEmpty(fileName)) {
      return null;
    }

    var thumb = await _thumbnail(context, fileName, size);
    if (thumb == null) {
      var file = _imageFile(fileName);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    }
    return thumb;
  }

  /// Returns a list of encoded images for the given [names] of the given
  /// [size]. This method will attempt to get the image from thumbnail cache
  /// before falling back on the full image.
  ///
  /// If there are no images associated with the given [names], an empty list
  /// is returned.
  Future<List<Uint8List>> images(
    BuildContext context, {
    @required List<String> imageNames,
    double size,
  }) async {
    if (imageNames == null || imageNames.isEmpty) {
      return [];
    }

    var result = <Uint8List>[];
    for (var fileName in imageNames) {
      _addToCache(fileName);

      var bytes = await image(
        context,
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

  void _addToCache(String fileName) {
    _thumbnails.putIfAbsent(fileName, () => _CachedThumbnail(fileName));
  }

  /// Returns a list of file names that were saved to disk.
  ///
  /// Compresses the given image files, converts them to JPG format, and saves
  /// them to the app's sandbox if the file doesn't already exit.
  ///
  /// This method will update the database such that the given entity ID will
  /// only be associated with the given image files. Any previous association
  /// will be overridden.
  ///
  /// Files are named by the image's MD5 hash value to ensure uniqueness, and so
  /// that the same image isn't saved multiple times.
  Future<List<String>> save(
    List<File> files, {
    bool compress = true,
  }) async {
    if (files == null || files.isEmpty) {
      return [];
    }

    var result = <String>[];

    for (var file in files) {
      // This can happen if an entity is edited, but the images associated with
      // that entity didn't change. In these cases, there are no "files" to
      // copy.
      if (file == null) {
        continue;
      }

      // If the file already exists in the app's sandbox, don't copy it again.
      if (file.path.contains(_imagePath) && await file.exists()) {
        _log.d("File exists, nothing to do");
        result.add(basename(file.path));
        continue;
      }

      // Compress first, so image MD5 hashes are equal to existing files.
      List<int> jpgBytes;
      if (compress) {
        jpgBytes = await _compress(null, file, _imageCompressionQuality, null);
      } else {
        jpgBytes = await file.readAsBytes();
      }

      var digest = md5.convert(jpgBytes);
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

      result.add(fileName);
      _addToCache(fileName);
    }

    return result;
  }

  /// Returns a Dart [ui.Image] object with the given [fileName] and [size].
  /// Returns null if the image doesn't exist.
  Future<ui.Image> dartImage(
      BuildContext context, String fileName, double size) async {
    var bytes = await image(
      context,
      fileName: fileName,
      size: size,
    );

    if (bytes == null || bytes.isEmpty) {
      return null;
    }

    return (await (await ui.instantiateImageCodec(bytes)).getNextFrame()).image;
  }

  Future<Uint8List> _compress(
      BuildContext context, File source, int quality, double size) async {
    var intBytes = <int>[];

    if (await source.exists()) {
      double pixels;
      if (size != null) {
        var pixelRatio = MediaQuery.of(context).devicePixelRatio;
        pixels = size == null ? null : pixelRatio * size;
      }
      intBytes = await _imageCompressWrapper.compress(
          source.path, quality, pixels?.round());
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
  Future<Uint8List> _thumbnail(
      BuildContext context, String fileName, double size) async {
    if (isEmpty(fileName) || size == null) {
      return null;
    }

    var cachedImage = _thumbnails[fileName];

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
    var sizePath = "$_cachePath/${size.round()}";
    await _ioWrapper.directory(sizePath).create(recursive: true);

    var thumbnail = _ioWrapper.file("$sizePath/$fileName");
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
      var totalBytes = 0;
      var totalImages = 0;
      for (var cachedThumb in _thumbnails.values) {
        totalBytes += cachedThumb.numberOfBytes;
        totalImages += cachedThumb.numberOfImages;
      }
      _log.d("Cache size: images($totalImages), "
          "memory(${totalBytes / 1000 / 1000} MB)");
    }

    return cachedImage.thumbnail(size);
  }

  /// Deletes images that are no longer used from memory cache and file
  /// system.
  Future<void> _clearStaleImages() async {
    await _ioWrapper.directory(_imagePath).list().forEach((entity) {
      var name = basename(entity.path);
      var found = false;
      for (var cat in _catchManager.list()) {
        // Image found, continue on to the next image.
        if (cat.imageNames.contains(name)) {
          found = true;
          break;
        }
      }

      // Image isn't found, delete it.
      if (!found) {
        entity.deleteSync();
        _thumbnails.remove(name);
        _log.d("Deleted stale image $name");
      }
    });
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
