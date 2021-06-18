import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../log.dart';
import '../model/fraction.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../user_preference_manager.dart';
import '../utils/number_utils.dart';
import '../utils/protobuf_utils.dart';
import 'input_controller.dart';
import 'text_input.dart';
import 'widget.dart';

enum ImperialFractionType {
  none,

  /// Renders a [TextInput] widget for fractional input, such as for whole
  /// inches or ounces.
  textField,

  /// Renders a [DropdownButton] with items for fractional inches, such as
  /// 1/8, 1/4, 1/2, etc.
  inchesDropdown,
}

/// A generic widget that gets input of measurement values and allows users to
/// switch between imperial and metric systems.
class MultiMeasurementInput extends StatefulWidget {
  /// See [MultiMeasurementInputSpec].
  final MultiMeasurementInputSpec spec;

  /// Invoked when the input or measurement system changes. To access the latest
  /// value, use [controller].
  final VoidCallback? onChanged;

  final MultiMeasurementInputController controller;

  /// A [NumberInputController] for the main input field. Defaults to
  /// [NumberInputController()].
  final NumberInputController? mainController;

  /// A [NumberInputController] for the fraction input field. Defaults to
  /// [NumberInputController()].
  final NumberInputController? fractionController;

  /// When true (default), includes an [PopupMenuButton] that allows the
  /// [MeasurementSystem] to be changed.
  final bool allowSystemSwitching;

  MultiMeasurementInput({
    required this.spec,
    required this.controller,
    this.onChanged,
    this.mainController,
    this.fractionController,
    this.allowSystemSwitching = true,
  });

  @override
  _MultiMeasurementInputState createState() => _MultiMeasurementInputState();
}

class _MultiMeasurementInputState extends State<MultiMeasurementInput> {
  static const _inchesDropdownWidth = 40.0;

  final _log = Log("MultiMeasurementInput");

  late final NumberInputController _mainController;
  late final NumberInputController _imperialFractionController;

  late MeasurementSystem _system;
  late Unit _mainUnit;
  late Unit? _imperialFractionUnit;

  bool get _isImperialWhole => _system == MeasurementSystem.imperial_whole;

  bool get _isImperialDecimal => _system == MeasurementSystem.imperial_decimal;

  bool get _isMetric => _system == MeasurementSystem.metric;

  @override
  void initState() {
    super.initState();

    _mainController = widget.mainController ?? NumberInputController();
    _imperialFractionController =
        widget.fractionController ?? NumberInputController();

    _resetSystem();

    if (widget.controller.hasValue) {
      var measurement = widget.controller.value!;
      _mainController.doubleValue =
          measurement.hasMainValue() ? measurement.mainValue.value : null;
      _imperialFractionController.doubleValue = measurement.hasFractionValue()
          ? measurement.fractionValue.value
          : null;
    }

    _roundValuesIfNeeded();
  }

  @override
  void didUpdateWidget(MultiMeasurementInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    _system = widget.controller.hasValue
        ? widget.controller.value?.system ?? _system
        : _system;
  }

