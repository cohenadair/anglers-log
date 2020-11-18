import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/app_manager.dart';
import 'package:provider/provider.dart';

class ImagePickerWrapper {
  static ImagePickerWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).imagePickerWrapper;

  Future<File> pickImage(ImageSource source) =>
      ImagePicker.pickImage(source: source);
}
