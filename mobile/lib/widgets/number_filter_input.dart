import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/form_page.dart';
import '../res/dimen.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../utils/validator.dart';
import 'input_controller.dart';
import 'list_picker_input.dart';
import 'multi_measurement_input.dart';
import 'radio_input.dart';
import 'text_input.dart';
import 'widget.dart';

class NumberFilterInput extends StatefulWidget {
  final String title;

  /// The title of the page shown when [NumberFilterInput] is tapped.
  final String filterTitle;

  final NumberFilterInputController controller;

  /// See [_NumberFilterPage.inputState].
  final MultiMeasurementInputState? inputState;

  NumberFilterInput({
    required this.title,
    required this.filterTitle,
    required this.controller,
    this.inputState,
  });

  @override
  _NumberFilterInputState createState() => _NumberFilterInputState();
}

class _NumberFilterInputState extends State<NumberFilterInput> {
  NumberFilter get value => widget.controller.value!;

  @override
  void initState() {
    super.initState();

    if (widget.controller.value == null) {
      widget.controller.value = NumberFilter(
        boundary: NumberBoundary.number_boundary_any,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListPickerInput(
      title: widget.title,
      value: value.displayValue(context),
      onTap: () {
        push(
          context,
          _NumberFilterPage(
            title: widget.filterTitle,
            initialValue: value,
            inputState: widget.inputState,
            onChanged: (numberFilter) =>
                setState(() => widget.controller.value = numberFilter),
          ),
        );
      },
    );
  }
}

class _NumberFilterPage extends StatefulWidget {
  final String title;
  final NumberFilter initialValue;

  /// If null, will show standard [TextField.number] for whole number input.
  final MultiMeasurementInputState? inputState;

  final ValueChanged<NumberFilter>? onChanged;

  _NumberFilterPage({
    required this.title,
    required this.initialValue,
    required this.inputState,
    this.onChanged,
  });

  @override
  __NumberFilterPageState createState() => __NumberFilterPageState();
}

class __NumberFilterPageState extends State<_NumberFilterPage> {
  static final _idBoundary = randomId();
  static final _idFromValue = randomId();
  static final _idToValue = randomId();

  final _boundaryController = InputController<NumberBoundary>();

  // Spec for input with units, such as [Catch.waterTemperature].
  late final MultiMeasurementInputState _fromMeasurementState;
  late final MultiMeasurementInputState _toMeasurementState;

  // Controllers for input without units, such as [Catch.quantity].
  late final NumberInputController _fromNumberController;
  late final NumberInputController _toNumberController;

  bool get _inputHasUnits => widget.inputState != null;

  NumberFilter get _initialValue => widget.initialValue;

  MultiMeasurementInputController get _fromMeasurementController =>
      _fromMeasurementState.controller;

  NumberInputController get _fromMeasurementMainController =>
      _fromMeasurementController.mainController;

  MultiMeasurementInputController get _toMeasurementController =>
      _toMeasurementState.controller;

  NumberInputController get _toMeasurementMainController =>
      _toMeasurementController.mainController;

  @override
  void initState() {
    super.initState();

    _boundaryController.value = _initialValue.hasBoundary()
        ? _initialValue.boundary
        : NumberBoundary.number_boundary_any;

    _initMeasurementInput();
    _initNumberInput();
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      title: Text(widget.title),
      showSaveButton: false,
      fieldBuilder: (context) => {
        _idBoundary: _buildBoundary(),
        _idFromValue: _buildFromValue(),
        _idToValue: _buildToValue(),
      },
    );
  }

  Widget _buildBoundary() {
    return Padding(
      padding: insetsTopDefault,
      child: RadioInput(
        initialSelectedIndex: _boundaryController.value!.value,
        optionCount: NumberBoundary.values.length,
        optionBuilder: (context, i) =>
            NumberBoundary.values[i].displayName(context),
        onSelect: (i) {
          setState(() {
            _boundaryController.value = NumberBoundary.values[i];
            _notifyIfNeeded();
          });
        },
      ),
    );
  }

  Widget _buildFromValue() {
    var label = _boundaryController.value == NumberBoundary.range
        ? Strings.of(context).numberFilterInputFrom
        : Strings.of(context).numberFilterInputValue;

    Widget child;
    if (_boundaryController.value == NumberBoundary.number_boundary_any) {
      child = Empty();
    } else if (widget.inputState == null) {
      child = TextInput.number(
        context,
        label: label,
        controller: _fromNumberController,
        decimal: false,
        signed: false,
        onChanged: (_) => setState(() {
          _toNumberController.validate(context);
          _notifyIfNeeded();
        }),
      );
    } else {
      _fromMeasurementState.title = (_) => label;

      child = MultiMeasurementInput(
        state: _fromMeasurementState,
        allowSystemSwitching: true,
        onChanged: () => setState(() {
          // Must update units before validation so the correct units are
          // being compared.
          _updateToInputUnits();
          _toMeasurementMainController.validate(context);
          _notifyIfNeeded();
        }),
      );
    }

    return AnimatedSwitcher(
      duration: defaultAnimationDuration,
      child: child,
    );
  }

  Widget _buildToValue() {
    var label = Strings.of(context).numberFilterInputTo;

    Widget child;
    if (_boundaryController.value != NumberBoundary.range) {
      child = Empty();
    } else if (widget.inputState == null) {
      child = TextInput.number(
        context,
        label: label,
        controller: _toNumberController,
        decimal: false,
        signed: false,
        onChanged: (_) => _notifyIfNeeded(),
      );
    } else {
      _toMeasurementState.title = (_) => label;

      child = MultiMeasurementInput(
        state: _toMeasurementState,
        allowSystemSwitching: false,
        onChanged: () => setState(() {
          // Need to validate, in case the fraction input changed.
          _toMeasurementMainController.validate(context);
          _notifyIfNeeded();
        }),
      );
    }

    return AnimatedSwitcher(
      duration: defaultAnimationDuration,
      child: child,
    );
  }

  void _notifyIfNeeded() {
    NumberFilter? filter;
    if (_inputHasUnits) {
      filter = _createNumberFilterForUnitInput();
    } else {
      filter = _createNumberFilterForNonUnitInput();
    }

    if (filter != null) {
      widget.onChanged?.call(filter);
    }
  }

  NumberFilter? _createNumberFilterForUnitInput() {
    if (!_inputHasUnits ||
        !_fromMeasurementMainController.isValid(context) ||
        (_boundaryController.value == NumberBoundary.range &&
            !_toMeasurementMainController.isValid(context))) {
      return null;
    }

    var filter = NumberFilter();
    filter.boundary = _boundaryController.value!;

    if (_fromMeasurementController.hasValue) {
      filter.from = _fromMeasurementController.value!;
    }

    if (_toMeasurementController.hasValue) {
      filter.to = _toMeasurementController.value!;
    }

    return filter;
  }

  NumberFilter? _createNumberFilterForNonUnitInput() {
    if (_inputHasUnits ||
        !_fromNumberController.isValid(context) ||
        (_boundaryController.value == NumberBoundary.range &&
            !_toNumberController.isValid(context))) {
      return null;
    }

    var filter = NumberFilter();
    filter.boundary = _boundaryController.value!;

    if (_fromNumberController.hasDoubleValue) {
      filter.from = MultiMeasurement(
        mainValue: Measurement(
          value: _fromNumberController.doubleValue!,
        ),
      );
    }

    if (_toNumberController.hasDoubleValue) {
      filter.to = MultiMeasurement(
        mainValue: Measurement(
          value: _toNumberController.doubleValue!,
        ),
      );
    }

    return filter;
  }

  void _updateToInputUnits() {
    if (!_fromMeasurementController.hasValue) {
      return;
    }

    var newEnd = _toMeasurementController.value ?? MultiMeasurement();

    if (_fromMeasurementController.value!.hasSystem()) {
      newEnd = newEnd.toSystem(_fromMeasurementController.value!.system);
    }

    _toMeasurementController.value = newEnd;
  }

  void _initMeasurementInput() {
    if (!_inputHasUnits) {
      return;
    }

    _fromMeasurementState = widget.inputState!.copy(
      mainController: NumberInputController(
        validator: EmptyValidator(),
      ),
    );

    _toMeasurementState = widget.inputState!.copy(
      mainController: NumberInputController(
        validator: RangeValidator(runner: (context, newValue) {
          if (_toMeasurementController.hasValue &&
              _fromMeasurementController.hasValue &&
              _fromMeasurementController.value! >=
                  _toMeasurementController.value!) {
            return (context) => format(
                Strings.of(context).filterPageInvalidEndValue,
                [_fromMeasurementController.value!.displayValue(context)]);
          }
          return null;
        }),
      ),
    );

    _fromMeasurementState.controller.value =
        _initialValue.hasFrom() ? _initialValue.from : null;
    _toMeasurementState.controller.value =
        _initialValue.hasTo() ? _initialValue.to : null;
  }

  void _initNumberInput() {
    if (_inputHasUnits) {
      return;
    }

    _fromNumberController = NumberInputController(
      validator: EmptyValidator(),
    );

    _toNumberController = NumberInputController(
      validator: RangeValidator(runner: (context, newValue) {
        if (_fromNumberController.hasIntValue &&
            _toNumberController.hasIntValue &&
            _toNumberController.intValue! <= _fromNumberController.intValue!) {
          return (context) => format(
              Strings.of(context).filterPageInvalidEndValue,
              [_fromNumberController.intValue!]);
        }
        return null;
      }),
    );

    _fromNumberController.intValue = _initialValue.hasFrom() &&
            _initialValue.from.hasMainValue() &&
            _initialValue.from.mainValue.hasValue()
        ? _initialValue.from.mainValue.value.round()
        : null;

    _toNumberController.intValue = _initialValue.hasTo() &&
            _initialValue.to.hasMainValue() &&
            _initialValue.to.mainValue.hasValue()
        ? _initialValue.to.mainValue.value.round()
        : null;
  }
}
