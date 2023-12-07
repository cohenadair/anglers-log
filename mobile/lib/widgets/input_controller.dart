import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/widgets/multi_measurement_input.dart';
import 'package:quiver/strings.dart';
import 'package:timezone/timezone.dart';

import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../time_manager.dart';
import '../utils/date_time_utils.dart';
import '../utils/number_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/validator.dart';

/// A class for storing a value of an input widget, such as a text field or
/// check box.
class InputController<T> extends ValueNotifier<T?> {
  /// The current error message for the [InputController], if there is one.
  String? error;

  InputController({T? value}) : super(value) {
    assert(!(T == Id) || this is IdInputController,
        "Use IdInputController instead");
    assert(!(T.toString().contains("Set")) || this is SetInputController,
        "Use SetInputController<T> instead");
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

  void clear() {
    value = null;
  }
}

/// An [InputController] subclass for a [Set], where the value of the controller
/// cannot be null. Instead of null, an empty [Set] is used.
class SetInputController<T> extends InputController<Set<T>> {
  final _log = Log("SetInputController<${T.runtimeType}>");

  @override
  Set<T> get value => super.value ?? {};

  @override
  set value(Set<T>? newValue) => super.value = newValue ?? {};

  @override
  bool get hasValue {
    _log.w("hasValue will always return true; did you mean to call isEmpty?");
    return super.hasValue;
  }

  bool get isEmpty => value.isEmpty;

  bool get isNotEmpty => value.isNotEmpty;

  void addAll(Iterable<T> items) => value = Set.of(value)..addAll(items);

  void remove(T item) => value = Set.of(value)..remove(item);
}

/// An [InputController] subclass for a [List], where the value of the
/// controller cannot be null. Instead of null, an empty [List] is used.
class ListInputController<T> extends InputController<List<T>> {
  final _log = Log("ListInputController<${T.runtimeType}>");

  ListInputController({List<T>? value}) : super(value: value) {
    assert(!(T == PickedImage) || this is ImagesInputController,
        "Use ImagesInputController instead");
  }

  @override
  List<T> get value => super.value ?? [];

  @override
  set value(List<T>? newValue) => super.value = newValue ?? [];

  @override
  bool get hasValue {
    _log.w(
        "hasValue will always return true; did you mean to use value.isEmpty?");
    return super.hasValue;
  }

  void addAll(Iterable<T> items) => value = List.of(value)..addAll(items);

  void remove(T item) => value = List.of(value)..remove(item);
}

class ImagesInputController extends SetInputController<PickedImage> {
  List<File> get originalFiles => value
      .where((img) => img.originalFile != null)
      .map((img) => img.originalFile!)
      .toList();
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
  Validator? validator;

  TextInputController({
    TextEditingController? editingController,
    this.validator,
  })  : editingController = editingController ?? TextEditingController(),
        super();

  TextInputController.name() : this(validator: NameValidator());

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
    super.dispose();
  }

  @override
  void clear() {
    editingController.clear();
  }

