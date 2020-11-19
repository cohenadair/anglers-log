import 'package:flutter/material.dart';
import 'package:mobile/model/gen/google/protobuf/timestamp.pb.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/validator.dart';
import 'package:quiver/strings.dart';

/// A class for storing a value of an input widget, such as a text field or
/// check box.
class InputController<T> {
  /// The value of the controller, such as [bool] or [String].
  T value;

  /// The current error message for the [InputController], if there is one.
  String error;

  InputController({this.value});

  void dispose() {
    clear();
  }

  void clear() {
    value = null;
  }
}

class TextInputController extends InputController<String> {
  final TextEditingController editingController;
  final Validator validator;

  TextInputController({
    TextEditingController editingController,
    this.validator,
  })  : editingController = editingController ?? TextEditingController(),
        super();

  @override
  get value {
    var text = editingController.text.trim();
    if (isEmpty(text)) {
      return null;
    }
    return text;
  }

  @override
  set value(String value) =>
      editingController.text = isEmpty(value) ? value : value.trim();

  @override
  void dispose() {
    editingController.dispose();
  }

  @override
  void clear() {
    editingController.clear();
  }

  void clearText() {
    editingController.value = TextEditingValue(text: "");
  }

  bool valid(BuildContext context) =>
      isEmpty(validator?.run(context, value)?.call(context));
}

class NumberInputController extends TextInputController {
  NumberInputController({
    TextEditingController editingController,
  }) : super(
          editingController: editingController ?? TextEditingController(),
          validator: DoubleValidator(),
        );
}

class EmailInputController extends TextInputController {
  EmailInputController({
    TextEditingController editingController,
    bool required = false,
  }) : super(
          editingController: editingController ?? TextEditingController(),
          validator: EmailValidator(required: required),
        );
}

/// A [TimestampInputController] value, [Timestamp], is always in UTC. However,
/// the [date] and [time] properties are in the local timezone.
class TimestampInputController extends InputController<Timestamp> {
  /// The date component of the controller.
  DateTime date;

  /// The time component of the controller.
  TimeOfDay time;

  TimestampInputController({
    DateTime date,
    this.time,
  }) : date = date;

  @override
  Timestamp get value => date != null && time != null
      ? Timestamp.fromDateTime(combine(date, time))
      : null;

  @override
  set value(Timestamp timestamp) {
    if (timestamp == null) {
      date = null;
      time = null;
      return;
    }
    date = timestamp.localDateTime;
    time = TimeOfDay.fromDateTime(date);
  }

  @override
  void clear() {
    super.clear();
    date = null;
    time = null;
  }
}
