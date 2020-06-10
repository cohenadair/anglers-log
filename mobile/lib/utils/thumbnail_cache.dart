import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile/log.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/strings.dart';

/// A function for compressing and scaling thumbnails.
typedef Future<Uint8List> CompressCallback(BuildContext context,
    String fileName, int quality, double size);

/// An image caching system that stores recently used images in memory, and
/// everything else in file storage.
///
/// The [ThumbnailCache] class does not access or modify full image files.
/// It only stores thumbnails that are identified by their unique file names.
/// All full image file management must be done elsewhere.
///
/// A "thumbnail" is defined as a scaled-down version of a full image.
class ThumbnailCache {
  static final _debug = true;
  static final _capacity = 250;
  static final _thumbnailsDirName = "thumbs";
  static final _thumbnailCompressionQuality = 50;

  /// Creates an instance of [ThumbnailCache], with all required file system
  /// directories initialized and created.
  ///
  /// [rootCacheDir] is the app's temporary directory, and is used to save all
  /// thumbnail images.
  static Future<ThumbnailCache> create({
    @required Directory rootCacheDir,
    CompressCallback compress,
  }) async {
    assert(rootCacheDir != null);

    // Create cache directory if it doesn't already exist.
    var thumbsDir = Directory("${rootCacheDir.path}/$_thumbnailsDirName");
    if (!await thumbsDir.exists()) {
      await thumbsDir.create();
    }

    return ThumbnailCache._(thumbsDir, compress);
  }

  final Log _log = Log("ThumbnailCache");

  final Directory _cacheDir;
  final CompressCallback _compressCallback;

  /// An file name to [_CachedThumbnail] map.
  final Map<String, _CachedThumbnail> _thumbnails =
      LinkedLruHashMap(maximumSize: _capacity);

  ThumbnailCache._(this._cacheDir, this._compressCallback);

  /// Adds an entry into the cache with the given [fileName]. Initially, the
  /// entry added does not have any thumbnails. Thumbnails are loaded into
  /// memory when needed.
  void put(String fileName) {
    _thumbnails[fileName] = _CachedThumbnail(fileName);
    if (_debug) {
      _log.d("Add to cache; new length: ${_thumbnails.length}");
    }
  }

  /// Removes [fileName] from the cache.
  void evict(String fileName) {
    _thumbnails.remove(fileName);
    if (_debug) {
      _log.d("Evict from cache; new length: ${_thumbnails.length}");
    }
  }

  /// Returns the image of a given [size] for the given [fileName], or null
  /// if one doesn't exist or an error occurs.
  ///
  /// If the image doesn't exist in the memory or file system cache,
  /// [_compressCallback] is invoked and the result is saved to the file system
  /// and added to the memory cache.
  Future<Uint8List> image(BuildContext context, String fileName, double size)
      async
  {
    if (isEmpty(fileName) || size == null) {
      _log.d("Cannot fetch cached image: empty name or null size");
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
    var sizeDir =
        Directory("${_cacheDir.path}/${size.round()}");
    if (!await sizeDir.exists()) {
      await sizeDir.create();
    }

    var thumbnail = File("${sizeDir.path}/$fileName");

    if (!await thumbnail.exists()) {
      if (_debug) {
        _log.d("Thumbnail does not exist in file system, writing to file...");
      }

      try {
        await thumbnail.writeAsBytes(await _compressCallback(context, fileName,
          _thumbnailCompressionQuality, size), flush: true);
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