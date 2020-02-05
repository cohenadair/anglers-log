import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/date_time_picker.dart';
import 'package:mobile/widgets/input.dart';
import 'package:mobile/widgets/widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      allFields: _allInputFields,
      initialFields: {
        timestampId : _allInputFields[timestampId],
        anglerId : _allInputFields[anglerId],
      },
      onBuildField: (id, isRemovingFields) {
        switch (id) {
          case timestampId: return _timestampWidget(isRemovingFields);
          case anglerId: return _anglerWidget(isRemovingFields);
          default:
            print("Unknown input key: $id");
            return Empty();
        }
      },
      onSave: _save,
    );
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

  Widget _anglerWidget(bool isRemovingFields) => TextInput.name(context,
    controller: _allInputFields[anglerId].controller.value,
    label: _allInputFields[anglerId].label(context),
    requiredText: format(Strings.of(context).inputRequiredMessage,
        [Strings.of(context).anglerNameLabel]),
    enabled: !isRemovingFields,
  );

  void _save(Map<String, InputData> result) {
    print(result);
  }
}