import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../log.dart';
import '../model/fraction.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../user_preference_manager.dart';
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
  /// See [MultiMeasurementInputState].
  final MultiMeasurementInputState state;

  /// Invoked when the input or measurement system changes. To access the latest
  /// value, use [state.controller].
  final VoidCallback? onChanged;

  /// When true (default), includes an [PopupMenuButton] that allows the
  /// [MeasurementSystem] to be changed.
  final bool allowSystemSwitching;

  MultiMeasurementInput({
    required this.state,
    this.onChanged,
    this.allowSystemSwitching = true,
  });

  @override
  _MultiMeasurementInputState createState() => _MultiMeasurementInputState();
}

class _MultiMeasurementInputState extends State<MultiMeasurementInput> {
  static const _inchesDropdownWidth = 40.0;

  final _log = Log("MultiMeasurementInput");

  MultiMeasurementInputController get _controller => widget.state.controller;

  MeasurementSystem get _system => _controller.system;

  bool get _isImperialWhole => _system == MeasurementSystem.imperial_whole;

  bool get _isImperialDecimal => _system == MeasurementSystem.imperial_decimal;

  bool get _isMetric => _system == MeasurementSystem.metric;

  @override
  void initState() {
    super.initState();
    _updateSystem(_controller.system);
  }

  @override
  Widget build(BuildContext context) {
    var fractionType =
        widget.state.imperialFractionType ?? ImperialFractionType.textField;

    var imperialWholeSuffix =
        _isImperialWhole && fractionType == ImperialFractionType.inchesDropdown
            ? null
            : widget.state.imperialMainUnit.shorthandDisplayName(context);
    var metricSuffix = widget.state.metricUnit.shorthandDisplayName(context);

    var wholeInput = TextInput.number(
      context,
      label: widget.state.title?.call(context),
      suffixText: _isImperialWhole || _isImperialDecimal
          ? imperialWholeSuffix
          : metricSuffix,
      controller: _controller.mainController,
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
            suffixText: widget.state.imperialFractionUnit
                ?.shorthandDisplayName(context),
            controller: _controller.fractionController,
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
            initialValue: _controller.fractionController.doubleValue,
            onChanged: (value) {
              _controller.fractionController.doubleValue = value;
              _notifyOnChanged();
            },
          ),
        );

        inchesLabel = Text(
          Unit.inches.shorthandDisplayName(context),
          style: styleSecondary(context),
        );
      } else {
        _log.w("Unknown fraction type: ${widget.state.imperialFractionType}");
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
    _controller.system = system;

    switch (_system) {
      case MeasurementSystem.imperial_whole:
        _controller.mainUnit = widget.state.imperialMainUnit;
        _controller.fractionUnit = widget.state.imperialFractionUnit;
        break;
      case MeasurementSystem.imperial_decimal:
        // Clear out fractional value when it isn't needed.
        _controller.fractionController.clear();
        _controller.mainUnit = widget.state.imperialMainUnit;
        _controller.fractionUnit = null;
        break;
      case MeasurementSystem.metric:
        // Clear out fractional value when it isn't needed.
        _controller.fractionController.clear();
        _controller.mainUnit = widget.state.metricUnit;
        _controller.fractionUnit = null;
        break;
    }
  }

  void _notifyOnChanged() => widget.onChanged?.call();
}

/// A state object to manipulate the different values in a
/// [MultiMeasurementInput] widget.
class MultiMeasurementInputState {
  /// The title of the input. Renders as the title of the "main" [TextInput].
  String Function(BuildContext)? title;

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

  late final MultiMeasurementInputController controller;

  MultiMeasurementInputState({
    this.title,
    required this.imperialMainUnit,
    this.imperialFractionUnit,
    this.imperialFractionType,
    required this.metricUnit,
    this.defaultSystem,
    NumberInputController? mainController,
    NumberInputController? fractionController,
  }) {
    if (defaultSystem == null) {
      controller = MultiMeasurementInputController(
        system: MeasurementSystem.imperial_whole,
        mainUnit: imperialMainUnit,
        fractionUnit: imperialFractionUnit,
        mainController: mainController,
        fractionController: fractionController,
      );
    } else {
      controller = MultiMeasurementInputController(
        system: defaultSystem!,
        mainUnit: defaultSystem!.isMetric ? metricUnit : imperialMainUnit,
        fractionUnit: imperialFractionUnit,
        mainController: mainController,
        fractionController: fractionController,
      );
    }
  }

