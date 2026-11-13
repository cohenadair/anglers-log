import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../app_manager.dart';

class ImagePickerWrapper {
  static ImagePickerWrapper of(BuildContext context) =>
      AppManager.get.imagePickerWrapper;

  Future<XFile?> pickImage(ImageSource source) =>
      ImagePicker().pickImage(source: source);

  Future<List<XFile>> pickMultiImage() => ImagePicker().pickMultiImage();
}
