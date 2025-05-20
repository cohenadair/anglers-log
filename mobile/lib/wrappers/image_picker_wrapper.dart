import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_manager.dart';

class ImagePickerWrapper {
  static ImagePickerWrapper of(BuildContext context) =>
      AppManager.get.imagePickerWrapper;

  Future<XFile?> pickImage(ImageSource source) =>
      ImagePicker().pickImage(source: source);
}