  @override
  Widget build(BuildContext context) {
    var fractionType =
        widget.spec.imperialFractionType ?? ImperialFractionType.textField;

    var imperialWholeSuffix =
        _isImperialWhole && fractionType == ImperialFractionType.inchesDropdown
            ? null
            : widget.spec.imperialMainUnit.shorthandDisplayName(context);
    var metricSuffix = widget.spec.metricUnit.shorthandDisplayName(context);

    var wholeInput = TextInput.number(
      context,
      label: widget.spec.title,
      suffixText: _isImperialWhole || _isImperialDecimal
          ? imperialWholeSuffix
          : metricSuffix,
      controller: _mainController,
      decimal: _isMetric || _isImperialDecimal,
      signed: false,
      showMaxLength: false,
      onChanged: (_) => _notifyOnChanged(),
    );

    Widget? imperialFractionInput;
    Widget? inchesLabel;
    if (_isImperialWhole && fractionType != ImperialFractionType.none) {
      if (fractionType == ImperialFractionType.textField) {
        imperialFractionInput = Expanded(
          child: TextInput.number(
            context,
            // Keeps text field underline aligned with wholeInput.
            label: "",
            suffixText:
                widget.spec.imperialFractionUnit?.shorthandDisplayName(context),
            controller: _imperialFractionController,
            decimal: false,
            signed: false,
            showMaxLength: false,
            onChanged: (_) => _notifyOnChanged(),
          ),
        );
      } else if (fractionType == ImperialFractionType.inchesDropdown) {
        imperialFractionInput = SizedBox(
          width: _inchesDropdownWidth,
          child: _InchesDropdownInput(
            initialValue: _imperialFractionController.doubleValue,
            onChanged: (value) {
              _imperialFractionController.doubleValue = value;
              _notifyOnChanged();
            },
          ),
        );

        inchesLabel = Text(
          Unit.inches.shorthandDisplayName(context),
          style: styleInputSuffix(context),
        );
      } else {
        _log.w("Unknown fraction type: ${widget.spec.imperialFractionType}");
      }
    }

    return HorizontalSafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: wholeInput),
          imperialFractionInput == null
              ? Empty()
              : HorizontalSpace(paddingWidget),
          imperialFractionInput == null ? Empty() : imperialFractionInput,
          inchesLabel == null ? Empty() : HorizontalSpace(paddingWidget),
          inchesLabel == null ? Empty() : inchesLabel,
          HorizontalSpace(paddingWidgetSmall),
          _buildSystemSwitcher(),
        ],
      ),
    );
  }

  Widget _buildSystemSwitcher() {
    // Use Opacity here so the button still takes up space in the layout.
    // Right now, this feature is only used for lining up text fields in
    // NumberFilterInput.
    return Opacity(
      opacity: widget.allowSystemSwitching ? 1.0 : 0.0,
      child: SizedBox(
        width: iconSizeDefault,
        height: iconSizeDefault,
        child: PopupMenuButton<MeasurementSystem>(
          padding: insetsZero,
          // Need to offset the popup since we modified the default size
          // of the menu button.
          offset: Offset(0, -iconSizeDefault),
          icon: Icon(Icons.more_vert),
          itemBuilder: (context) => MeasurementSystem.values
              .map(
                (system) => PopupMenuItem<MeasurementSystem>(
                  value: system,
                  child: Text(system.displayName(context)),
                  enabled: system != _system,
                ),
              )
              .toList(),
          onSelected: (option) {
            setState(() => _updateSystem(option));
            _notifyOnChanged();
          },
        ),
      ),
    );
  }

  void _updateSystem(MeasurementSystem system) {
    _system = system;

    switch (_system) {
      case MeasurementSystem.imperial_whole:
        // When switching from imperial whole, round the metric
        // value to the nearest whole number, since the imperial whole
        // number cannot be a decimal.
        _roundValuesIfNeeded();
        _mainUnit = widget.spec.imperialMainUnit;
        _imperialFractionUnit = widget.spec.imperialFractionUnit;
        break;
      case MeasurementSystem.imperial_decimal:
        // Clear out fractional value when it isn't needed.
        _imperialFractionController.value = null;
        _mainUnit = widget.spec.imperialMainUnit;
        _imperialFractionUnit = null;
        break;
      case MeasurementSystem.metric:
        // Clear out fractional value when it isn't needed.
        _imperialFractionController.value = null;
        _mainUnit = widget.spec.metricUnit;
        _imperialFractionUnit = null;
        break;
    }
  }

  void _resetSystem() {
    var controllerSystem =
        widget.controller.hasValue && widget.controller.value!.hasSystem()
            ? widget.controller.value!.system
            : null;
    _updateSystem(controllerSystem ??
        widget.spec.defaultSystem ??
        MeasurementSystem.imperial_whole);
  }

  void _notifyOnChanged() {
    var main = Measurement(unit: _mainUnit);
    if (_mainController.hasDoubleValue) {
      main.value = _mainController.doubleValue!;
    }

    var fraction = Measurement(unit: _imperialFractionUnit);
    if (_imperialFractionController.hasDoubleValue) {
      fraction.value = _imperialFractionController.doubleValue!;
    }

    widget.controller.value = MultiMeasurement(
      system: _system,
      mainValue: main,
      fractionValue: fraction,
    );
    widget.onChanged?.call();
  }

  void _roundValuesIfNeeded() {
    if (_mainController.hasDoubleValue &&
        (_mainController.doubleValue!.isWhole || _isImperialWhole)) {
      _mainController.value = _mainController.doubleValue?.round().toString();
    }

    // Only round values if not using inches; inch values are stored as
    // decimals.
    //
    // Only round values if a value exists, otherwise the value will be set to
    // 0.0, which is not what we want; we want users to explicitly enter
    // values.
    if (widget.spec.imperialFractionType !=
            ImperialFractionType.inchesDropdown &&
        _imperialFractionController.hasValue) {
      _imperialFractionController.value =
          _imperialFractionController.doubleValue?.round().toString();
    }
  }
}

class MultiMeasurementInputSpec {
  /// The title of the input. Renders as the title of the "main" [TextInput].
  final String? title;

  /// The main imperial unit, such as feet.
  final Unit imperialMainUnit;

  /// The fractional unit of the imperial system value, such as inches. If null,
  /// a fractional input will not be rendered at all.
  final Unit? imperialFractionUnit;

  /// The type of fractional input for imperial system. This determines what
  /// kind of widget is rendered. If null, [ImperialFractionType.textField] is
  /// used.
  final ImperialFractionType? imperialFractionType;

  final Unit metricUnit;
  final MeasurementSystem? defaultSystem;

