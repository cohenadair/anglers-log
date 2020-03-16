import 'package:flutter/material.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/text_input.dart';
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
  static const String nameId = "name";

  final _log = Log("SaveBaitPage");
  List<BaitCategory> _categories = [];

  bool get editing => widget.oldBait != null;

  BaitCategoryController get _baitCategoryController =>
      _allInputFields[baitCategoryId].controller as BaitCategoryController;
  TextInputController get _nameController =>
      _allInputFields[nameId].controller as TextInputController;

  final Map<String, InputData> _allInputFields = {
    baitCategoryId: InputData(
      id: baitCategoryId,
      label: (context) => Strings.of(context).saveBaitPageCategoryLabel,
      controller: BaitCategoryController(),
      removable: true,
    ),
    nameId: InputData(
      id: nameId,
      label: (context) => Strings.of(context).inputNameLabel,
      controller: TextInputController(
        validate: (context) => Strings.of(context).inputGenericRequired,
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      title: Strings.of(context).saveBaitPageNewTitle,
      padding: insetsZero,
      allFields: _allInputFields,
      initialFields: {
        baitCategoryId: _allInputFields[baitCategoryId],
        nameId: _allInputFields[nameId],
      },
      onBuildField: (id, isRemovingFields) {
        switch (id) {
          case nameId: return _buildNameField(isRemovingFields);
          case baitCategoryId: return _buildCategoryPicker(isRemovingFields);
          default:
            print("Unknown input key: $id");
            return Empty();
        }
      },
      onSave: _save,
      isInputValid: isEmpty(_nameController.error(context)),
    );
  }

  Widget _buildCategoryPicker(bool isRemovingFields) {
    return ListPickerInput<BaitCategory>.single(
      initialValue: _baitCategoryController.value,
      pageTitle: Strings.of(context).saveBaitPageCategoryPickerTitle,
      enabled: !isRemovingFields,
      labelText: Strings.of(context).saveBaitPageCategoryLabel,
      futureStreamHolder: BaitCategoriesFutureStreamHolder(context,
        onUpdate: (categories) {
          _log.d("Bait categories updated...");
          _categories = categories;

          // Update bait category in case the selected category has changed, or
          // been deleted.
          BaitCategory currentCategory = _baitCategoryController.value;
          BaitCategory updatedCategory = _categories.firstWhere(
            (e) => e.id == currentCategory?.id,
            orElse: () => null,
          );
          _baitCategoryController.value = updatedCategory;
        },
      ),
      itemBuilder: () => _categories.map((e) => PickerPageItem(
        title: e.name,
        value: e,
      )).toList(),
      onChanged: (category) => _baitCategoryController.value = category,
      addItemHelper: PickerPageItemNameManager<BaitCategory>(
        addTitle: Strings.of(context).saveBaitPageNewCategoryLabel,
        editTitle: Strings.of(context).saveBaitPageEditCategoryLabel,
        deleteMessageBuilder: (context, category) => InsertedBoldText(
          text: Strings.of(context).saveBaitPageConfirmDeleteCategory,
          args: [category.name],
        ),
        oldNameCallback: (oldCategory) => oldCategory.name,
        validate: (potentialName, oldCategory) async {
          if (isEmpty(potentialName)) {
            return (context) => Strings.of(context).inputGenericRequired;
          } else if (await BaitManager.of(context)
              .categoryNameExists(potentialName))
          {
            return (context) =>
                Strings.of(context).saveBaitPageCategoryExistsMessage;
          } else {
            return null;
          }
        },
        onSave: (newName, oldCategory) {
          var newCategory = BaitCategory(name: newName);
          if (oldCategory != null) {
            newCategory = BaitCategory(name: newName, id: oldCategory.id);
          }

          BaitManager.of(context).createOrUpdateCategory(newCategory);
        },
        onDelete: (categoryToDelete) =>
            BaitManager.of(context).deleteCategory(categoryToDelete),
      ),
      itemEqualsOldValue: (item, oldCategory) {
        return item.value.id == oldCategory.id;
      },
    );
  }

  Widget _buildNameField(bool isRemovingFields) => Padding(
    padding: insetsHorizontalDefault,
    child: TextInput.name(context,
      enabled: !isRemovingFields,
      controller: _nameController,
      autofocus: true,
      validate: () {
        var callback;
        if (isEmpty(_nameController.text)) {
          callback = (context) => Strings.of(context).inputGenericRequired;
        }

        // Trigger "Save" button state refresh.
        setState(() {});
        return callback;
      },
    ),
  );

  Future<bool> _save(Map<String, InputData> result) async {
    Bait newBait = Bait(
      name: _nameController.text,
      baitCategoryId: _baitCategoryController.value?.id,
    );

    if (await BaitManager.of(context).baitExists(newBait)) {
      // TODO: Show dialog
      print("Bait exists");
      return false;
    }

    BaitManager.of(context).createOrUpdateBait(newBait);
    return true;
  }
}