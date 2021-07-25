import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../user_preference_manager.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/field.dart';
import '../widgets/input_controller.dart';
import '../widgets/text_input.dart';
import '../widgets/widget.dart';
import 'editable_form_page.dart';

class SaveBaitVariantPage extends StatefulWidget {
  final BaitVariant? oldBaitVariant;

  /// Called when the variant is saved. This function is invoked with null if
  /// no fields contain a value.
  final void Function(BaitVariant?)? onSave;

  SaveBaitVariantPage({
    this.onSave,
  }) : oldBaitVariant = null;

  SaveBaitVariantPage.edit(
    this.oldBaitVariant, {
    this.onSave,
  });

  @override
  _SaveBaitVariantPageState createState() => _SaveBaitVariantPageState();
}

class _SaveBaitVariantPageState extends State<SaveBaitVariantPage> {
  // Unique IDs for each field. These are stored in the database and should not
  // be changed.
  static final _idColor = Id()..uuid = "8b803b47-f3e1-4233-bb4b-f25e3ea48694";

  final _log = Log("SaveBaitVariantPage");

  final Map<Id, Field> _fields = {};
  List<CustomEntityValue> _customEntityValues = [];

  UserPreferenceManager get _userPreferencesManager =>
      UserPreferenceManager.of(context);

  BaitVariant? get _oldBaitVariant => widget.oldBaitVariant;

  bool get _isEditing => _oldBaitVariant != null;

  TextInputController get _colorController =>
      _fields[_idColor]!.controller as TextInputController;

  @override
  void initState() {
    super.initState();

    _fields[_idColor] = Field(
      id: _idColor,
      name: (context) => Strings.of(context).inputColorLabel,
      controller: TextInputController(),
    );

    // Only include fields being tracked by the user.
    var fieldIds = _userPreferencesManager.baitVariantFieldIds;
    for (var field in _fields.values) {
      field.isShowing = fieldIds.isEmpty || fieldIds.contains(field.id);
    }

    if (_isEditing) {
      _colorController.value =
          _oldBaitVariant!.hasColor() ? _oldBaitVariant!.color : null;
      _customEntityValues = _oldBaitVariant!.customEntityValues;
    }
  }

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      title: _isEditing
          ? Text(Strings.of(context).saveBaitVariantPageTitle)
          : Text(Strings.of(context).saveBaitVariantPageEditTitle),
      padding: insetsZero,
      fields: _fields,
      customEntityIds: _userPreferencesManager.baitVariantCustomIds,
      customEntityValues: _customEntityValues,
      onBuildField: _buildField,
      onSave: _save,
      onAddFields: (ids) =>
          _userPreferencesManager.setBaitVariantFieldIds(ids.toList()),
      runSpacing: 0,
    );
  }

  Widget _buildField(Id id) {
    if (id == _idColor) {
      return _buildColor();
    } else {
      _log.e("Unknown input key: $id");
      return Empty();
    }
  }

  Widget _buildColor() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.name(
        context,
        label: Strings.of(context).inputColorLabel,
        controller: _colorController,
        // Trigger "Save" button state refresh.
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  FutureOr<bool> _save(Map<Id, dynamic> customFieldValueMap) {
    _userPreferencesManager
        .setBaitVariantCustomIds(customFieldValueMap.keys.toList());

    var newVariant = BaitVariant()
      ..id = _oldBaitVariant?.id ?? randomId()
      ..customEntityValues.addAll(entityValuesFromMap(customFieldValueMap));

    if (isNotEmpty(_colorController.value)) {
      newVariant.color = _colorController.value!;
    }

    var isSet =
        newVariant.customEntityValues.isNotEmpty || newVariant.hasColor();
    widget.onSave?.call(isSet ? newVariant : null);

    return true;
  }
}
