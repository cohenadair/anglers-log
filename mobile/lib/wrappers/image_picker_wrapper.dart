import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class ImagePickerWrapper {
  static ImagePickerWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).imagePickerWrapper;

  Future<PickedFile> getImage(ImageSource source) =>
      ImagePicker().getImage(source: source);
}
