import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../model/gen/anglerslog.pb.dart';
import '../time_manager.dart';
import '../utils/date_time_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/validator.dart';

/// A class for storing a value of an input widget, such as a text field or
/// check box.
class InputController<T> {
  /// The value of the controller, such as [bool] or [String].
  T? value;

  /// The current error message for the [InputController], if there is one.
  String? error;

  InputController({this.value}) {
    assert(!(T == Id) || this is IdInputController,
        "Use IdInputController instead>");
    assert(!(T.toString().contains("Set")) || this is SetInputController,
        "Use SetInputController<T> instead>");
    assert(!(T.toString().contains("List")) || this is ListInputController,
        "Use ListInputController<T> instead");
    assert(
      !(T.toString().contains("MultiMeasurement")) ||
          this is MultiMeasurementInputController,
      "Use MultiMeasurementInputController instead",
    );
    assert(
      !(T.toString().contains("NumberFilter")) ||
          this is NumberFilterInputController,
      "Use NumberFilterInputController instead",
    );
    assert(!(T == bool) || this is BoolInputController,
        "Use BoolInputController instead");
  }

  bool get hasValue => value != null;

  void dispose() {
    clear();
  }

  void clear() {
    value = null;
  }
}

/// An [InputController] subclass for a [Set], where the value of the controller
/// cannot be null. Instead of null, an empty [Set] is used.
class SetInputController<T> extends InputController<Set<T>> {
  @override
  Set<T> get value => super.value ?? {};

  @override
  set value(Set<T>? newValue) => super.value = newValue ?? {};
}

/// An [InputController] subclass for a [List], where the value of the
/// controller cannot be null. Instead of null, an empty [List] is used.
class ListInputController<T> extends InputController<List<T>> {
  @override
  List<T> get value => super.value ?? [];

  @override
  set value(List<T>? newValue) => super.value = newValue ?? [];
}

/// An [InputController] subclass for a [bool], where the value of the
/// controller cannot be null. Instead of null, false is used.
class BoolInputController extends InputController<bool> {
  @override
  bool get value => super.value ?? false;

  @override
  set value(bool? newValue) => super.value = newValue ?? false;
}

class IdInputController extends InputController<Id> {
  @override
  set value(Id? newValue) {
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
  final Validator? validator;

  TextInputController({
    TextEditingController? editingController,
    this.validator,
  })  : editingController = editingController ?? TextEditingController(),
        super();

  @override
  String? get value {
    var text = editingController.text.trim();
    if (isEmpty(text)) {
      return null;
    }
    return text;
  }

  @override
  set value(String? value) =>
      editingController.text = isEmpty(value) ? "" : value!.trim();

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

  bool isValid(BuildContext context) =>
      isEmpty(validator?.run(context, value)?.call(context));

  /// Validates the controller's input immediately. This should only be called
  /// in special cases where an input field's validity depends on another input
  /// field's value.
  ///
  /// In most cases, input fields are automatically validated when input
  /// changes.
  ///
  /// This method should be called within a [setState] call.
  void validate(BuildContext context) {
    error = validator?.run(context, value)?.call(context);
  }
}

class NumberInputController extends TextInputController {
  NumberInputController({
    TextEditingController? editingController,
    Validator? validator,
  }) : super(
          editingController: editingController ?? TextEditingController(),
          validator: validator ?? DoubleValidator(),
        );

  bool get hasDoubleValue => doubleValue != null;

  double? get doubleValue => value == null ? null : double.tryParse(value!);

  set doubleValue(double? value) => super.value = value?.toString();

  bool get hasIntValue => intValue != null;

  int? get intValue => value == null ? null : int.tryParse(value!);

  set intValue(int? value) => super.value = value?.toString();
}

class EmailInputController extends TextInputController {
  EmailInputController({
    TextEditingController? editingController,
    bool required = false,
  }) : super(
          editingController: editingController ?? TextEditingController(),
          validator: EmailValidator(required: required),
        );
}

class PasswordInputController extends TextInputController {
  PasswordInputController({
    TextEditingController? editingController,
  }) : super(
          editingController: editingController ?? TextEditingController(),
          validator: PasswordValidator(),
        );
}

/// A [TimestampInputController] value is always in milliseconds since Epoch
/// local time.
class TimestampInputController extends InputController<int> {
  final TimeManager timeManager;

  /// The date component of the controller.
  DateTime? _date;

  /// The time component of the controller.
  TimeOfDay? _time;

  TimestampInputController(
    this.timeManager, {
    DateTime? date,
    TimeOfDay? time,
  })  : _date = date,
        _time = time;

  /// Returns only the date portion of the controller's value. The time
  /// properties of the returned [DateTime] are all 0. If the controller's
  /// [_date] property is null, the current date is returned.
  DateTime get date {
    if (_date != null) {
      return _date!;
    }
    var now = timeManager.currentDateTime;
    return DateTime(now.year, now.month, now.day);
  }

  set date(DateTime? value) => _date = value;

  /// Returns the controller's [TimeOfDay] value. If the controller's
  /// [_time] property is null, the current time is returned.
  TimeOfDay get time =>
      _time ?? TimeOfDay.fromDateTime(timeManager.currentDateTime);

  set time(TimeOfDay? value) => _time = value;

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(value);

  @override
  int get value => combine(date, time).millisecondsSinceEpoch;

  @override
  set value(int? timestamp) {
    if (timestamp == null) {
      date = null;
      time = null;
      return;
    }
    date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    time = TimeOfDay.fromDateTime(date);
  }

  @override
  void clear() {
    super.clear();
    date = null;
    time = null;
  }
}

class NumberFilterInputController extends InputController<NumberFilter> {
  /// Returns true if a numerical value in [NumberFilter] is set.
  /// [value] may be non-null if the [MeasurementSystem] was updated, but values
  /// weren't actually set.
  bool get isSet => hasValue && value!.isSet;

  /// Returns true if this controller's value should be added to a [Report]
  /// object. A value should be added if it is set and the number boundary isn't
  /// "any".
  bool get shouldAddToReport =>
      isSet && value!.boundary != NumberBoundary.number_boundary_any;
}

class MultiMeasurementInputController
    extends InputController<MultiMeasurement> {
  /// Returns true if a numerical value in [MeasurementSystemValue] is set.
  /// [value] may be non-null if the [MeasurementSystem] was updated, but values
  /// weren't actually set.
  bool get isSet => hasValue && value!.isSet;
}
