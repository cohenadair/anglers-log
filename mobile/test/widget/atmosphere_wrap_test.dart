import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/widgets/atmosphere_wrap.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.userPreferenceManager.airTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.airVisibilitySystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.airPressureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.airPressureImperialUnit)
        .thenReturn(Unit.inch_of_mercury);
    when(managers.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.metric);
  });

  Atmosphere defaultAtmosphere() {
    return Atmosphere(
      temperature: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.celsius,
          value: 15,
        ),
      ),
      skyConditions: [SkyCondition.cloudy, SkyCondition.drizzle],
      windSpeed: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.kilometers_per_hour,
          value: 6.5,
        ),
      ),
      windDirection: Direction.north,
      pressure: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.millibars,
          value: 1000,
        ),
      ),
      humidity: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.percent,
          value: 50,
        ),
      ),
      visibility: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.kilometers,
          value: 10,
        ),
      ),
      moonPhase: MoonPhase.full,
      sunriseTimestamp: Int64(1624366800000),
      sunsetTimestamp: Int64(1624388400000),
    );
  }

  testWidgets("Shows all items", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => AtmosphereWrap(defaultAtmosphere()),
    ));

    expect(find.text("15\u00B0C"), findsOneWidget);
    expect(find.text("Cloudy, Drizzle"), findsOneWidget);
    expect(find.text("7 km/h"), findsOneWidget);
    expect(find.text("N"), findsOneWidget);
    expect(find.text("1000 MB"), findsOneWidget);
    expect(find.text("10 km"), findsOneWidget);
    expect(find.text("Full"), findsOneWidget);
    expect(find.text("50%"), findsOneWidget);
    expect(find.text("9:00 AM"), findsOneWidget);
    expect(find.text("3:00 PM"), findsOneWidget);
  });

  testWidgets("Shows no items", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => AtmosphereWrap(Atmosphere()),
    ));

    expect(find.byType(Icon), findsNothing);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets("No subtitle on item shows empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => AtmosphereWrap(
        Atmosphere(
          temperature: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.celsius,
              value: 15,
            ),
          ),
        ),
      ),
    ));

    expect(find.byType(Text), findsOneWidget);
    expect(find.text("15\u00B0C"), findsOneWidget);
  });

  testWidgets("No wind direction shows plain label", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => AtmosphereWrap(
        Atmosphere(
          windSpeed: MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(
              unit: Unit.miles_per_hour,
              value: 15,
            ),
          ),
        ),
      ),
    ));

    expect(find.byType(Text), findsNWidgets(2));
    expect(find.text("15 mph"), findsOneWidget);
    expect(find.text("Wind"), findsOneWidget);
  });

  testWidgets("Wind direction shows", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => AtmosphereWrap(
        Atmosphere(
          windSpeed: MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(
              unit: Unit.miles_per_hour,
              value: 15,
            ),
          ),
          windDirection: Direction.north,
        ),
      ),
    ));

    expect(find.byType(Text), findsNWidgets(2));
    expect(find.text("15 mph"), findsOneWidget);
    expect(find.text("N"), findsOneWidget);
  });

  testWidgets("No temperature shows sky conditions", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => AtmosphereWrap(
        Atmosphere(
          skyConditions: [SkyCondition.sunny, SkyCondition.clear],
        ),
      ),
    );
    expect(find.text("Sunny, Clear"), findsOneWidget);
    expect(find.subtitleText(context), findsNothing);
  });
}
