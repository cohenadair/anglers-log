import 'dart:io';

import 'package:protobuf/protobuf.dart';

import 'app_manager.dart';
import 'image_manager.dart';
import 'named_entity_manager.dart';

abstract class ImageEntityManager<T extends GeneratedMessage>
    extends NamedEntityManager<T> {
  void setImageName(T entity, String imageName);

  void clearImageName(T entity);

  ImageEntityManager(AppManager app) : super(app);

  ImageManager get _imageManager => appManager.imageManager;

  @override
  Future<bool> addOrUpdate(
    T entity, {
    File? imageFile,
    bool compressImages = true,
    bool notify = true,
  }) async {
    if (imageFile != null) {
      var savedImages =
          await _imageManager.save([imageFile], compress: compressImages);
      if (savedImages.isNotEmpty) {
        setImageName(entity, savedImages.first);
      } else {
        clearImageName(entity);
      }
    }

    return super.addOrUpdate(entity, notify: notify);
  }
}
