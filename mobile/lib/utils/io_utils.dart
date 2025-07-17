import 'dart:io';

import '../log.dart';

const _log = Log("IoUtils");

Future<void> safeDeleteFileSystemEntity(FileSystemEntity entity) async {
  if (!entity.existsSync()) {
    return;
  }

  try {
    entity.deleteSync(recursive: true);
  } on Exception catch (ex, _) {
    _log.w("Error deleting file at path ${entity.path}: $ex");
  }
}
