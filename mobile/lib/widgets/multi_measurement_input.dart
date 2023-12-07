import 'package:flutter/material.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/chip_list.dart';

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
        builder: (context, _, __) => _buildContainer(context),
      ),
    );
  }

  Widget _buildContainer(BuildContext context) {
    return HorizontalSafeArea(
      child: Column(
        children: [
          _buildInput(context),
          _buildConversion(context),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    var imperialUnit = spec.imperialUnit?.call(context);
    var imperialWholeSuffix = _isImperialWhole && imperialUnit == Unit.inches
        ? null
        : imperialUnit?.shorthandDisplayName(context);
    var metricSuffix = spec.metricUnit?.shorthandDisplayName(context);
    var decimalPlaces = spec.mainValueDecimalPlaces?.call(context);
    var unitAllowsDecimals =
        _isMetric || _isImperialDecimal || imperialUnit == Unit.inch_of_mercury;

    var wholeInput = TextInput.number(
      context,
      label: title ?? spec.title?.call(context),
      suffixText: _isImperialWhole || _isImperialDecimal
          ? imperialWholeSuffix
          : metricSuffix,
      controller: controller.mainController,
      decimal:
          (decimalPlaces == null || decimalPlaces > 0) && unitAllowsDecimals,
      signed: false,
      showMaxLength: false,
      onChanged: (_) => onChanged?.call(),
    );

    Widget? imperialFractionInput;
    Widget? inchesLabel;
    if (_isImperialWhole) {
      if (imperialUnit == Unit.inches) {
        if (spec.includeFractionalInches) {
          imperialFractionInput = _InchesDropdownInput(
            initialValue: controller.fractionController.doubleValue,
            onChanged: (value) {
              controller.fractionController.doubleValue = value;
              onChanged?.call();
            },
          );
        }

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

    Widget? unitsDropdown;
    if (spec.availableUnits.isNotEmpty) {
      Unit? initialValue;
      if (controller.value.mainValue.hasUnit()) {
        initialValue = controller.value.mainValue.unit;
      }
      unitsDropdown = _UnitsDropdownInput(
        initialValue: initialValue,
        options: spec.availableUnits,
        onChanged: (value) {
          controller.mainController.selectedUnit = value;
          onChanged?.call();
        },
      );
    }

    return Row(
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
        unitsDropdown == null
            ? const Empty()
            : const HorizontalSpace(paddingDefault),
        unitsDropdown ?? const Empty(),
      ],
    );
  }

  Widget _buildConversion(BuildContext context) {
    var specMeasurement = _specMultiMeasurement(context);
    if (specMeasurement == null) {
      return const Empty();
    }

    return ChipList(
      children: [
        _buildConversionChip(context, specMeasurement),
        _buildConversionChip(
            context, controller.value.convertUnitsOnly(specMeasurement)),
      ],
    );
  }

  ChipButton _buildConversionChip(
      BuildContext context, MultiMeasurement newMeasurement) {
    // Create a new input controller here to ensure that the values shown in the
    // conversion chip match exactly what will be shown in the text input.
    var newController = spec.newInputController();
    newController.value = newMeasurement;

    return ChipButton(
      label: newController.value.displayValue(
        context,
        resultFormat: Strings.of(context).unitConvertToValue,
        includeFraction: true,
      ),
      onPressed: () {
        controller.value = newMeasurement;
        onChanged?.call();
      },
    );
  }

  /// Returns a [MultiMeasurement] object for the measurement system in
  /// [spec]. Returns null if a conversion cannot or should not be made.
  MultiMeasurement? _specMultiMeasurement(BuildContext context) {
    if (!controller.isSet) {
      return null;
    }

    var specSystem = spec.system?.call(context);
    if (specSystem == null) {
      return null;
    }

    var specUnit = spec.mainUnit!; // Can't be null if system != null.

    if (specSystem == controller.system &&
        specUnit == controller.value.mainValue.unit) {
      return null;
    }

    var result = controller.value.convertToSystem(specSystem, specUnit);

    var decimalPlaces = spec.mainValueDecimalPlaces?.call(context);
    if (decimalPlaces == null || decimalPlaces > 0) {
      return result;
    }

    return result..clearFractionValue();
  }
}

class MultiMeasurementInputSpec {
  final BuildContext context;

  final Unit Function(BuildContext)? imperialUnit;
  final Unit? metricUnit;

  /// The fractional unit of the imperial system value, such as inches. If null,
  /// a fractional input will not be rendered at all.
  final Unit? fractionUnit;

  /// When true (default) and [imperialUnit] is set to [Unit.inches], a
  /// dropdown is rendered, allowing users to select fraction values to 1/8
  /// accuracy.
  final bool includeFractionalInches;

  /// When set, a dropdown will be rendered, allowing users to select their
  /// unit. This should only be used for units that can't be converted between
  /// one another, such as "5X" and "10 lb test".
  final List<Unit> availableUnits;

  final MeasurementSystem? Function(BuildContext)? system;

  /// The title of the input. Renders as the title of the "main" [TextInput].
  final LocalizedString? title;

  /// The number of decimal places to show to the user for the main value. Note
  /// that regardless of this value, the main value will be rounded if the main
  /// measurement system is [MeasurementSystem.imperial_whole].
  final int Function(BuildContext)? mainValueDecimalPlaces;

  MultiMeasurementInputSpec._(
    this.context, {
    this.imperialUnit,
    this.metricUnit,
    this.includeFractionalInches = true,
    this.fractionUnit,
    this.availableUnits = const [],
    this.system,
    this.title,
    this.mainValueDecimalPlaces,
  }) {
    assert((availableUnits.isNotEmpty &&
            imperialUnit == null &&
            metricUnit == null) ||
        (availableUnits.isEmpty && imperialUnit != null && metricUnit != null));
  }

  MultiMeasurementInputSpec._lineRating(
    BuildContext context,
    LocalizedString title,
  ) : this._(
          context,
          availableUnits: [Unit.pound_test, Unit.x],
          title: title,
        );

  MultiMeasurementInputSpec.length(BuildContext context)
      : this._(
          context,
          imperialUnit: (_) => Unit.inches,
          metricUnit: Unit.centimeters,
          system: (context) =>
              UserPreferenceManager.of(context).catchLengthSystem,
          title: (context) => Strings.of(context).catchFieldLengthLabel,
        );

  MultiMeasurementInputSpec.weight(BuildContext context)
      : this._(
          context,
          imperialUnit: (_) => Unit.pounds,
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
          imperialUnit: (_) => Unit.feet,
          metricUnit: Unit.meters,
          fractionUnit: Unit.inches,
          system: (context) =>
              UserPreferenceManager.of(context).waterDepthSystem,
          title: (context) =>
              title ?? Strings.of(context).catchFieldWaterDepthLabel,
        );

  MultiMeasurementInputSpec.tideHeight(BuildContext context)
      : this._(
          context,
          imperialUnit: (_) => Unit.feet,
          metricUnit: Unit.meters,
          fractionUnit: Unit.inches,
          system: (context) =>
              UserPreferenceManager.of(context).tideHeightSystem,
          title: (context) => Strings.of(context).catchFieldTideHeightLabel,
        );

  MultiMeasurementInputSpec.waterTemperature(BuildContext context)
      : this._(
          context,
          imperialUnit: (_) => Unit.fahrenheit,
          metricUnit: Unit.celsius,
          system: (context) =>
              UserPreferenceManager.of(context).waterTemperatureSystem,
          title: (context) =>
              Strings.of(context).catchFieldWaterTemperatureLabel,
        );

  MultiMeasurementInputSpec.windSpeed(BuildContext context)
      : this._(
          context,
          imperialUnit: (_) => Unit.miles_per_hour,
          metricUnit: Unit.kilometers_per_hour,
          system: (context) =>
              UserPreferenceManager.of(context).windSpeedSystem,
          title: (context) => Strings.of(context).atmosphereInputWindSpeed,
          mainValueDecimalPlaces: (_) => 0,
        );

  MultiMeasurementInputSpec.airTemperature(BuildContext context)
      : this._(
          context,
          imperialUnit: (_) => Unit.fahrenheit,
          metricUnit: Unit.celsius,
          system: (context) =>
              UserPreferenceManager.of(context).airTemperatureSystem,
          title: (context) => Strings.of(context).atmosphereInputAirTemperature,
          mainValueDecimalPlaces: (_) => 0,
        );

  MultiMeasurementInputSpec.airPressure(BuildContext context)
      : this._(
          context,
          imperialUnit: (context) =>
              UserPreferenceManager.of(context).airPressureImperialUnit,
          metricUnit: Unit.millibars,
          system: (context) =>
              UserPreferenceManager.of(context).airPressureSystem,
          title: (context) =>
              Strings.of(context).atmosphereInputAtmosphericPressure,
          mainValueDecimalPlaces: (context) =>
              UserPreferenceManager.of(context).airPressureImperialUnit ==
                      Unit.inch_of_mercury
                  ? 1
                  : 0,
        );

  MultiMeasurementInputSpec.airVisibility(BuildContext context)
      : this._(
          context,
          imperialUnit: (_) => Unit.miles,
          metricUnit: Unit.kilometers,
          system: (context) =>
              UserPreferenceManager.of(context).airVisibilitySystem,
          title: (context) => Strings.of(context).atmosphereInputAirVisibility,
          mainValueDecimalPlaces: (_) => 0,
        );

  MultiMeasurementInputSpec.airHumidity(BuildContext context)
      : this._(
          context,
          imperialUnit: (_) => Unit.percent,
          metricUnit: Unit.percent,
          title: (context) => Strings.of(context).atmosphereInputAirHumidity,
          mainValueDecimalPlaces: (_) => 0,
        );

  MultiMeasurementInputSpec.fishingSpotDistance(BuildContext context)
      : this._(
          context,
          imperialUnit: (_) => Unit.feet,
          metricUnit: Unit.meters,
          system: (context) =>
              UserPreferenceManager.of(context).fishingSpotDistance.system,
          title: (context) =>
              Strings.of(context).settingsPageFishingSpotDistanceTitle,
          mainValueDecimalPlaces: (_) => 0,
        );

  MultiMeasurementInputSpec.minGpsTrailDistance(BuildContext context)
      : this._(
          context,
          imperialUnit: (_) => Unit.feet,
          metricUnit: Unit.meters,
          system: (context) =>
              UserPreferenceManager.of(context).minGpsTrailDistance.system,
          title: (context) =>
              Strings.of(context).settingsPageMinGpsTrailDistanceTitle,
          mainValueDecimalPlaces: (_) => 0,
        );

  MultiMeasurementInputSpec.rodLength(BuildContext context)
      : this._(
          context,
          imperialUnit: (_) => Unit.feet,
          metricUnit: Unit.meters,
          fractionUnit: Unit.inches,
          system: (context) =>
              UserPreferenceManager.of(context).rodLengthSystem,
          title: (context) => Strings.of(context).gearFieldRodLength,
        );

  MultiMeasurementInputSpec.leaderLength(BuildContext context)
      : this._(
          context,
          imperialUnit: (_) => Unit.feet,
          metricUnit: Unit.meters,
          fractionUnit: Unit.inches,
          system: (context) =>
              UserPreferenceManager.of(context).leaderLengthSystem,
          title: (context) => Strings.of(context).gearFieldLeaderLength,
        );

  MultiMeasurementInputSpec.tippetLength(BuildContext context)
      : this._(
          context,
          imperialUnit: (_) => Unit.inches,
          includeFractionalInches: false,
          metricUnit: Unit.centimeters,
          system: (context) =>
              UserPreferenceManager.of(context).tippetLengthSystem,
          title: (context) => Strings.of(context).gearFieldTippetLength,
        );

  MultiMeasurementInputSpec.lineRating(BuildContext context)
      : this._lineRating(
          context,
          (context) => Strings.of(context).gearFieldLineRating,
        );

  MultiMeasurementInputSpec.leaderRating(BuildContext context)
      : this._lineRating(
          context,
          (context) => Strings.of(context).gearFieldLeaderRating,
        );

  MultiMeasurementInputSpec.tippetRating(BuildContext context)
      : this._lineRating(
          context,
          (context) => Strings.of(context).gearFieldTippetRating,
        );

  MultiMeasurementInputSpec.hookSize(BuildContext context)
      : this._(
          context,
          availableUnits: [Unit.hashtag, Unit.aught],
          title: (context) => Strings.of(context).gearFieldHookSize,
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

  Unit? get mainUnit {
    var system = this.system?.call(context);
    if (system == null) {
      return null;
    }

    if (system.isMetric) {
      return metricUnit;
    } else {
      return imperialUnit?.call(context);
    }
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
              DropdownMenuItem<Fraction>(value: f, child: Text(f.symbol)))
          .toList(),
      onChanged: (fraction) {
        setState(() => _value = fraction ?? Fraction.zero);
        widget.onChanged?.call(fraction?.value);
      },
    );
  }
}

class _UnitsDropdownInput extends StatefulWidget {
  final Unit? initialValue;
  final List<Unit> options;
  final void Function(Unit?)? onChanged;

  _UnitsDropdownInput({
    this.initialValue,
    required this.options,
    this.onChanged,
  }) : assert(options.isNotEmpty);

  @override
  __UnitsDropdownInputState createState() => __UnitsDropdownInputState();
}

class __UnitsDropdownInputState extends State<_UnitsDropdownInput> {
  late Unit _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue ?? widget.options.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Unit>(
      underline: const Empty(),
      value: _value,
      items: widget.options
          .map((e) => DropdownMenuItem<Unit>(
              value: e, child: Text(e.shorthandDisplayName(context))))
          .toList(),
      onChanged: (unit) {
        setState(() => _value = unit ?? widget.options.first);
        widget.onChanged?.call(unit);
      },
    );
  }
}
