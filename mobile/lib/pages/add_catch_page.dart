import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/field.dart';
import 'package:mobile/model/angler.dart';
import 'package:mobile/model/custom_field.dart';
import 'package:mobile/model/field_type.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/input.dart';
import 'package:uuid/uuid.dart';

import 'form_page.dart';

class AddCatchPage extends StatefulWidget {
  final AppManager app;

  AddCatchPage({this.app}) : assert(app != null);

  @override
  _AddCatchPageState createState() => _AddCatchPageState();
}

class _AddCatchPageState extends State<AddCatchPage> {
  // TODO: Remove
  static final String test1 = Uuid().v1();
  static final String test2 = Uuid().v1();
  static final String test3 = Uuid().v1();
  static final String test4 = Uuid().v1();

  /// Options that are shown in the form, but not necessarily filled out.
  Map<String, dynamic> _usedInputOptions = {
    Angler.key: TextEditingController(),
  };

  /// All fields that can be added to (or are already a part of) the form.
  Map<String, Field> _allInputFields = {
    Angler.key: Field(id: Angler.key, type: FieldType.text),
    test1: Field(id: test1, type: FieldType.text),
    test2: Field(id: test2, type: FieldType.text),
    test3: Field(id: test3, type: FieldType.text),
    test4: Field(id: test4, type: FieldType.text),
  };

  @override
  void dispose() {
    for (var value in _usedInputOptions.values) {
      if (value is TextEditingController) {
        value.dispose();
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      key: UniqueKey(),
      app: widget.app,
      fieldBuilder: (BuildContext context, bool isRemovingFields) {
        return Map.fromIterable(_usedInputOptions.keys,
          key: (item) => item.toString(),
          value: (item) => _inputField(
            key: item.toString(),
            isRemovingFields: isRemovingFields,
          ),
        );
      },
      onSave: _save,
      addFieldOptions: _allInputFields.keys.map((String id) {
        return FormPageFieldOption(
          id: id,
          userFacingName: _userFacingLabel(id),
          used: _usedInputOptions.keys.contains(id),
        );
      }).toList(),
      onAddField: _addField,
      onConfirmRemoveFields: (List<String> fieldsToRemove) {
        setState(() {
          for (String key in fieldsToRemove) {
            _usedInputOptions.remove(key);
          }
        });
      },
    );
  }

  CustomField _customField(String id) =>
      widget.app.customFieldManager.customField(id);

  Widget _inputField({String key, bool isRemovingFields}) {
    CustomField customField = _customField(key);
    if (customField != null) {
      // TODO: Need default input fields for each FieldType
    }

    switch (key) {
      case Angler.key: return TextInput(
        controller: _usedInputOptions[key],
        label: _userFacingLabel(key),
        requiredText: format(Strings.of(context).inputRequiredMessage,
            [Strings.of(context).anglerNameLabel]),
        capitalization: TextCapitalization.words,
        enabled: !isRemovingFields,
      );

      default: return TextInput(
        controller: _usedInputOptions[key],
        label: _userFacingLabel(key),
        requiredText: "Test Field is required",
        capitalization: TextCapitalization.words,
        enabled: !isRemovingFields,
      );
    }
  }

  String _userFacingLabel(String id) {
    CustomField customField = _customField(id);
    if (customField != null) {
      return customField.name;
    }

    switch (id) {
      case Angler.key: return Strings.of(context).anglerNameLabel;
      default: return "Test Field ${id.substring(id.length - 5)}";
    }
  }

  void _addField(String id) {
    // Handle the case of a new custom field being added.
    CustomField customField = _customField(id);
    if (customField != null) {
      _allInputFields.putIfAbsent(customField.id, () => customField);
    }

    setState(() {
      _usedInputOptions.putIfAbsent(id, () =>
          defaultFieldTypeValue(_allInputFields[id].type));
    });
  }

  void _save() {
    Map<String, dynamic> result = {};

    // Angler
    if (_usedInputOptions.containsKey(Angler.key)) {
      Angler angler =
          Angler(name: _usedInputOptions[Angler.key].value.text);
      result.putIfAbsent(Angler.key, () => angler.toMap);
    }

    // Test
    if (_usedInputOptions.containsKey(test1)) {
      result.putIfAbsent(test1, () =>
          _usedInputOptions[test1].value.text);
    }
    if (_usedInputOptions.containsKey(test2)) {
      result.putIfAbsent(test2, () =>
          _usedInputOptions[test2].value.text);
    }
    if (_usedInputOptions.containsKey(test3)) {
      result.putIfAbsent(test3, () =>
          _usedInputOptions[test3].value.text);
    }
    if (_usedInputOptions.containsKey(test4)) {
      result.putIfAbsent(test4, () =>
          _usedInputOptions[test4].value.text);
    }

    print(result);
  }
}