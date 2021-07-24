import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../model/fraction.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../user_preference_manager.dart';
import '../utils/protobuf_utils.dart';
import 'input_controller.dart';
import 'text_input.dart';
import 'widget.dart';

/// A generic widget that gets input of measurement values and allows users to
/// switch between imperial and metric systems.
class MultiMeasurementInput extends StatelessWidget {
  static const _inchesDropdownWidth = 40.0;

  final MultiMeasurementInputSpec spec;
  final MultiMeasurementInputController controller;

  /// A title for the main text input. This will override
  /// [MultiMeasurementInputSpec.title].
  final String? title;

  /// Invoked when the input or measurement system changes. To access the latest
  /// value, use [state.controller].
  final VoidCallback? onChanged;

  MultiMeasurementInput({
    required this.spec,
    required this.controller,
    this.title,
    this.onChanged,
  });

  MeasurementSystem get _system => controller.system;

  bool get _isImperialWhole => _system == MeasurementSystem.imperial_whole;

  bool get _isImperialDecimal => _system == MeasurementSystem.imperial_decimal;

  bool get _isMetric => _system == MeasurementSystem.metric;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MultiMeasurement?>(
      valueListenable: controller,
      builder: (context, _, __) => _buildInput(context),
    );
  }

  Widget _buildInput(BuildContext context) {
    var imperialWholeSuffix = _isImperialWhole && spec.imperial == Unit.inches
        ? null
        : spec.imperial.shorthandDisplayName(context);
    var metricSuffix = spec.metric.shorthandDisplayName(context);

    var wholeInput = TextInput.number(
      context,
      label: title ?? spec.title?.call(context),
      suffixText: _isImperialWhole || _isImperialDecimal
          ? imperialWholeSuffix
          : metricSuffix,
      controller: controller.mainController,
      decimal: _isMetric || _isImperialDecimal,
      signed: false,
      showMaxLength: false,
      onChanged: (_) => onChanged?.call(),
    );

    Widget? imperialFractionInput;
    Widget? inchesLabel;
    if (_isImperialWhole) {
      if (spec.imperial == Unit.inches) {
        imperialFractionInput = SizedBox(
          width: _inchesDropdownWidth,
          child: _InchesDropdownInput(
            initialValue: controller.fractionController.doubleValue,
            onChanged: (value) {
              controller.fractionController.doubleValue = value;
              onChanged?.call();
            },
          ),
        );

        inchesLabel = Text(
          Unit.inches.shorthandDisplayName(context),
          style: styleSecondary(context),
        );
      } else if (spec.fraction != null) {
        imperialFractionInput = Expanded(
          child: TextInput.number(
            context,
            // Keeps text field underline aligned with wholeInput.
            label: "",
            suffixText: spec.fraction?.shorthandDisplayName(context),
            controller: controller.fractionController,
            decimal: false,
            signed: false,
            showMaxLength: false,
            onChanged: (_) => onChanged?.call(),
          ),
        );
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
        ],
      ),
    );
  }
}

class MultiMeasurementInputSpec {
  final Unit imperial;
  final Unit metric;

  /// The fractional unit of the imperial system value, such as inches. If null,
  /// a fractional input will not be rendered at all.
  final Unit? fraction;

  final MeasurementSystem? system;

  /// The title of the input. Renders as the title of the "main" [TextInput].
  final LocalizedString? title;

  MultiMeasurementInputSpec._({
    required this.imperial,
    required this.metric,
    this.fraction,
    this.system,
    this.title,
  });

  MultiMeasurementInputSpec.length(BuildContext context)
      : this._(
          imperial: Unit.inches,
          metric: Unit.centimeters,
          system: UserPreferenceManager.of(context).catchLengthSystem,
          title: (context) => Strings.of(context).catchFieldLengthLabel,
        );

  MultiMeasurementInputSpec.weight(BuildContext context)
      : this._(
          imperial: Unit.pounds,
          metric: Unit.kilograms,
          fraction: Unit.ounces,
          system: UserPreferenceManager.of(context).catchWeightSystem,
          title: (context) => Strings.of(context).catchFieldWeightLabel,
        );

  MultiMeasurementInputSpec.waterDepth(BuildContext context)
      : this._(
          imperial: Unit.feet,
          metric: Unit.meters,
          fraction: Unit.inches,
          system: UserPreferenceManager.of(context).waterDepthSystem,
          title: (context) => Strings.of(context).catchFieldWaterDepthLabel,
        );

  MultiMeasurementInputSpec.waterTemperature(BuildContext context)
      : this._(
          imperial: Unit.fahrenheit,
          metric: Unit.celsius,
          system: UserPreferenceManager.of(context).waterTemperatureSystem,
          title: (context) =>
              Strings.of(context).catchFieldWaterTemperatureLabel,
        );

  MultiMeasurementInputSpec.windSpeed(BuildContext context)
      : this._(
          imperial: Unit.miles_per_hour,
          metric: Unit.kilometers_per_hour,
          system: UserPreferenceManager.of(context).windSpeedSystem,
          title: (context) => Strings.of(context).atmosphereInputWindSpeed,
        );

  MultiMeasurementInputSpec.airTemperature(BuildContext context)
      : this._(
          imperial: Unit.fahrenheit,
          metric: Unit.celsius,
          system: UserPreferenceManager.of(context).airTemperatureSystem,
          title: (context) => Strings.of(context).atmosphereInputAirTemperature,
        );

  MultiMeasurementInputSpec.airPressure(BuildContext context)
      : this._(
          imperial: Unit.pounds_per_square_inch,
          metric: Unit.millibars,
          system: UserPreferenceManager.of(context).airPressureSystem,
          title: (context) =>
              Strings.of(context).atmosphereInputAtmosphericPressure,
        );

  MultiMeasurementInputSpec.airVisibility(BuildContext context)
      : this._(
          imperial: Unit.miles,
          metric: Unit.kilometers,
          system: UserPreferenceManager.of(context).airVisibilitySystem,
          title: (context) => Strings.of(context).atmosphereInputAirVisibility,
        );

  MultiMeasurementInputSpec.airHumidity(BuildContext context)
      : this._(
          imperial: Unit.percent,
          metric: Unit.percent,
          title: (context) => Strings.of(context).atmosphereInputAirHumidity,
        );

  MultiMeasurementInputController newInputController({
    NumberInputController? mainController,
    NumberInputController? fractionController,
  }) {
    return MultiMeasurementInputController(
      system: system,
      mainUnit: system == null || !system!.isMetric ? imperial : metric,
      fractionUnit: fraction,
      mainController: mainController,
      fractionController: fractionController,
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
