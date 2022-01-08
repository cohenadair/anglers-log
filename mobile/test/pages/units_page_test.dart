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
}
