import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'auth_manager.dart';
import 'log.dart';
import 'subscription_manager.dart';
import 'wrappers/firebase_storage_wrapper.dart';
import 'wrappers/image_compress_wrapper.dart';
import 'wrappers/io_wrapper.dart';
import 'wrappers/path_provider_wrapper.dart';

class ImageManager {
  static ImageManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).imageManager;

  static final _dirNameImages = "2.0/images";
  static final _dirNameThumbs = "2.0/thumbs";

  static const _debug = false;
  static const _log = Log("ImageManager");

  static const _memoryCacheCapacity = 250;
  static const _imageCompressionQuality = 80;
  static const _thumbnailCompressionQuality = 50;

  /// A memory cache map of file name to [_CachedThumbnail] objects.
  final Map<String, _CachedThumbnail> _thumbnails =
      LinkedLruHashMap(maximumSize: _memoryCacheCapacity);

  final AppManager _appManager;

  late String _imagePath;
  late String _cachePath;

  AuthManager get _authManager => _appManager.authManager;

  SubscriptionManager get _subscriptionManager =>
      _appManager.subscriptionManager;

  FirebaseStorageWrapper get _firebaseStorageWrapper =>
      _appManager.firebaseStorageWrapper;

  ImageCompressWrapper get _imageCompressWrapper =>
      _appManager.imageCompressWrapper;

  IoWrapper get _ioWrapper => _appManager.ioWrapper;

  PathProviderWrapper get _pathProviderWrapper =>
      _appManager.pathProviderWrapper;

  ImageManager(this._appManager) {
    _subscriptionManager.stream.listen((_) => _onSubscriptionStreamUpdate());
  }

  Future<void> initialize() async {
    var imagesPath = await _pathProviderWrapper.appDocumentsPath;
    _imagePath = "$imagesPath/$_dirNameImages";

    var cachePath = await _pathProviderWrapper.temporaryPath;
    _cachePath = "$cachePath/$_dirNameThumbs";

    // Create directories if needed.
    await _ioWrapper.directory(_imagePath).create(recursive: true);
    await _ioWrapper.directory(_cachePath).create(recursive: true);
  }

  File _imageFile(String imageName) =>
      _ioWrapper.file("$_imagePath/$imageName");

  String _firebaseStoragePath(String fileName) =>
      "${_authManager.userId}/$fileName";

  /// Returns encoded image data with the given [fileName] at the given [size].
  /// If an image of [size] does not exist in the cache, the full image is
  /// returned.
  Future<Uint8List?> image(
    BuildContext context, {
    required String fileName,
    double? size,
  }) async {
    if (isEmpty(fileName)) {
      return null;
    }

    var file = _imageFile(fileName);

    // Download the image if it doesn't exist.
    if (!(await file.exists()) && _subscriptionManager.isPro) {
      try {
        _log.d("Local file not found, downloading...");

        await _firebaseStorageWrapper
            .ref(_firebaseStoragePath(fileName))
            .writeToFile(file);

        _log.d("Download complete");
      } on FirebaseException catch (e) {
        _log.e("Error downloading image: $e");
      }
    }

    // Return the correct thumbnail if it exists.
    var thumb = await _thumbnail(context, fileName, size);
    if (thumb != null) {
      return thumb;
    }

    // Fallback on full image if thumbnail couldn't be created.
    if (await file.exists()) {
      return await file.readAsBytes();
    }

    // No image is available.
    return null;
  }

  /// Returns a map of file-to-encoded images for the given [names] of the given
  /// [size]. This method will attempt to get the image from thumbnail cache
  /// before falling back on the full image.
  ///
  /// If there are no images associated with the given [names], an empty map
  /// is returned.
  Future<Map<File, Uint8List>> images(
    BuildContext context, {
    required List<String> imageNames,
    double? size,
  }) async {
    if (imageNames.isEmpty) {
      return {};
    }

    var result = <File, Uint8List>{};
    for (var fileName in imageNames) {
      _addToCache(fileName);

      var bytes = await image(
        context,
        fileName: fileName,
        size: size,
      );

      if (bytes != null) {
        result[_imageFile(fileName)] = bytes;
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

  Future<void> _upload(FileSystemEntity image) async {
    if (!_subscriptionManager.isPro) {
      _log.d("User isn't pro, skipping image upload");
      return;
    }

    var imageName = basename(image.path);

    if (!image.existsSync()) {
      _log.d("Can't upload file that doesn't exist: $imageName");
      return;
    }

    try {
      _log.d("Uploading image $imageName...");

      await _firebaseStorageWrapper
          .ref(_firebaseStoragePath(imageName))
          .putFile(image as File);

      _log.d("Upload complete");
    } on FirebaseException catch (e) {
      _log.e("Error uploading image: $e");
    }
  }

  /// Returns a list of file names that were saved to disk.
  ///
  /// Compresses the given image files, converts them to JPG format, and saves
  /// them to the app's sandbox if the file doesn't already exit.
  ///
  /// This method will update the database such that the given entity ID will
  /// only be associated with the given image files. Any previous associations
  /// will be overridden.
  ///
  /// Files are named by the image's MD5 hash value to ensure uniqueness, and so
  /// that the same image isn't saved multiple times.
  Future<List<String>> save(
    List<File> files, {
    bool compress = true,
  }) async {
    if (files.isEmpty) {
      return [];
    }

    var result = <String>[];

    for (var file in files) {
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
      _upload(newFile);
    }

    return result;
  }

  Future<Uint8List> _compress(
      BuildContext? context, File source, int quality, double? size) async {
    var intBytes = <int>[];

    if (await source.exists()) {
      double? pixels;
      if (size != null) {
        pixels = MediaQuery.of(context!).devicePixelRatio * size;
      }
      var bytes = await _imageCompressWrapper.compress(
          source.path, quality, pixels?.round());
      if (bytes != null) {
        intBytes = bytes;
      }
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
  Future<Uint8List?> _thumbnail(
      BuildContext context, String name, double? size) async {
    if (isEmpty(name) || size == null) {
      return null;
    }

    var fileName = name;
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
        var imageFile = _imageFile(fileName);

        if (!(await imageFile.exists())) {
          _log.d("Can't create thumbnail from file that doesn't exist");
          return null;
        }

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

  /// Uploads to Firebase any local images that don't exist in Firebase.
  void _onSubscriptionStreamUpdate() {
    if (_subscriptionManager.isFree) {
      return;
    }

    _log.d("User is pro, checking for images that need to be uploaded...");

    _ioWrapper.directory(_imagePath).list().forEach((file) async {
      var fileName = basename(file.path);

      // Firebase storage doesn't have an "exists" method, so getMetadata is
      // used, which will throw an exception if the file doesn't exist.
      try {
        await _firebaseStorageWrapper
            .ref(_firebaseStoragePath(fileName))
            .getMetadata();
      } on FirebaseException catch (_) {
        // Note that although this exception is caught, the Android stacktrace
        // is still printed to the console. The logs can be safely ignored.
        _log.d("File doesn't exist in the cloud: $fileName");
        _upload(file);
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

  Uint8List? thumbnail(double size) => _thumbnails[size];

  int get numberOfBytes => _thumbnails.values
      .fold<int>(0, (previousValue, bytes) => previousValue += bytes.length);

  int get numberOfImages => _thumbnails.length;
}
