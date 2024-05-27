import 'dart:io';

import '../log.dart';
import '../wrappers/io_wrapper.dart';

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

Future<bool> isConnected(IoWrapper io) async {
  // A quick DNS lookup will tell us if there's a current internet
  // connection.
  return (await io.lookup("example.com")).isNotEmpty ||
      (await io.lookup("google.com")).isNotEmpty;
}