  MultiMeasurementInputState.length(BuildContext context)
      : this(
          title: (context) => Strings.of(context).catchFieldLengthLabel,
          imperialMainUnit: Unit.inches,
          imperialFractionType: ImperialFractionType.inchesDropdown,
          metricUnit: Unit.centimeters,
          defaultSystem: UserPreferenceManager.of(context).catchLengthSystem,
        );

  MultiMeasurementInputState.weight(BuildContext context)
      : this(
          title: (context) => Strings.of(context).catchFieldWeightLabel,
          imperialMainUnit: Unit.pounds,
          imperialFractionUnit: Unit.ounces,
          metricUnit: Unit.kilograms,
          defaultSystem: UserPreferenceManager.of(context).catchWeightSystem,
        );

  MultiMeasurementInputState.waterDepth(BuildContext context)
      : this(
          title: (context) => Strings.of(context).catchFieldWaterDepthLabel,
          imperialMainUnit: Unit.feet,
          imperialFractionUnit: Unit.inches,
          imperialFractionType: ImperialFractionType.textField,
          metricUnit: Unit.meters,
          defaultSystem: UserPreferenceManager.of(context).waterDepthSystem,
        );

  MultiMeasurementInputState.waterTemperature(BuildContext context)
      : this(
          title: (context) =>
              Strings.of(context).catchFieldWaterTemperatureLabel,
          imperialMainUnit: Unit.fahrenheit,
          imperialFractionType: ImperialFractionType.none,
          metricUnit: Unit.celsius,
          defaultSystem:
              UserPreferenceManager.of(context).waterTemperatureSystem,
        );

  MultiMeasurementInputState.windSpeed(BuildContext context)
      : this(
          title: (context) => Strings.of(context).atmosphereInputWindSpeed,
          imperialMainUnit: Unit.miles_per_hour,
          imperialFractionType: ImperialFractionType.none,
          metricUnit: Unit.kilometers_per_hour,
          defaultSystem: UserPreferenceManager.of(context).windSpeedSystem,
        );

  MultiMeasurementInputState.airTemperature(BuildContext context)
      : this(
          title: (context) => Strings.of(context).atmosphereInputTemperature,
          imperialMainUnit: Unit.fahrenheit,
          imperialFractionType: ImperialFractionType.none,
          metricUnit: Unit.celsius,
          defaultSystem: UserPreferenceManager.of(context).airTemperatureSystem,
        );

  MultiMeasurementInputState.airPressure(BuildContext context)
      : this(
          title: (context) =>
              Strings.of(context).atmosphereInputAtmosphericPressure,
          imperialMainUnit: Unit.pounds_per_square_inch,
          imperialFractionType: ImperialFractionType.none,
          metricUnit: Unit.millibars,
          defaultSystem: UserPreferenceManager.of(context).airPressureSystem,
        );

  MultiMeasurementInputState.airVisibility(BuildContext context)
      : this(
          title: (context) => Strings.of(context).atmosphereInputAirVisibility,
          imperialMainUnit: Unit.miles,
          imperialFractionType: ImperialFractionType.none,
          metricUnit: Unit.kilometers,
          defaultSystem: UserPreferenceManager.of(context).airVisibilitySystem,
        );

  MultiMeasurementInputState copy({
    String Function(BuildContext)? title,
    Unit? imperialMainUnit,
    Unit? imperialFractionUnit,
    ImperialFractionType? imperialFractionType,
    Unit? metricUnit,
    MeasurementSystem? defaultSystem,
    NumberInputController? mainController,
    NumberInputController? fractionController,
  }) {
    return MultiMeasurementInputState(
      title: title ?? this.title,
      imperialMainUnit: imperialMainUnit ?? this.imperialMainUnit,
      imperialFractionUnit: imperialFractionUnit ?? this.imperialFractionUnit,
      imperialFractionType: imperialFractionType ?? this.imperialFractionType,
      metricUnit: metricUnit ?? this.metricUnit,
      defaultSystem: defaultSystem ?? this.defaultSystem,
      mainController: mainController ?? controller.mainController,
      fractionController: fractionController ?? controller.fractionController,
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