  MultiMeasurementInputSpec({
    this.title,
    required this.imperialMainUnit,
    this.imperialFractionUnit,
    this.imperialFractionType,
    required this.metricUnit,
    this.defaultSystem,
  });

  MultiMeasurementInputSpec.length(BuildContext context)
      : this(
          title: Strings.of(context).catchFieldLengthLabel,
          imperialMainUnit: Unit.inches,
          imperialFractionType: ImperialFractionType.inchesDropdown,
          metricUnit: Unit.centimeters,
          defaultSystem: UserPreferenceManager.of(context).catchLengthSystem,
        );

  MultiMeasurementInputSpec.weight(BuildContext context)
      : this(
          title: Strings.of(context).catchFieldWeightLabel,
          imperialMainUnit: Unit.pounds,
          imperialFractionUnit: Unit.ounces,
          metricUnit: Unit.kilograms,
          defaultSystem: UserPreferenceManager.of(context).catchWeightSystem,
        );

  MultiMeasurementInputSpec.waterDepth(BuildContext context)
      : this(
          title: Strings.of(context).catchFieldWaterDepthLabel,
          imperialMainUnit: Unit.feet,
          imperialFractionUnit: Unit.inches,
          imperialFractionType: ImperialFractionType.textField,
          metricUnit: Unit.meters,
          defaultSystem: UserPreferenceManager.of(context).waterDepthSystem,
        );

  MultiMeasurementInputSpec.waterTemperature(BuildContext context)
      : this(
          title: Strings.of(context).catchFieldWaterTemperatureLabel,
          imperialMainUnit: Unit.fahrenheit,
          imperialFractionType: ImperialFractionType.none,
          metricUnit: Unit.celsius,
          defaultSystem:
              UserPreferenceManager.of(context).waterTemperatureSystem,
        );

  MultiMeasurementInputSpec.windSpeed(BuildContext context)
      : this(
          title: Strings.of(context).atmosphereInputWindSpeed,
          imperialMainUnit: Unit.miles_per_hour,
          imperialFractionType: ImperialFractionType.none,
          metricUnit: Unit.kilometers_per_hour,
          defaultSystem: UserPreferenceManager.of(context).windSpeedSystem,
        );

  MultiMeasurementInputSpec.airTemperature(BuildContext context)
      : this(
          title: Strings.of(context).atmosphereInputTemperature,
          imperialMainUnit: Unit.fahrenheit,
          imperialFractionType: ImperialFractionType.none,
          metricUnit: Unit.celsius,
          defaultSystem: UserPreferenceManager.of(context).airTemperatureSystem,
        );

  MultiMeasurementInputSpec.airPressure(BuildContext context)
      : this(
          title: Strings.of(context).atmosphereInputAtmosphericPressure,
          imperialMainUnit: Unit.pounds_per_square_inch,
          imperialFractionType: ImperialFractionType.none,
          metricUnit: Unit.millibars,
          defaultSystem: UserPreferenceManager.of(context).airPressureSystem,
        );

  MultiMeasurementInputSpec.airVisibility(BuildContext context)
      : this(
          title: Strings.of(context).atmosphereInputAirVisibility,
          imperialMainUnit: Unit.miles,
          imperialFractionType: ImperialFractionType.none,
          metricUnit: Unit.kilometers,
          defaultSystem: UserPreferenceManager.of(context).airVisibilitySystem,
        );

  MultiMeasurementInputSpec copyWith({
    String? title,
    Unit? imperialMainUnit,
    Unit? imperialFractionUnit,
    ImperialFractionType? imperialFractionType,
    Unit? metricUnit,
    MeasurementSystem? defaultSystem,
  }) {
    return MultiMeasurementInputSpec(
      title: title ?? this.title,
      imperialMainUnit: imperialMainUnit ?? this.imperialMainUnit,
      imperialFractionUnit: imperialFractionUnit ?? this.imperialFractionUnit,
      imperialFractionType: imperialFractionType ?? this.imperialFractionType,
      metricUnit: metricUnit ?? this.metricUnit,
      defaultSystem: defaultSystem ?? this.defaultSystem,
    );
  }
}

class _InchesDropdownInput extends StatefulWidget {
  final double? initialValue;
  final void Function(double?)? onChanged;

  _InchesDropdownInput({
    this.initialValue,
    this.onChanged,
  });

  @override
  __InchesDropdownInputState createState() => __InchesDropdownInputState();
}

class __InchesDropdownInputState extends State<_InchesDropdownInput> {
  late Fraction _value;

  @override
  void initState() {
    super.initState();
    _value = Fraction.fromValue(widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Fraction>(
      underline: Empty(),
      value: _value,
      items: Fraction.all
          .map((f) =>
              DropdownMenuItem<Fraction>(child: Text(f.symbol), value: f))
          .toList(),
      onChanged: (fraction) {
        setState(() => _value = fraction ?? Fraction.zero);
        widget.onChanged?.call(fraction?.value);
      },
    );
  }
}
