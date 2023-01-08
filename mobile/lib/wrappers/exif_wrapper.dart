import 'package:flutter/material.dart';
import 'package:native_exif/native_exif.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class ExifWrapper {
  static ExifWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).exifWrapper;

  Future<Exif> fromPath(String path) => Exif.fromPath(path);
}
