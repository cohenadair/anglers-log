import 'dart:async';

import 'package:flutter/material.dart';

import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../entity_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/bait_category_list_page.dart';
import '../pages/editable_form_page.dart';
import '../preferences_manager.dart';
import '../res/dimen.dart';
import '../utils/dialog_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/validator.dart';
import '../widgets/input_controller.dart';
import '../widgets/input_data.dart';
import '../widgets/list_picker_input.dart';
import '../widgets/text_input.dart';
import '../widgets/widget.dart';
import 'manageable_list_page.dart';

class SaveBaitPage extends StatefulWidget {
  final Bait oldBait;

  SaveBaitPage() : oldBait = null;

  SaveBaitPage.edit(this.oldBait);

  @override
  _SaveBaitPageState createState() => _SaveBaitPageState();
}

class _SaveBaitPageState extends State<SaveBaitPage> {
  // Unique IDs for each bait field. These are stored in the database and
  // should not be changed.
  static final _idBaitCategory = Id()
    ..uuid = "832e8f16-3fb6-4530-b8d7-7840734cf465";
  static final _idName = Id()..uuid = "017ae032-477b-4fe4-9be0-ea0a05a576f9";

  final Log _log = Log("SaveCatchPage");

  final Map<Id, Field> _fields = {};
  List<CustomEntityValue> _customEntityValues = [];

  Bait get _oldBait => widget.oldBait;

  bool get _editing => _oldBait != null;

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

    var baitFieldIds = _preferencesManager.baitFieldIds;

    _fields[_idBaitCategory] = Field(
      id: _idBaitCategory,
      name: (context) => Strings.of(context).saveBaitPageCategoryLabel,
      controller: IdInputController(),
      removable: true,
      // Only include bait category field if not disabled by the user.
      showing: baitFieldIds == null ||
          baitFieldIds.isEmpty ||
          baitFieldIds.contains(_idBaitCategory),
    );

    // Name field is required; always include it.
    _fields[_idName] = Field(
      id: _idName,
      name: (context) => Strings.of(context).inputNameLabel,
      controller: TextInputController(
        validator: NameValidator(),
      ),
      removable: false,
      showing: true,
    );

    if (_editing) {
      _baitCategoryController.value = _oldBait.baitCategoryId;
      _nameController.value = _oldBait.name;
      _customEntityValues = _oldBait.customEntityValues;
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
      onAddFields: (ids) => _preferencesManager.baitFieldIds = ids.toList(),
      isInputValid: _nameController.valid(context),
    );
  }

  Widget _buildCategoryPicker() {
    return EntityListenerBuilder(
      managers: [_baitCategoryManager],
      builder: (context) {
        var baitCategory =
            _baitCategoryManager.entity(_baitCategoryController.value);
        return ListPickerInput(
          title: Strings.of(context).saveBaitPageCategoryLabel,
          value: baitCategory?.name,
          onTap: () {
            push(
              context,
              BaitCategoryListPage(
                pickerSettings:
                    ManageableListPagePickerSettings<BaitCategory>.single(
                  onPicked: (context, category) {
                    setState(
                        () => _baitCategoryController.value = category?.id);
                    return true;
                  },
                  initialValue: baitCategory,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.name(
        context,
        controller: _nameController,
        autofocus: true,
        // Trigger "Save" button state refresh.
        onChanged: () => setState(() {}),
      ),
    );
  }

  FutureOr<bool> _save(Map<Id, dynamic> customFieldValueMap) {
    _preferencesManager.baitCustomEntityIds = customFieldValueMap.keys.toList();

    var newBait = Bait()
      ..id = _oldBait?.id ?? randomId()
      ..name = _nameController.value
      ..customEntityValues.addAll(entityValuesFromMap(customFieldValueMap));

    if (_baitCategoryController.value != null) {
      newBait.baitCategoryId = _baitCategoryController.value;
    }

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
