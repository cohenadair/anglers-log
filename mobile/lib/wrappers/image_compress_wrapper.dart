import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class ImageCompressWrapper {
  static ImageCompressWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).imageCompressWrapper;

  Future<Uint8List?> compress(String path, int quality, int? size) async {
    // TODO: Compression freezes UI until finished.
    // https://github.com/OpenFlutter/flutter_image_compress/issues/131
    if (size == null) {
      // Note that passing null minWidth/minHeight will not use the
      // default values in compressWithFile, so we have to explicitly
      // exclude minWidth/minHeight when we don't have a size.
      return await FlutterImageCompress.compressWithFile(path,
          quality: quality);
    }

    return await FlutterImageCompress.compressWithFile(
      path,
      quality: quality,
      minWidth: size.round(),
      minHeight: size.round(),
    );
  }
}
