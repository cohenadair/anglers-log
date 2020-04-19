import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/custom_field_manager.dart';
import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/input_data.dart';
import 'package:mobile/widgets/input_type.dart';
import 'package:mobile/widgets/widget.dart';

class EditableFormPage extends StatefulWidget {
  final Widget title;

  /// A unique ID to [InputData] map of all valid fields for the form.
  final Map<String, InputData> fields;

  /// Called when an input field needs to be built. The ID of the input field
  /// is passed into the function.
  final Function(String) onBuildField;

  /// Called when the "Save" button is pressed and form validation passes.
  /// A map of used input fields, including any custom fields, is passed into
  /// the function.
  ///
  /// See [FormPage.onSave].
  final FutureOr<bool> Function(Map<String, InputData>) onSave;

  /// See [FormPage.isInputValid].
  final bool isInputValid;

  /// See [FormPage.runSpacing].
  final double runSpacing;

  final EdgeInsets padding;

  EditableFormPage({
    this.title,
    this.fields = const {},
    this.onBuildField,
    this.onSave,
    this.padding = insetsHorizontalDefault,
    this.isInputValid = true,
    this.runSpacing,
  });

  @override
  _EditableFormPageState createState() => _EditableFormPageState();
}

class _EditableFormPageState extends State<EditableFormPage> {
  /// Options that are shown in the form, but not necessarily filled out.
  Map<String, InputData> _fields = {};

  Map<String, InputData> get _allInputFields => widget.fields;

  @override
  void initState() {
    super.initState();
    _fields.addAll(widget.fields);
  }

  @override
  void dispose() {
    for (var value in _fields.values) {
      value.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: widget.title,
      runSpacing: widget.runSpacing,
      padding: widget.padding,
      fieldBuilder: (BuildContext context) {
        return Map.fromIterable(_fields.keys,
          key: (item) => item.toString(),
          value: (item) => _inputWidget(
            key: item.toString(),
          ),
        );
      },
      onSave: () => widget.onSave(_fields),
      addFieldOptions: _allInputFields.keys.map((String id) {
        return FormPageFieldOption(
          id: id,
          userFacingName: _allInputFields[id].label(context),
          used: _fields[id].showing,
          removable: _allInputFields[id].removable,
        );
      }).toList(),
      onAddFields: _addInputWidgets,
      isInputValid: widget.isInputValid,
    );
  }

  CustomEntity _customField(String id) =>
      CustomFieldManager.of(context).entity(id:id);

  Widget _inputWidget({String key}) {
    if (!_fields[key].showing) {
      return Empty();
    }

    CustomEntity customField = _customField(key);
    if (customField != null) {
      return inputTypeWidget(context,
        type: customField.type,
        label: customField.name,
        controller: _fields[key].controller,
        onCheckboxChanged: (bool newValue) {
          _fields[key].controller.value = newValue;
        },
      );
    }

    return widget.onBuildField?.call(key);
  }

  void _addInputWidgets(Set<String> ids) {
    // Handle the case of a new custom field being added.
    for (String id in ids) {
      CustomEntity customField = _customField(id);
      if (customField != null) {
        _fields.putIfAbsent(customField.id, () => InputData(
          id: customField.id,
          controller: inputTypeController(customField.type),
          label: (_) => customField.name,
          showing: true,
        ));
      }
    }

    setState(() {
      for (var field in _fields.values) {
        field.showing = ids.contains(field.id);
      }
    });
  }
}