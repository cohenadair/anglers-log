import 'package:flutter/material.dart';
import 'package:mobile/custom_field_manager.dart';
import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/widgets/input.dart';
import 'package:mobile/widgets/input_type.dart';

class EditableFormPage extends StatefulWidget {
  /// A unique ID to [InputData] map of all valid fields for the form. The
  /// items in this map may or may not need to be added by the user via
  /// "Add Field" button.
  final Map<String, InputData> allFields;

  /// A sub-collection of [allFields]. All items in [initialFields] will be
  /// available to fill out immediately, without using the "Add Field" button.
  final Map<String, InputData> initialFields;

  /// Called when an input field needs to be built. The ID of the input field
  /// is passed into the function, as well as whether the user is currently
  /// removing fields.
  final Function(String, bool) onBuildField;

  /// Called when the "Save" button is pressed and form validation passes.
  /// A map of used input fields, including any custom fields, is passed into
  /// the function.
  final Function(Map<String, InputData>) onSave;

  EditableFormPage({
    this.allFields = const {},
    this.initialFields = const {},
    this.onBuildField,
    this.onSave,
  });

  @override
  _EditableFormPageState createState() => _EditableFormPageState();
}

class _EditableFormPageState extends State<EditableFormPage> {
  /// Options that are shown in the form, but not necessarily filled out.
  Map<String, InputData> _usedInputOptions = {};

  Map<String, InputData> get _allInputFields => widget.allFields;

  @override
  void initState() {
    super.initState();
    _usedInputOptions.addAll(widget.initialFields);
  }

  @override
  void dispose() {
    for (var value in _usedInputOptions.values) {
      value.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      key: UniqueKey(),
      fieldBuilder: (BuildContext context, bool isRemovingFields) {
        return Map.fromIterable(_usedInputOptions.keys,
          key: (item) => item.toString(),
          value: (item) => _inputWidget(
            key: item.toString(),
            isRemovingFields: isRemovingFields,
          ),
        );
      },
      onSave: () {
        widget.onSave?.call(_usedInputOptions);
      },
      addFieldOptions: _allInputFields.keys.map((String id) {
        return FormPageFieldOption(
          id: id,
          userFacingName: _allInputFields[id].label(context),
          used: _usedInputOptions.keys.contains(id),
          removable: _allInputFields[id].removable,
        );
      }).toList(),
      onAddField: _addInputWidget,
      onConfirmRemoveFields: (List<String> fieldsToRemove) {
        setState(() {
          for (String key in fieldsToRemove) {
            _usedInputOptions.remove(key);
            _allInputFields[key].controller.clear();
          }
        });
      },
    );
  }

  CustomEntity _customField(String id) =>
      CustomFieldManager.of(context).customField(id);

  Widget _inputWidget({String key, bool isRemovingFields}) {
    CustomEntity customField = _customField(key);
    if (customField != null) {
      return inputTypeWidget(context,
        type: customField.type,
        label: customField.name,
        controller: _usedInputOptions[key].controller,
        onCheckboxChanged: (bool newValue) {
          _usedInputOptions[key].controller.value = newValue;
        },
        enabled: !isRemovingFields,
      );
    }

    return widget.onBuildField?.call(key, isRemovingFields);
  }

  void _addInputWidget(String id) {
    // Handle the case of a new custom field being added.
    CustomEntity customField = _customField(id);
    if (customField != null) {
      _allInputFields.putIfAbsent(customField.id, () => InputData(
        id: customField.id,
        controller: inputTypeController(customField.type),
        label: (_) => customField.name,
      ));
    }

    setState(() {
      _usedInputOptions.putIfAbsent(id, () => _allInputFields[id]);
    });
  }
}