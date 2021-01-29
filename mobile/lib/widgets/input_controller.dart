import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../model/gen/anglerslog.pb.dart';
import '../model/gen/google/protobuf/timestamp.pb.dart';
import '../utils/date_time_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/validator.dart';

/// A class for storing a value of an input widget, such as a text field or
/// check box.
class InputController<T> {
  /// The value of the controller, such as [bool] or [String].
  T value;

  /// The current error message for the [InputController], if there is one.
  String error;

  InputController({this.value}) {
    assert(!(T == Id) || this is IdInputController,
        "Use IdInputController instead of InputController<Id>");
  }

  void dispose() {
    clear();
  }

  void clear() {
    value = null;
  }
}

class IdInputController extends InputController<Id> {
  @override
  set value(Id newValue) {
    // An ID with an empty uuid is invalid. This can happen by accessing a
    // Google Protobuf Id property that isn't set (i.e. the protobufObj.has*()
    // method returns false).
    //
    // For convenience, and to avoid accidental errors, anytime we see an
    // invalid ID, we'll set the value to null.
    if (newValue != null && isEmpty(newValue.uuid)) {
      super.value = null;
    } else {
      super.value = newValue;
    }
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
  String get value {
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

class PasswordInputController extends TextInputController {
  PasswordInputController({
    TextEditingController editingController,
  }) : super(
          editingController: editingController ?? TextEditingController(),
          validator: PasswordValidator(),
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
    this.date,
    this.time,
  });

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
