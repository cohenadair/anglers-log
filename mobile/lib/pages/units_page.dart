import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../model/gen/anglerslog.pbserver.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../user_preference_manager.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/radio_input.dart';
import '../widgets/widget.dart';
import 'scroll_page.dart';

class UnitsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      appBar: AppBar(
        title: Text(Strings.of(context).unitsPageTitle),
      ),
      children: [
        _buildCatchLength(context),
        const MinDivider(),
        _buildCatchWeight(context),
        const MinDivider(),
        _buildWaterTemperature(context),
        const MinDivider(),
        _buildWaterDepth(context),
        const MinDivider(),
        _buildAirTemperature(context),
        const MinDivider(),
        _buildAirVisibility(context),
        const MinDivider(),
        _buildAirPressure(context),
        const MinDivider(),
        _buildWindSpeed(context),
      ],
    );
  }

  Widget _buildCatchLength(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).catchFieldLengthLabel,
      initialValue: UserPreferenceManager.of(context).catchLengthSystem,
      options: [
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(
              unit: Unit.inches,
              value: 26,
            ),
            fractionValue: Measurement(
              value: 0.75,
            ),
          ),
          displayValue:
              Strings.of(context).unitsPageCatchLengthFractionalInches,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_decimal,
            mainValue: Measurement(
              unit: Unit.inches,
              value: 26.75,
            ),
          ),
          displayValue: Strings.of(context).unitsPageCatchLengthInches,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.centimeters,
              value: 68,
            ),
          ),
          displayValue: Strings.of(context).unitsPageCatchLengthCentimeters,
        ),
      ],
      onSelect: (system) =>
          UserPreferenceManager.of(context).setCatchLengthSystem(system),
    );
  }

  Widget _buildCatchWeight(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).catchFieldWeightLabel,
      initialValue: UserPreferenceManager.of(context).catchWeightSystem,
      options: [
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(
              unit: Unit.pounds,
              value: 5,
            ),
            fractionValue: Measurement(
              unit: Unit.ounces,
              value: 4,
            ),
          ),
          displayValue: Strings.of(context).unitsPageCatchWeightPoundsOunces,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_decimal,
            mainValue: Measurement(
              unit: Unit.pounds,
              value: 5.25,
            ),
          ),
          displayValue: Strings.of(context).unitsPageCatchWeightPounds,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.kilograms,
              value: 2.38,
            ),
          ),
          displayValue: Strings.of(context).unitsPageCatchWeightKilograms,
        ),
      ],
      onSelect: (system) =>
          UserPreferenceManager.of(context).setCatchWeightSystem(system),
    );
  }

  Widget _buildWaterTemperature(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).catchFieldWaterTemperatureLabel,
      initialValue: UserPreferenceManager.of(context).waterTemperatureSystem,
      options: [
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(
              unit: Unit.fahrenheit,
              value: 72,
            ),
          ),
          displayValue: Strings.of(context).unitsPageWaterTemperatureFahrenheit,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.celsius,
              value: 22,
            ),
          ),
          displayValue: Strings.of(context).unitsPageWaterTemperatureCelsius,
        ),
      ],
      onSelect: (system) =>
          UserPreferenceManager.of(context).setWaterTemperatureSystem(system),
    );
  }

  Widget _buildWaterDepth(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).catchFieldWaterDepthLabel,
      initialValue: UserPreferenceManager.of(context).waterDepthSystem,
      options: [
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(
              unit: Unit.feet,
              value: 35,
            ),
            fractionValue: Measurement(
              unit: Unit.inches,
              value: 6,
            ),
          ),
          displayValue: Strings.of(context).unitsPageWaterDepthFeetInches,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_decimal,
            mainValue: Measurement(
              unit: Unit.feet,
              value: 35.5,
            ),
          ),
          displayValue: Strings.of(context).unitsPageWaterDepthFeet,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.meters,
              value: 10.8,
            ),
          ),
          displayValue: Strings.of(context).unitsPageWaterDepthMeters,
        ),
      ],
      onSelect: (system) =>
          UserPreferenceManager.of(context).setWaterDepthSystem(system),
    );
  }

  Widget _buildAirTemperature(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).atmosphereInputAirTemperature,
      initialValue: UserPreferenceManager.of(context).airTemperatureSystem,
      options: [
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(
              unit: Unit.fahrenheit,
              value: 59,
            ),
          ),
          displayValue: Strings.of(context).unitsPageAirTemperatureFahrenheit,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.celsius,
              value: 15,
            ),
          ),
          displayValue: Strings.of(context).unitsPageAirTemperatureCelsius,
        ),
      ],
      onSelect: (system) =>
          UserPreferenceManager.of(context).setAirTemperatureSystem(system),
    );
  }

  Widget _buildAirPressure(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).atmosphereInputAtmosphericPressure,
      initialValue: UserPreferenceManager.of(context).airPressureSystem,
      options: [
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_decimal,
            mainValue: Measurement(
              unit: Unit.pounds_per_square_inch,
              value: 14.5,
            ),
          ),
          displayValue: Strings.of(context).unitsPageAirPressurePsi,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.millibars,
              value: 1000,
            ),
          ),
          displayValue: Strings.of(context).unitsPageAirPressureMillibars,
        ),
      ],
      onSelect: (system) =>
          UserPreferenceManager.of(context).setAirPressureSystem(system),
    );
  }

  Widget _buildAirVisibility(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).atmosphereInputAirVisibility,
      initialValue: UserPreferenceManager.of(context).airVisibilitySystem,
      options: [
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_decimal,
            mainValue: Measurement(
              unit: Unit.miles,
              value: 6.5,
            ),
          ),
          displayValue: Strings.of(context).unitsPageAirVisibilityMiles,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.kilometers,
              value: 10.5,
            ),
          ),
          displayValue: Strings.of(context).unitsPageAirVisibilityKilometers,
        ),
      ],
      onSelect: (system) =>
          UserPreferenceManager.of(context).setAirVisibilitySystem(system),
    );
  }

  Widget _buildWindSpeed(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).atmosphereInputWindSpeed,
      initialValue: UserPreferenceManager.of(context).windSpeedSystem,
      options: [
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_decimal,
            mainValue: Measurement(
              unit: Unit.miles_per_hour,
              value: 2,
            ),
          ),
          displayValue: Strings.of(context).unitsPageWindSpeedMiles,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.kilometers,
              value: 3.2,
            ),
          ),
          displayValue: Strings.of(context).unitsPageWindSpeedKilometers,
        ),
      ],
      onSelect: (system) =>
          UserPreferenceManager.of(context).setWindSpeedSystem(system),
    );
  }
}

class _UnitSelectorOption {
  MultiMeasurement value;
  String displayValue;

  _UnitSelectorOption({
    required this.value,
    required this.displayValue,
  }) : assert(isNotEmpty(displayValue));
}

class _UnitSelector extends StatelessWidget {
  final String title;
  final MeasurementSystem? initialValue;
  final List<_UnitSelectorOption> options;
  final void Function(MeasurementSystem)? onSelect;

  const _UnitSelector({
    required this.title,
    required this.initialValue,
    required this.options,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: insetsDefault,
          child: Text(
            title,
            style: styleListHeading(context),
          ),
        ),
        RadioInput(
          padding: const EdgeInsets.only(
            left: paddingDefault,
            right: paddingDefault,
            bottom: paddingWidgetSmall,
            top: paddingWidgetTiny,
          ),
          initialSelectedIndex:
              max(0, options.indexWhere((o) => o.value.system == initialValue)),
          optionCount: options.length,
          optionBuilder: (context, i) => format(options[i].displayValue,
              [options[i].value.displayValue(context)]),
          onSelect: (i) => onSelect?.call(options[i].value.system),
        ),
      ],
    );
  }
}
