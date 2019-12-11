import 'package:flutter/material.dart';
import 'package:mobile/custom_field_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/date_time_picker.dart';
import 'package:mobile/widgets/input.dart';
import 'package:mobile/widgets/widget.dart';

import 'form_page.dart';

class SaveCatchPage extends StatefulWidget {
  @override
  _SaveCatchPageState createState() => _SaveCatchPageState();
}

class _SaveCatchPageState extends State<SaveCatchPage> {
  static const String timestampId = "timestamp";
  static const String anglerId = "angler";

  /// All valid fields for the form.
  Map<String, InputData> _allInputFields = {
    timestampId: InputData(
      id: timestampId,
      controller: TimestampInputController(
        date: DateTime.now(),
        time: TimeOfDay.now(),
      ),
      label: (BuildContext context) =>
          Strings.of(context).addCatchPageDateTimeLabel,
      removable: false,
    ),

    anglerId: InputData(
      id: anglerId,
      controller: TextInputController(controller: TextEditingController()),
      label: (BuildContext context) => Strings.of(context).anglerNameLabel,
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
      timestampId: _allInputFields[timestampId],
      anglerId: _allInputFields[anglerId],
    };
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
      onSave: _save,
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

    switch (key) {
      case timestampId: return _timestampWidget(isRemovingFields);
      case anglerId: return _anglerWidget(isRemovingFields);
      default:
        print("Unknown input key: $key");
        return Empty();
    }
  }

  Widget _timestampWidget(bool isRemovingFields) {
    TimestampInputController controller =
        _allInputFields[timestampId].controller;

    return DateTimePickerContainer(
      datePicker: DatePicker(
        initialDate: controller.date,
        label: Strings.of(context).addCatchPageDateLabel,
        enabled: !isRemovingFields,
        onChange: (DateTime newDate) {
          controller.date = newDate;
        },
      ),
      timePicker: TimePicker(
        initialTime: controller.time,
        label: Strings.of(context).addCatchPageTimeLabel,
        enabled: !isRemovingFields,
        onChange: (TimeOfDay newTime) {
          controller.time = newTime;
        },
      ),
    );
  }

  Widget _anglerWidget(bool isRemovingFields) =>
      TextInput.name(context,
        controller: _usedInputOptions[anglerId].controller.value,
        label: _usedInputOptions[anglerId].label(context),
        requiredText: format(Strings.of(context).inputRequiredMessage,
            [Strings.of(context).anglerNameLabel]),
        enabled: !isRemovingFields,
      );

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