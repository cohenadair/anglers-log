import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:provider/provider.dart';

class FilePickerWrapper {
  static FilePickerWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).filePickerWrapper;

  Future<File> getFile({
    FileType type,
    String fileExtension,
  }) {
    return FilePicker.getFile(
      type: type,
      fileExtension: fileExtension,
    );
  }

  Future<List<File>> getMultiFile(FileType type) =>
      FilePicker.getMultiFile(type: type);
}
