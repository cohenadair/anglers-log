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

  const MultiMeasurementInput({
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
    return StreamBuilder<void>(
      stream: UserPreferenceManager.of(context).stream,
      builder: (context, _) => ValueListenableBuilder<MultiMeasurement?>(
        valueListenable: controller,
        builder: (context, _, __) => _buildInput(context),
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    var imperialWholeSuffix =
        _isImperialWhole && spec.imperialUnit == Unit.inches
            ? null
            : spec.imperialUnit.shorthandDisplayName(context);
    var metricSuffix = spec.metricUnit.shorthandDisplayName(context);

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
      if (spec.imperialUnit == Unit.inches) {
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
      } else if (spec.fractionUnit != null) {
        imperialFractionInput = Expanded(
          child: TextInput.number(
            context,
            // Keeps text field underline aligned with wholeInput.
            label: "",
            suffixText: spec.fractionUnit?.shorthandDisplayName(context),
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
              ? const Empty()
              : const HorizontalSpace(paddingDefault),
          imperialFractionInput ?? const Empty(),
          inchesLabel == null
              ? const Empty()
              : const HorizontalSpace(paddingDefault),
          inchesLabel ?? const Empty(),
        ],
      ),
    );
  }
}

class MultiMeasurementInputSpec {
  final BuildContext context;
  final Unit imperialUnit;
  final Unit metricUnit;

  /// The fractional unit of the imperial system value, such as inches. If null,
  /// a fractional input will not be rendered at all.
  final Unit? fractionUnit;

  final MeasurementSystem? Function(BuildContext)? system;

  /// The title of the input. Renders as the title of the "main" [TextInput].
  final LocalizedString? title;

  /// The number of decimal places to show to the user for the main value. Note
  /// that regardless of this value, the main value will be rounded if the main
  /// measurement system is [MeasurementSystem.imperial_whole].
  final int? mainValueDecimalPlaces;

  MultiMeasurementInputSpec._(
    this.context, {
    required this.imperialUnit,
    required this.metricUnit,
    this.fractionUnit,
    this.system,
    this.title,
    this.mainValueDecimalPlaces,
  });

  MultiMeasurementInputSpec.length(BuildContext context)
      : this._(
          context,
          imperialUnit: Unit.inches,
          metricUnit: Unit.centimeters,
          system: (context) =>
              UserPreferenceManager.of(context).catchLengthSystem,
          title: (context) => Strings.of(context).catchFieldLengthLabel,
        );

  MultiMeasurementInputSpec.weight(BuildContext context)
      : this._(
          context,
          imperialUnit: Unit.pounds,
          metricUnit: Unit.kilograms,
          fractionUnit: Unit.ounces,
          system: (context) =>
              UserPreferenceManager.of(context).catchWeightSystem,
          title: (context) => Strings.of(context).catchFieldWeightLabel,
        );

  MultiMeasurementInputSpec.waterDepth(
    BuildContext context, {
    String? title,
  }) : this._(
          context,
          imperialUnit: Unit.feet,
          metricUnit: Unit.meters,
          fractionUnit: Unit.inches,
          system: (context) =>
              UserPreferenceManager.of(context).waterDepthSystem,
          title: (context) =>
              title ?? Strings.of(context).catchFieldWaterDepthLabel,
        );

  MultiMeasurementInputSpec.waterTemperature(BuildContext context)
      : this._(
          context,
          imperialUnit: Unit.fahrenheit,
          metricUnit: Unit.celsius,
          system: (context) =>
              UserPreferenceManager.of(context).waterTemperatureSystem,
          title: (context) =>
              Strings.of(context).catchFieldWaterTemperatureLabel,
        );

  MultiMeasurementInputSpec.windSpeed(BuildContext context)
      : this._(
          context,
          imperialUnit: Unit.miles_per_hour,
          metricUnit: Unit.kilometers_per_hour,
          system: (context) =>
              UserPreferenceManager.of(context).windSpeedSystem,
          title: (context) => Strings.of(context).atmosphereInputWindSpeed,
          mainValueDecimalPlaces: 0,
        );

  MultiMeasurementInputSpec.airTemperature(BuildContext context)
      : this._(
          context,
          imperialUnit: Unit.fahrenheit,
          metricUnit: Unit.celsius,
          system: (context) =>
              UserPreferenceManager.of(context).airTemperatureSystem,
          title: (context) => Strings.of(context).atmosphereInputAirTemperature,
          mainValueDecimalPlaces: 0,
        );

  MultiMeasurementInputSpec.airPressure(BuildContext context)
      : this._(
          context,
          imperialUnit: Unit.pounds_per_square_inch,
          metricUnit: Unit.millibars,
          system: (context) =>
              UserPreferenceManager.of(context).airPressureSystem,
          title: (context) =>
              Strings.of(context).atmosphereInputAtmosphericPressure,
          mainValueDecimalPlaces: 0,
        );

  MultiMeasurementInputSpec.airVisibility(BuildContext context)
      : this._(
          context,
          imperialUnit: Unit.miles,
          metricUnit: Unit.kilometers,
          system: (context) =>
              UserPreferenceManager.of(context).airVisibilitySystem,
          title: (context) => Strings.of(context).atmosphereInputAirVisibility,
          mainValueDecimalPlaces: 0,
        );

  MultiMeasurementInputSpec.airHumidity(BuildContext context)
      : this._(
          context,
          imperialUnit: Unit.percent,
          metricUnit: Unit.percent,
          title: (context) => Strings.of(context).atmosphereInputAirHumidity,
          mainValueDecimalPlaces: 0,
        );

  MultiMeasurementInputController newInputController({
    NumberInputController? mainController,
    NumberInputController? fractionController,
  }) {
    return MultiMeasurementInputController(
      context: context,
      spec: this,
      mainController: mainController,
      fractionController: fractionController,
    );
  }
}

class _InchesDropdownInput extends StatefulWidget {
  final double? initialValue;
  final void Function(double?)? onChanged;

  const _InchesDropdownInput({
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
      underline: const Empty(),
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
