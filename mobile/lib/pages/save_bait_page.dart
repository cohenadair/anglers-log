import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/photo_input.dart';
import 'package:mobile/widgets/widget.dart';

class SaveBaitPage extends StatefulWidget {
  @override
  _SaveBaitPageState createState() => _SaveBaitPageState();
}

class _SaveBaitPageState extends State<SaveBaitPage> {
  static const String photoId = "photo";
  static const String photosId = "photos";

  ImagePickerPageResult _currentImage;
  List<ImagePickerPageResult> _currentImages = [];

  final Map<String, InputData> _allInputFields = {
    photoId: InputData(
      id: photoId,
      label: (context) => Strings.of(context).inputPhotoLabel,
      controller: ImageInputController(),
      removable: false,
    ),
    photosId: InputData(
      id: photosId,
      label: (context) => Strings.of(context).inputPhotosLabel,
      controller: ImageInputController(),
      removable: false,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      padding: insetsZero,
      allFields: _allInputFields,
      initialFields: {
        photoId: _allInputFields[photoId],
        photosId: _allInputFields[photosId],
      },
      onBuildField: (id, isRemovingFields) {
        switch (id) {
          case photoId: return PhotoInput.single(
            padding: insetsDefault,
            enabled: !isRemovingFields,
            currentImage: _currentImage,
            onImagePicked: (image) {
              if (image != null) {
                setState(() {
                  _currentImage = image;
                });
              }
            },
          );
          case photosId: return PhotoInput(
            padding: insetsDefault,
            enabled: !isRemovingFields,
            initialImages: _currentImages,
            onImagesPicked: (images) {
              if (images != null) {
                setState(() {
                  _currentImages = images;
                });
              }
            },
          );
          default:
            print("Unknown input key: $id");
            return Empty();
        }
      },
      onSave: _save,
    );
  }

  void _save(Map<String, InputData> result) {
    print(result);
  }
}