  void clearText() {
    editingController.value = const TextEditingValue(text: "");
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
  /// Set when a user selects a unit from a
  /// [MultiMeasurementInputSpec.availableUnits] dropdown.
  Unit? selectedUnit;

  NumberInputController({
    TextEditingController? editingController,
    Validator? validator,
  }) : super(
          editingController: editingController ?? TextEditingController(),
          validator: validator ?? DoubleValidator(),
        );

  bool get hasDoubleValue => doubleValue != null;

  double? get doubleValue =>
      value == null ? null : Doubles.tryLocaleParse(value!);

  set doubleValue(double? value) => super.value = value?.displayValue();

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

/// A controller for picking a date and time. Both the [date] and [time] fields
/// default to null. For a controller that defaults to the current date and
/// time, see [CurrentDateTimeInputController].
class DateTimeInputController extends InputController<TZDateTime?> {
  final BuildContext context;

  /// The date component of the controller. Defaults to null.
  TZDateTime? date;

  /// The time component of the controller. Defaults to null.
  TimeOfDay? time;

  DateTimeInputController(
    this.context, {
    TZDateTime? value,
  }) {
    this.value = value;
  }

  /// Sets the time zone of the controller. If [date] is null, this method
  /// does nothing.
  set timeZone(String timeZone) {
    var date = this.date;
    if (date == null) {
      return;
    }
    this.date = dateTimeToDayAccuracy(date, timeZone);
  }

  bool get isMidnight =>
      time == null ? false : (time!.hour == 0 && time!.minute == 0);

  @override
  TZDateTime? get value => combine(context, date, time);

  @override
  set value(TZDateTime? dateTime) {
    if (dateTime == null) {
      date = null;
      time = null;
      return;
    }
    date = dateTimeToDayAccuracy(dateTime, dateTime.locationName);
    time = TimeOfDay.fromDateTime(dateTime);

    // TODO: Listeners aren't notified when date and time variables are set.
    super.value = value;
  }

  @override
  void clear() {
    super.clear();
    date = null;
    time = null;
  }

  @override
  bool get hasValue => value != null;

  int? get timestamp => value?.millisecondsSinceEpoch;
}

/// A [DateTimeInputController] that defaults to the current date and time.
class CurrentDateTimeInputController extends DateTimeInputController {
  CurrentDateTimeInputController(BuildContext context)
      : super(
          context,
          value: TimeManager.of(context).currentDateTime,
        );

  @override
  TZDateTime get date => super.date!;

  @override
  TimeOfDay get time => super.time!;

  @override
  TZDateTime get value => super.value!;

  @override
  int get timestamp => super.timestamp!;
}

class TimeZoneInputController extends InputController<String> {
  final BuildContext context;

  TimeManager get _timeManager => TimeManager.of(context);

  TimeZoneInputController(this.context);

  /// If the current value is empty, always returns the current time zone.
  @override
  String get value =>
      isEmpty(super.value) ? _timeManager.currentLocation.name : super.value!;
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
  static const _log = Log("MultiMeasurementInputController");

  final BuildContext context;
  final NumberInputController mainController;
  final NumberInputController fractionController;
  final MultiMeasurementInputSpec spec;

  // Values that override the controller's MultiMeasurementInputSpec. These
  // values will be non-null when the controller's value is explicitly set, such
  // as when editing an entity.
  MeasurementSystem? _systemOverride;
  Unit? _mainUnitOverride;
  Unit? _fractionUnitOverride;

  late StreamSubscription<void> preferenceSubscription;

  MultiMeasurementInputController({
    required this.context,
    required this.spec,
    NumberInputController? mainController,
    NumberInputController? fractionController,
  })  : mainController = mainController ?? NumberInputController(),
        fractionController = fractionController ?? NumberInputController();

  @override
  bool get hasValue {
    _log.w("hasValue will always return true. Do you mean to call isSet?");
    return super.hasValue;
  }

  @override
  set value(MultiMeasurement? newValue) {
    if (newValue == null) {
      mainController.clear();
      fractionController.clear();
      super.value = null;
    } else {
      if (newValue.hasSystem()) {
        _systemOverride = newValue.system;
      }

      mainController.doubleValue =
          newValue.mainValue.hasValue() ? newValue.mainValue.value : null;
      if (newValue.mainValue.hasUnit()) {
        _mainUnitOverride = newValue.mainValue.unit;
      }

      fractionController.doubleValue = newValue.fractionValue.hasValue()
          ? newValue.fractionValue.value
          : null;
      _fractionUnitOverride =
          newValue.fractionValue.hasUnit() ? newValue.fractionValue.unit : null;

      _round();
      super.value = value;
    }
  }

  @override
  MultiMeasurement get value {
    var result = MultiMeasurement(system: system);

    if (mainController.hasDoubleValue) {
      result.mainValue = Measurement(
        unit: _mainUnit,
        value: mainController.doubleValue,
      );
    }

    // Only record fraction values if the system is imperial whole.
    if (result.system == MeasurementSystem.imperial_whole &&
        fractionController.hasDoubleValue) {
      var measurement = Measurement(
        value: fractionController.doubleValue,
      );

      if (_fractionUnit != null) {
        measurement.unit = _fractionUnit!;
      }

      result.fractionValue = measurement;
    }

    return result;
  }

  MeasurementSystem get system => _system;

  /// Returns true if a numerical value in [value] is set to a non-null value.
  bool get isSet => value.isSet;

  /// Rounds values to a reasonable value for displaying to the user.
  void _round() {
    mainController.value = mainController.doubleValue?.displayValue(
        decimalPlaces: spec.mainValueDecimalPlaces?.call(context));

    // Round to whole number if using imperial_whole system.
    if (mainController.hasDoubleValue &&
        _system == MeasurementSystem.imperial_whole) {
      mainController.value = mainController.doubleValue?.round().toString();
    }

    // Round all fractional values whose main unit is not inches. Inch fraction
    // values are stored as decimals.
    //
    // Only round values if a value exists, otherwise the value will be set to
    // 0.0, which is not what we want; we want users to explicitly enter
    // values.
    //
    // Note that fractionController should never have an imperial_decimal
    // unit. Instead, mainController should be used with imperial_decimal.
    if (_fractionUnit != null &&
        _mainUnit != Unit.inches &&
        fractionController.hasValue) {
      fractionController.value =
          fractionController.doubleValue?.round().toString();
    }
  }

  MeasurementSystem get _system =>
      _systemOverride ??
      spec.system?.call(context) ??
      MeasurementSystem.imperial_whole;

  Unit get _mainUnit {
    var unit =
        _system.isMetric ? spec.metricUnit : spec.imperialUnit?.call(context);
    return mainController.selectedUnit ??
        _mainUnitOverride ??
        unit ??
        spec.availableUnits.first;
  }

  Unit? get _fractionUnit => _fractionUnitOverride ?? spec.fractionUnit;
}
