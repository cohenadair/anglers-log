import 'dart:math';

import 'package:adair_flutter_lib/pages/scroll_page.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';

import '../model/gen/anglerslog.pb.dart';
import '../model/gen/anglerslog.pbserver.dart';
import '../res/style.dart';
import '../user_preference_manager.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/radio_input.dart';
import '../widgets/widget.dart';

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
        _buildTideHeight(context),
        const MinDivider(),
        _buildAirTemperature(context),
        const MinDivider(),
        _buildAirVisibility(context),
        const MinDivider(),
        _buildAirPressure(context),
        const MinDivider(),
        _buildWindSpeed(context),
        const MinDivider(),
        _buildDistance(context),
        const MinDivider(),
        _buildRodLength(context),
        const MinDivider(),
        _buildLeaderLength(context),
        const MinDivider(),
        _buildTippetLength(context),
      ],
    );
  }

  Widget _buildCatchLength(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).catchFieldLengthLabel,
      initialSystem: UserPreferenceManager.get.catchLengthSystem,
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
          displayValue: Strings.of(context).unitsPageFractionalInches,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_decimal,
            mainValue: Measurement(
              unit: Unit.inches,
              value: 26.75,
            ),
          ),
          displayValue: Strings.of(context).unitsPageInches,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.centimeters,
              value: 68,
            ),
          ),
          displayValue: Strings.of(context).unitsPageCentimeters,
        ),
      ],
      onSelect: (system, _) =>
          UserPreferenceManager.get.setCatchLengthSystem(system),
    );
  }

  Widget _buildCatchWeight(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).unitsPageCatchWeight,
      initialSystem: UserPreferenceManager.get.catchWeightSystem,
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
      onSelect: (system, _) =>
          UserPreferenceManager.get.setCatchWeightSystem(system),
    );
  }

  Widget _buildWaterTemperature(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).fieldWaterTemperatureLabel,
      initialSystem: UserPreferenceManager.get.waterTemperatureSystem,
      options: [
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_decimal,
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
      onSelect: (system, _) =>
          UserPreferenceManager.get.setWaterTemperatureSystem(system),
    );
  }

  Widget _buildWaterDepth(BuildContext context) {
    return _buildFeetInchesMetersSelector(
      context: context,
      title: Strings.of(context).fieldWaterDepthLabel,
      initialSystem: UserPreferenceManager.get.waterDepthSystem,
      feetMainValue: 35,
      feetInchesValue: 6,
      feetDecimalValue: 35.5,
      metersValue: 10.8,
      onSelect: (system, _) =>
          UserPreferenceManager.get.setWaterDepthSystem(system),
    );
  }

  Widget _buildTideHeight(BuildContext context) {
    return _buildFeetInchesMetersSelector(
      context: context,
      title: Strings.of(context).catchFieldTideHeightLabel,
      initialSystem: UserPreferenceManager.get.tideHeightSystem,
      decimalPlaces: TideHeights.displayDecimalPlaces,
      feetMainValue: 0,
      feetInchesValue: 5,
      feetDecimalValue: 0.406,
      metersValue: 0.124,
      onSelect: (system, _) =>
          UserPreferenceManager.get.setTideHeightSystem(system),
    );
  }

  Widget _buildAirTemperature(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).atmosphereInputAirTemperature,
      initialSystem: UserPreferenceManager.get.airTemperatureSystem,
      options: [
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_decimal,
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
      onSelect: (system, _) =>
          UserPreferenceManager.get.setAirTemperatureSystem(system),
    );
  }

  Widget _buildAirPressure(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).atmosphereInputAtmosphericPressure,
      initialSystem: UserPreferenceManager.get.airPressureSystem,
      initialUnit: UserPreferenceManager.get.airPressureImperialUnit,
      options: [
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_decimal,
            mainValue: Measurement(
              unit: Unit.inch_of_mercury,
              value: 29.5,
            ),
          ),
          displayValue: Strings.of(context).unitsPageAirPressureInHg,
        ),
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
      onSelect: (system, imperialUnit) {
        UserPreferenceManager.get.setAirPressureSystem(system);
        UserPreferenceManager.get.setAirPressureImperialUnit(imperialUnit);
      },
    );
  }

  Widget _buildAirVisibility(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).atmosphereInputAirVisibility,
      initialSystem: UserPreferenceManager.get.airVisibilitySystem,
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
      onSelect: (system, _) =>
          UserPreferenceManager.get.setAirVisibilitySystem(system),
    );
  }

  Widget _buildWindSpeed(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).atmosphereInputWindSpeed,
      initialSystem: UserPreferenceManager.get.windSpeedSystem,
      initialUnit: UserPreferenceManager.get.windSpeedMetricUnit,
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
              unit: Unit.kilometers_per_hour,
              value: 3.2,
            ),
          ),
          displayValue: Strings.of(context).unitsPageWindSpeedKilometers,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.meters_per_second,
              value: 7.5,
            ),
          ),
          displayValue: Strings.of(context).unitsPageWindSpeedMeters,
        ),
      ],
      onSelect: (system, unit) {
        UserPreferenceManager.get.setWindSpeedSystem(system);
        if (system == MeasurementSystem.metric) {
          UserPreferenceManager.get.setWindSpeedMetricUnit(unit);
        }
      },
    );
  }

  Widget _buildDistance(BuildContext context) {
    return _UnitSelector(
      title: Strings.of(context).unitsPageDistanceTitle,
      initialSystem:
          // Doesn't matter which distance preference is used here since they
          // are all the same.
          UserPreferenceManager.get.fishingSpotDistance.system,
      options: [
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(
              unit: Unit.feet,
              value: 100,
            ),
          ),
          displayValue: Strings.of(context).unitsPageFeet,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.meters,
              value: 30,
            ),
          ),
          displayValue: Strings.of(context).unitsPageMeters,
        ),
      ],
      onSelect: (system, unit) {
        // Update all distance preferences.
        UserPreferenceManager.get.setFishingSpotDistance(
          UserPreferenceManager.get.fishingSpotDistance.convertUnitsOnly(
            MultiMeasurement(
              system: system,
              mainValue: Measurement(unit: unit),
            ),
          ),
        );

        UserPreferenceManager.get.setMinGpsTrailDistance(
          UserPreferenceManager.get.minGpsTrailDistance.convertUnitsOnly(
            MultiMeasurement(
              system: system,
              mainValue: Measurement(unit: unit),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRodLength(BuildContext context) {
    return _buildFeetInchesMetersSelector(
      context: context,
      title: Strings.of(context).gearFieldRodLength,
      initialSystem: UserPreferenceManager.get.rodLengthSystem,
      feetMainValue: 9,
      feetInchesValue: 6,
      feetDecimalValue: 9.5,
      metersValue: 3,
      onSelect: (system, _) =>
          UserPreferenceManager.get.setRodLengthSystem(system),
    );
  }

  Widget _buildLeaderLength(context) {
    return _buildFeetInchesMetersSelector(
      context: context,
      title: Strings.of(context).gearFieldLeaderLength,
      initialSystem: UserPreferenceManager.get.leaderLengthSystem,
      feetMainValue: 3,
      feetInchesValue: 6,
      feetDecimalValue: 3.5,
      metersValue: 1,
      onSelect: (system, _) =>
          UserPreferenceManager.get.setLeaderLengthSystem(system),
    );
  }

  Widget _buildTippetLength(context) {
    return _UnitSelector(
      title: Strings.of(context).unitsPageTippetLengthTitle,
      initialSystem: UserPreferenceManager.get.tippetLengthSystem,
      options: [
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(
              unit: Unit.inches,
              value: 18,
            ),
          ),
          displayValue: Strings.of(context).unitsPageInches,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.centimeters,
              value: 46,
            ),
          ),
          displayValue: Strings.of(context).unitsPageCentimeters,
        ),
      ],
      onSelect: (system, _) =>
          UserPreferenceManager.get.setTippetLengthSystem(system),
    );
  }

  Widget _buildFeetInchesMetersSelector({
    required BuildContext context,
    required String title,
    required MeasurementSystem initialSystem,
    int? decimalPlaces,
    required double feetMainValue,
    required double feetInchesValue,
    required double feetDecimalValue,
    required double metersValue,
    required void Function(MeasurementSystem, Unit)? onSelect,
  }) {
    return _UnitSelector(
      title: title,
      initialSystem: initialSystem,
      decimalPlaces: decimalPlaces,
      options: [
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(
              unit: Unit.feet,
              value: feetMainValue,
            ),
            fractionValue: Measurement(
              unit: Unit.inches,
              value: feetInchesValue,
            ),
          ),
          displayValue: Strings.of(context).unitsPageFeetInches,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.imperial_decimal,
            mainValue: Measurement(
              unit: Unit.feet,
              value: feetDecimalValue,
            ),
          ),
          displayValue: Strings.of(context).unitsPageFeet,
        ),
        _UnitSelectorOption(
          value: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.meters,
              value: metersValue,
            ),
          ),
          displayValue: Strings.of(context).unitsPageMeters,
        ),
      ],
      onSelect: onSelect,
    );
  }
}

class _UnitSelectorOption {
  MultiMeasurement value;
  String Function(String) displayValue;

  _UnitSelectorOption({
    required this.value,
    required this.displayValue,
  });
}

class _UnitSelector extends StatelessWidget {
  final String title;
  final MeasurementSystem? initialSystem;
  final Unit? initialUnit;
  final int? decimalPlaces;
  final List<_UnitSelectorOption> options;
  final void Function(MeasurementSystem, Unit mainUnit)? onSelect;

  const _UnitSelector({
    required this.title,
    required this.initialSystem,
    required this.options,
    this.initialUnit,
    this.decimalPlaces,
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
            bottom: paddingSmall,
            top: paddingTiny,
          ),
          initialSelectedIndex: max(
            0,
            options.indexWhere((o) =>
                o.value.system == initialSystem &&
                (initialUnit == null || initialUnit == o.value.mainValue.unit)),
          ),
          optionCount: options.length,
          optionBuilder: (context, i) => options[i].displayValue(options[i]
              .value
              .displayValue(context, mainDecimalPlaces: decimalPlaces)),
          onSelect: (i) => onSelect?.call(
            options[i].value.system,
            options[i].value.mainValue.unit,
          ),
        ),
      ],
    );
  }
}
