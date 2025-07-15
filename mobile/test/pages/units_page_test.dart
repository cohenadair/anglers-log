import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/units_page.dart';
import 'package:mobile/widgets/radio_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.userPreferenceManager.catchLengthSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.catchWeightSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.waterTemperatureSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.waterDepthSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.airTemperatureSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.airPressureSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.airVisibilitySystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.windSpeedSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.windSpeedMetricUnit,
    ).thenReturn(Unit.kilometers_per_hour);
    when(
      managers.userPreferenceManager.airPressureImperialUnit,
    ).thenReturn(Unit.millibars);
    when(managers.userPreferenceManager.fishingSpotDistance).thenReturn(
      MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(unit: Unit.feet, value: 20),
      ),
    );
    when(managers.userPreferenceManager.minGpsTrailDistance).thenReturn(
      MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(unit: Unit.feet, value: 150),
      ),
    );
    when(
      managers.userPreferenceManager.tideHeightSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.rodLengthSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.leaderLengthSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.tippetLengthSystem,
    ).thenReturn(MeasurementSystem.metric);
  });

  testWidgets("Initial index when preferences is not null", (tester) async {
    when(
      managers.userPreferenceManager.catchLengthSystem,
    ).thenReturn(MeasurementSystem.imperial_decimal);

    await tester.pumpWidget(Testable((_) => UnitsPage()));

    var radioInput = findSiblingOfText<RadioInput>(tester, Column, "Length");
    expect(radioInput.initialSelectedIndex, 1);
  });

  testWidgets("Initial index with system and unit", (tester) async {
    when(
      managers.userPreferenceManager.airPressureSystem,
    ).thenReturn(MeasurementSystem.imperial_decimal);
    when(
      managers.userPreferenceManager.airPressureImperialUnit,
    ).thenReturn(Unit.inch_of_mercury);

    await tester.pumpWidget(Testable((_) => UnitsPage()));

    var radioInput = findSiblingOfText<RadioInput>(
      tester,
      Column,
      "Atmospheric Pressure",
    );
    expect(radioInput.initialSelectedIndex, 0);
  });

  testWidgets("Preferences is updated on selection", (tester) async {
    // Avoids having to scroll to widgets off screen.
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(Testable((_) => UnitsPage()));

    await tapAndSettle(tester, find.text("Inches (26.75 in)"));
    verify(
      managers.userPreferenceManager.setCatchLengthSystem(
        MeasurementSystem.imperial_decimal,
      ),
    ).called(1);

    await tapAndSettle(tester, find.text("Pounds (5.25 lbs)"));
    verify(
      managers.userPreferenceManager.setCatchWeightSystem(
        MeasurementSystem.imperial_decimal,
      ),
    ).called(1);

    await tapAndSettle(tester, find.text("Celsius (22\u00B0C)"));
    verify(
      managers.userPreferenceManager.setWaterTemperatureSystem(
        MeasurementSystem.metric,
      ),
    ).called(1);

    await tapAndSettle(tester, find.text("Feet (35.5 ft)"));
    verify(
      managers.userPreferenceManager.setWaterDepthSystem(
        MeasurementSystem.imperial_decimal,
      ),
    ).called(1);

    await tapAndSettle(tester, find.text("Feet (0.406 ft)"));
    verify(
      managers.userPreferenceManager.setTideHeightSystem(
        MeasurementSystem.imperial_decimal,
      ),
    ).called(1);

    await tester.ensureVisible(find.text("Celsius (15\u00B0C)"));
    await tapAndSettle(tester, find.text("Celsius (15\u00B0C)"));
    verify(
      managers.userPreferenceManager.setAirTemperatureSystem(
        MeasurementSystem.metric,
      ),
    ).called(1);

    await tapAndSettle(tester, find.text("Kilometres (10.5 km)"));
    verify(
      managers.userPreferenceManager.setAirVisibilitySystem(
        MeasurementSystem.metric,
      ),
    ).called(1);

    await tapAndSettle(tester, find.text("Millibars (1000 MB)"));
    verify(
      managers.userPreferenceManager.setAirPressureSystem(
        MeasurementSystem.metric,
      ),
    ).called(1);

    await tapAndSettle(tester, find.text("Kilometres per hour (3.2 km/h)"));
    verify(
      managers.userPreferenceManager.setWindSpeedSystem(
        MeasurementSystem.metric,
      ),
    ).called(1);
    verify(
      managers.userPreferenceManager.setWindSpeedMetricUnit(
        Unit.kilometers_per_hour,
      ),
    ).called(1);

    await tapAndSettle(tester, find.text("Miles per hour (2 mph)"));
    verify(
      managers.userPreferenceManager.setWindSpeedSystem(
        MeasurementSystem.imperial_decimal,
      ),
    ).called(1);
    verifyNever(managers.userPreferenceManager.setWindSpeedMetricUnit(any));

    await tapAndSettle(tester, find.text("Metres (30 m)"));
    verify(
      managers.userPreferenceManager.setFishingSpotDistance(any),
    ).called(1);
    verify(
      managers.userPreferenceManager.setMinGpsTrailDistance(any),
    ).called(1);

    await tapAndSettle(tester, find.text("Feet (9.5 ft)"));
    verify(
      managers.userPreferenceManager.setRodLengthSystem(
        MeasurementSystem.imperial_decimal,
      ),
    ).called(1);

    await tapAndSettle(tester, find.text("Feet (3.5 ft)"));
    verify(
      managers.userPreferenceManager.setLeaderLengthSystem(
        MeasurementSystem.imperial_decimal,
      ),
    ).called(1);

    await tapAndSettle(tester, find.text("Centimetres (46 cm)"));
    verify(
      managers.userPreferenceManager.setTippetLengthSystem(
        MeasurementSystem.metric,
      ),
    ).called(1);
  });

  testWidgets("Distance preferences are updated on selection", (tester) async {
    await tester.pumpWidget(Testable((_) => UnitsPage()));

    await tester.ensureVisible(find.text("Metres (30 m)"));
    await tapAndSettle(tester, find.text("Metres (30 m)"));

    var result = verify(
      managers.userPreferenceManager.setFishingSpotDistance(captureAny),
    );
    result.called(1);

    MultiMeasurement value = result.captured.first;
    expect(value.system, MeasurementSystem.metric);
    expect(value.mainValue.unit, Unit.meters);
    expect(value.mainValue.value, 20);

    result = verify(
      managers.userPreferenceManager.setMinGpsTrailDistance(captureAny),
    );
    result.called(1);

    value = result.captured.first;
    expect(value.system, MeasurementSystem.metric);
    expect(value.mainValue.unit, Unit.meters);
    expect(value.mainValue.value, 150);
  });
}
