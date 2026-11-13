import 'package:material_ui/material_ui.dart';
import 'package:native_exif/native_exif.dart';

import '../app_manager.dart';

class ExifWrapper {
  static ExifWrapper of(BuildContext context) => AppManager.get.exifWrapper;

  Future<Exif> fromPath(String path) => Exif.fromPath(path);
}
