import 'package:flutter/material.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/validator.dart';
import 'package:quiver/strings.dart';

/// A class for storing a value of an input widget, such as a text field or
/// check box.
class InputController<T> {
  /// The value of the controller, such as [bool] or [String].
  T value;

  /// The current error message for the [InputController], if there is one.
  String error;

  InputController({
    this.value
  });

  void dispose() {
    clear();
  }

  void clear() {
    value = null;
  }
}

class TextInputController extends InputController<String> {
  final TextEditingController editingController = TextEditingController();
  final Validator validator;

  TextInputController({
    TextEditingController editingController,
    this.validator,
  }) : super();

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

class TimestampInputController extends InputController<int> {
  /// The date component of the controller.
  DateTime date;

  /// The time component of the controller.
  TimeOfDay time;

  TimestampInputController({
    this.date,
    this.time,
  });

  @override
  int get value => combine(date, time).millisecondsSinceEpoch;

  @override
  set value(int millisSinceEpoch) {
    if (millisSinceEpoch == null) {
      date = null;
      time = null;
      return;
    }
    date = DateTime.fromMillisecondsSinceEpoch(millisSinceEpoch);
    time = TimeOfDay.fromDateTime(date);
  }

  @override
  void clear() {
    super.clear();
    date = null;
    time = null;
  }
}