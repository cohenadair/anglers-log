import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/custom_field_manager.dart';
import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/input.dart';
import 'package:mobile/widgets/input_type.dart';

class EditableFormPage extends StatefulWidget {
  final Widget title;

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
  ///
  /// See [FormPage.onSave].
  final FutureOr<bool> Function(Map<String, InputData>) onSave;

  /// See [FormPage.isInputValid].
  final bool isInputValid;

  final EdgeInsets padding;

  EditableFormPage({
    this.title,
    this.allFields = const {},
    this.initialFields = const {},
    this.onBuildField,
    this.onSave,
    this.padding = insetsHorizontalDefault,
    this.isInputValid = true,
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
      title: widget.title,
      padding: widget.padding,
      fieldBuilder: (BuildContext context, bool isRemovingFields) {
        return Map.fromIterable(_usedInputOptions.keys,
          key: (item) => item.toString(),
          value: (item) => _inputWidget(
            key: item.toString(),
            isRemovingFields: isRemovingFields,
          ),
        );
      },
      onSave: () => widget.onSave(_usedInputOptions),
      addFieldOptions: _allInputFields.keys.map((String id) {
        return FormPageFieldOption(
          id: id,
          userFacingName: _allInputFields[id].label(context),
          used: _usedInputOptions.keys.contains(id),
          removable: _allInputFields[id].removable,
        );
      }).toList(),
      onAddFields: _addInputWidgets,
      onConfirmRemoveFields: (List<String> fieldsToRemove) {
        setState(() {
          for (String key in fieldsToRemove) {
            _usedInputOptions.remove(key);
            _allInputFields[key].controller.clear();
          }
        });
      },
      isInputValid: widget.isInputValid,
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

  void _addInputWidgets(Set<String> ids) {
    // Handle the case of a new custom field being added.
    for (String id in ids) {
      CustomEntity customField = _customField(id);
      if (customField != null) {
        _allInputFields.putIfAbsent(customField.id, () => InputData(
          id: customField.id,
          controller: inputTypeController(customField.type),
          label: (_) => customField.name,
        ));
      }
    }

    setState(() {
      _usedInputOptions.clear();
      ids.forEach((id) =>
          _usedInputOptions.putIfAbsent(id, () => _allInputFields[id]));
    });
  }
}