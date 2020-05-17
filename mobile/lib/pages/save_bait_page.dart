import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/pages/bait_category_list_page.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/validator.dart';
import 'package:mobile/widgets/input_data.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class SaveBaitPage extends StatefulWidget {
  final Bait oldBait;

  SaveBaitPage() : oldBait = null;
  SaveBaitPage.edit(this.oldBait);

  @override
  _SaveBaitPageState createState() => _SaveBaitPageState();
}

class _SaveBaitPageState extends State<SaveBaitPage> {
  static const String baitCategoryId = "bait_category";
  static const String nameId = "name";

  final Log _log = Log("SaveCatchPage");

  final Map<String, InputData> _fields = {};

  bool get _editing => widget.oldBait != null;

  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);
  BaitManager get _baitManager => BaitManager.of(context);

  BaitCategoryInputController get _baitCategoryController =>
      _fields[baitCategoryId].controller as BaitCategoryInputController;
  TextInputController get _nameController =>
      _fields[nameId].controller as TextInputController;

  @override
  void initState() {
    super.initState();

    _fields[baitCategoryId] = InputData(
      id: baitCategoryId,
      label: (context) => Strings.of(context).saveBaitPageCategoryLabel,
      controller: BaitCategoryInputController(),
      removable: true,
      showing: true,
    );

    _fields[nameId] = InputData(
      id: nameId,
      label: (context) => Strings.of(context).inputNameLabel,
      controller: TextInputController(
        validate: (context) => Strings.of(context).inputGenericRequired,
      ),
      removable: false,
      showing: true,
    );

    if (widget.oldBait != null) {
      _baitCategoryController.value =
          _baitCategoryManager.entity(id: widget.oldBait.categoryId);
      _nameController.text = widget.oldBait.name;
      _nameController.validate = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      title: _editing
          ? Text(Strings.of(context).saveBaitPageEditTitle)
          : Text(Strings.of(context).saveBaitPageNewTitle),
      padding: insetsZero,
      fields: _fields,
      onBuildField: (id) {
        switch (id) {
          case nameId: return _buildNameField();
          case baitCategoryId: return _buildCategoryPicker();
          default:
            _log.e("Unknown input key: $id");
            return Empty();
        }
      },
      onSave: _save,
      isInputValid: isEmpty(_nameController.error(context)),
    );
  }

  Widget _buildCategoryPicker() {
    return EntityListenerBuilder<BaitCategory>(
      manager: _baitCategoryManager,
      builder: (context) {
        // Update value with latest from database.
        _baitCategoryController.value =
            _baitCategoryManager.entity(id: _baitCategoryController.value?.id);

        return ListPickerInput<BaitCategory>(
          title: Strings.of(context).saveBaitPageCategoryLabel,
          value: _baitCategoryController.value?.name,
          onTap: () {
            push(context, BaitCategoryListPage.picker(
              onPicked: (context, pickedCategory) {
                setState(() {
                  _baitCategoryController.value = pickedCategory;
                });
                return true;
              },
            ));
          },
        );
      },
    );
  }

  Widget _buildNameField() => Padding(
    padding: insetsHorizontalDefault,
    child: TextInput.name(context,
      controller: _nameController,
      autofocus: true,
      validator: GenericValidator(runner: (context, newName) {
        if (isEmpty(_nameController.text)) {
          return (context) => Strings.of(context).inputGenericRequired;
        }
        return null;
      }),
      // Trigger "Save" button state refresh.
      onChanged: () => setState(() {}),
    ),
  );

  Future<bool> _save(Map<String, InputData> result) async {
    Bait newBait = Bait(
      id: widget.oldBait?.id,
      name: _nameController.text,
      categoryId: _baitCategoryController.value?.id,
    );

    if (_baitManager.isDuplicate(newBait)) {
      showErrorDialog(
        context: context,
        description: Text(Strings.of(context).saveBaitPageBaitExists),
      );
      return false;
    }

    _baitManager.addOrUpdate(newBait);
    return true;
  }
}