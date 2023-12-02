import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/units_page.dart';
import 'package:mobile/widgets/radio_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airPressureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airVisibilitySystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airPressureImperialUnit)
        .thenReturn(Unit.millibars);
    when(appManager.userPreferenceManager.fishingSpotDistance).thenReturn(
      MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 20,
        ),
      ),
    );
    when(appManager.userPreferenceManager.minGpsTrailDistance)
        .thenReturn(MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.feet,
        value: 150,
      ),
    ));
    when(appManager.userPreferenceManager.tideHeightSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.rodLengthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.leaderLengthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.tippetLengthSystem)
        .thenReturn(MeasurementSystem.metric);
  });

  testWidgets("Initial index when preferences is not null", (tester) async {
    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.imperial_decimal);

    await tester.pumpWidget(Testable(
      (_) => UnitsPage(),
      appManager: appManager,
    ));

    var radioInput = findSiblingOfText<RadioInput>(tester, Column, "Length");
    expect(radioInput.initialSelectedIndex, 1);
  });

  testWidgets("Initial index with system and unit", (tester) async {
    when(appManager.userPreferenceManager.airPressureSystem)
        .thenReturn(MeasurementSystem.imperial_decimal);
    when(appManager.userPreferenceManager.airPressureImperialUnit)
        .thenReturn(Unit.inch_of_mercury);

    await tester.pumpWidget(Testable(
      (_) => UnitsPage(),
      appManager: appManager,
    ));

    var radioInput =
        findSiblingOfText<RadioInput>(tester, Column, "Atmospheric Pressure");
    expect(radioInput.initialSelectedIndex, 0);
  });

  testWidgets("Preferences is updated on selection", (tester) async {
    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.imperial_whole);

    await tester.pumpWidget(Testable(
      (_) => UnitsPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Inches (26.75 in)"));
    verify(appManager.userPreferenceManager
            .setCatchLengthSystem(MeasurementSystem.imperial_decimal))
        .called(1);
  });

  testWidgets("Distance preferences are updated on selection", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => UnitsPage(),
      appManager: appManager,
    ));

    await tester.ensureVisible(find.text("Meters (30 m)"));
    await tapAndSettle(tester, find.text("Meters (30 m)"));

    var result = verify(
        appManager.userPreferenceManager.setFishingSpotDistance(captureAny));
    result.called(1);

    MultiMeasurement value = result.captured.first;
    expect(value.system, MeasurementSystem.metric);
    expect(value.mainValue.unit, Unit.meters);
    expect(value.mainValue.value, 20);

    result = verify(
        appManager.userPreferenceManager.setMinGpsTrailDistance(captureAny));
    result.called(1);

    value = result.captured.first;
    expect(value.system, MeasurementSystem.metric);
    expect(value.mainValue.unit, Unit.meters);
    expect(value.mainValue.value, 150);
  });
}
