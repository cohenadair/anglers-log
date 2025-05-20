import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app_manager.dart';

class FilePickerWrapper {
  static FilePickerWrapper of(BuildContext context) =>
      AppManager.get.filePickerWrapper;

  Future<FilePickerResult?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) {
    return FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
    );
  }
}
