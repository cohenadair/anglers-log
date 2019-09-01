import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/custom_entity.dart';
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
  static const String anglerId = "angler";
  // TODO: Remove
  static final String test1 = Uuid().v1();
  static final String test2 = Uuid().v1();
  static final String test3 = Uuid().v1();
  static final String test4 = Uuid().v1();

  /// All valid fields for the form.
  Map<String, InputData> _allInputFields = {
    anglerId: InputData(
      id: anglerId,
      controller: TextInputController(controller: TextEditingController()),
      label: (BuildContext context) {
        return Strings.of(context).anglerNameLabel;
      },
    ),
    test1: InputData(
      id: test1,
      controller: TextInputController(controller: TextEditingController()),
      label: (BuildContext context)
          => "Test Field ${test1.substring(test1.length - 5)}",
    ),
    test2: InputData(
      id: test2,
      controller: TextInputController(controller: TextEditingController()),
      label: (BuildContext context)
          => "Test Field ${test2.substring(test2.length - 5)}",
    ),
    test3: InputData(
      id: test3,
      controller: TextInputController(controller: TextEditingController()),
      label: (BuildContext context)
          => "Test Field ${test3.substring(test3.length - 5)}",
    ),
    test4: InputData(
      id: test4,
      controller: TextInputController(controller: TextEditingController()),
      label: (BuildContext context)
          => "Test Field ${test4.substring(test4.length - 5)}",
    ),
  };

  /// Options that are shown in the form, but not necessarily filled out.
  Map<String, InputData> _usedInputOptions;

  @override
  void dispose() {
    for (var value in _usedInputOptions.values) {
      value.controller.dispose();
    }
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _usedInputOptions = {
      anglerId: _allInputFields[anglerId],
    };
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      key: UniqueKey(),
      app: widget.app,
      fieldBuilder: (BuildContext context, bool isRemovingFields) {
        return Map.fromIterable(_usedInputOptions.keys,
          key: (item) => item.toString(),
          value: (item) => _inputWidget(
            key: item.toString(),
            isRemovingFields: isRemovingFields,
          ),
        );
      },
      onSave: _save,
      addFieldOptions: _allInputFields.keys.map((String id) {
        return FormPageFieldOption(
          id: id,
          userFacingName: _allInputFields[id].label(context),
          used: _usedInputOptions.keys.contains(id),
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
      widget.app.customFieldManager.customField(id);

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

    var label = _usedInputOptions[key].label(context);

    switch (key) {
      case anglerId: return TextInput.name(context,
        controller: _usedInputOptions[key].controller.value,
        label: label,
        requiredText: format(Strings.of(context).inputRequiredMessage,
            [Strings.of(context).anglerNameLabel]),
        enabled: !isRemovingFields,
      );

      default: return TextInput(
        controller: _usedInputOptions[key].controller.value,
        label: label,
        requiredText: "Test Field is required",
        capitalization: TextCapitalization.words,
        enabled: !isRemovingFields,
      );
    }
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

  void _save() {
    Map<String, dynamic> result = {};
    print(result);
  }
}