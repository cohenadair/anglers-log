import 'package:flutter/material.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/photo_input.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class SaveBaitPage extends StatefulWidget {
  final Bait oldBait;

  SaveBaitPage({this.oldBait});

  @override
  _SaveBaitPageState createState() => _SaveBaitPageState();
}

class _SaveBaitPageState extends State<SaveBaitPage> {
  static const String baitCategoryId = "bait_category";
  static const String photoId = "photo";

  final _log = Log("SaveBaitPage");
  List<BaitCategory> _categories = [];

  bool get editing => widget.oldBait != null;

  final Map<String, InputData> _allInputFields = {
    baitCategoryId: InputData(
      id: baitCategoryId,
      label: (context) => Strings.of(context).saveBaitPageCategoryLabel,
      controller: BaitCategoryController(),
      removable: true,
    ),
    photoId: InputData(
      id: photoId,
      label: (context) => Strings.of(context).inputPhotoLabel,
      controller: ImageInputController(),
      removable: true,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      padding: insetsZero,
      allFields: _allInputFields,
      initialFields: {
        baitCategoryId: _allInputFields[baitCategoryId],
        photoId: _allInputFields[photoId],
      },
      onBuildField: (id, isRemovingFields) {
        switch (id) {
          case baitCategoryId: return _buildCategoryPicker(isRemovingFields);
          case photoId: return _buildPhotoPicker(isRemovingFields);
          default:
            print("Unknown input key: $id");
            return Empty();
        }
      },
      onSave: _save,
    );
  }

  Widget _buildCategoryPicker(bool isRemovingFields) {
    return ListPickerInput<BaitCategory>.single(
      enabled: !isRemovingFields,
      labelText: Strings.of(context).saveBaitPageCategoryLabel,
      futureStreamHolder: BaitCategoriesFutureStreamHolder(context,
        onUpdate: (categories) {
          _log.d("Bait categories updated...");
          _categories = categories;
        },
      ),
      itemBuilder: () => _categories.map((e) => ListPickerInputItem(
        title: e.name,
        value: e,
      )).toList(),
      onChanged: (category) =>
          _allInputFields[baitCategoryId].controller.value = category,
      addItemHelper: ListPickerInputAddHelper(
        title: Strings.of(context).saveBaitPageAddCategoryLabel,
        labelText: Strings.of(context).inputNameLabel,
        validate: (potentialName) async {
          if (isEmpty(potentialName)) {
            return Strings.of(context).inputNameRequired;
          } else if (await BaitManager.of(context)
              .categoryNameExists(potentialName))
          {
            return Strings.of(context).saveBaitPageCategoryExistsMessage;
          } else {
            return null;
          }
        },
        onAdd: (newName) => BaitManager.of(context).createOrUpdateCategory(
            BaitCategory(name: newName)),
      ),
    );
  }

  Widget _buildPhotoPicker(bool isRemovingFields) => PhotoInput.single(
    enabled: !isRemovingFields,
    currentImage: _allInputFields[photoId].controller.value,
    onImagePicked: (image) {
      setState(() {
        _allInputFields[photoId].controller.value = image;
      });
    },
  );

  void _save(Map<String, InputData> result) {
    print(result);
  }
}