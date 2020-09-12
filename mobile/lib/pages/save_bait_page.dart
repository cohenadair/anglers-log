import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/pages/bait_category_list_page.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/validator.dart';
import 'package:mobile/widgets/input_data.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mobile/widgets/widget.dart';

class SaveBaitPage extends StatefulWidget {
  final Bait oldBait;

  SaveBaitPage() : oldBait = null;
  SaveBaitPage.edit(this.oldBait);

  @override
  _SaveBaitPageState createState() => _SaveBaitPageState();
}

class _SaveBaitPageState extends State<SaveBaitPage> {
  static final _idBaitCategory = Id.random();
  static final _idName = Id.random();

  final Log _log = Log("SaveCatchPage");

  final Map<Id, InputData> _fields = {};
  List<CustomEntityValue> _customEntityValues = [];

  bool get _editing => widget.oldBait != null;

  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);
  BaitManager get _baitManager => BaitManager.of(context);
  PreferencesManager get _preferencesManager => PreferencesManager.of(context);

  InputController<Id> get _baitCategoryController =>
      _fields[_idBaitCategory].controller;
  TextInputController get _nameController =>
      _fields[_idName].controller as TextInputController;

  @override
  void initState() {
    super.initState();

    _fields[_idBaitCategory] = InputData(
      id: _idBaitCategory,
      label: (context) => Strings.of(context).saveBaitPageCategoryLabel,
      controller: InputController<BaitCategory>(),
      removable: true,
      showing: true,
    );

    _fields[_idName] = InputData(
      id: _idName,
      label: (context) => Strings.of(context).inputNameLabel,
      controller: TextInputController(
        validator: NameValidator(),
      ),
      removable: false,
      showing: true,
    );

    if (widget.oldBait != null) {
      _baitCategoryController.value = Id(widget.oldBait.baitCategoryId);
      _nameController.value = widget.oldBait.name;
      _customEntityValues = widget.oldBait.customEntityValues;
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
      customEntityIds: _preferencesManager.baitCustomEntityIds,
      customEntityValues: _customEntityValues,
      onBuildField: (id) {
        if (id == _idName) {
          return _buildNameField();
        } else if (id == _idBaitCategory) {
          return _buildCategoryPicker();
        } else {
          _log.e("Unknown input key: $id");
          return Empty();
        }
      },
      onSave: _save,
      isInputValid: _nameController.valid(context),
    );
  }

  Widget _buildCategoryPicker() {
    return EntityListenerBuilder(
      managers: [ _baitCategoryManager ],
      builder: (context) {
        return ListPickerInput(
          title: Strings.of(context).saveBaitPageCategoryLabel,
          value: _baitCategoryManager.entity(_baitCategoryController.value)
              .name,
          onTap: () {
            push(context, BaitCategoryListPage.picker(
              onPicked: (context, pickedCategoryId) {
                setState(() {
                  _baitCategoryController.value = pickedCategoryId;
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
      // Trigger "Save" button state refresh.
      onChanged: () => setState(() {}),
    ),
  );

  FutureOr<bool> _save(Map<Id, dynamic> customFieldValueMap) {
    _preferencesManager.baitCustomEntityIds = customFieldValueMap.keys.toList();

    Bait newBait = Bait()
      ..id = widget.oldBait?.id
      ..name = _nameController.value
      ..baitCategoryId = _baitCategoryController.value.bytes
      ..customEntityValues.addAll(entityValuesFromMap(customFieldValueMap));

    if (_baitManager.duplicate(newBait)) {
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