import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/utils/atmosphere_utils.dart';
import 'package:mobile/widgets/atmosphere_input.dart';
import 'package:mobile/widgets/atmosphere_wrap.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  late MockAtmosphereFetcher fetcher;
  late InputController<Atmosphere> controller;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.propertiesManager.visualCrossingApiKey).thenReturn("");
    when(appManager.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.airTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airVisibilitySystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airPressureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.metric);

    fetcher = MockAtmosphereFetcher();
    controller = InputController<Atmosphere>();
  });

  Atmosphere defaultAtmosphere() {
    return Atmosphere(
      temperature: Measurement(
        unit: Unit.celsius,
        value: 15,
      ),
      skyConditions: [SkyCondition.cloudy, SkyCondition.drizzle],
      windSpeed: Measurement(
        unit: Unit.kilometers_per_hour,
        value: 6.5,
      ),
      windDirection: Direction.north,
      pressure: Measurement(
        unit: Unit.millibars,
        value: 1000,
      ),
      humidity: Measurement(
        unit: Unit.percent,
        value: 50,
      ),
      visibility: Measurement(
        unit: Unit.kilometers,
        value: 10,
      ),
      moonPhase: MoonPhase.full,
      sunriseMillis: Int64(8000),
      sunsetMillis: Int64(9000),
    );
  }

  testWidgets("Null atmosphere shows label only", (tester) async {
    controller.value = null;

    await tester.pumpWidget(Testable(
      (_) => AtmosphereInput(
        fetcher: fetcher,
        controller: controller,
      ),
      appManager: appManager,
    ));

    var crossFade = findFirst<AnimatedCrossFade>(tester);
    expect(crossFade.crossFadeState, CrossFadeState.showFirst);
    expect(crossFade.secondChild is Empty, isTrue);
  });

  testWidgets("Non-null atmosphere shows AtmosphereWrap", (tester) async {
    controller.value = defaultAtmosphere();

    await tester.pumpWidget(Testable(
      (_) => AtmosphereInput(
        fetcher: fetcher,
        controller: controller,
      ),
      appManager: appManager,
    ));

    var crossFade = findFirst<AnimatedCrossFade>(tester);
    expect(crossFade.crossFadeState, CrossFadeState.showSecond);
    expect(crossFade.secondChild is AtmosphereWrap, isTrue);
  });

  testWidgets("All input fields show when preferences is empty",
      (tester) async {
    when(appManager.userPreferenceManager.atmosphereFieldIds).thenReturn([]);

    await tester.pumpWidget(Testable(
      (_) => AtmosphereInput(
        fetcher: fetcher,
        controller: controller,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Atmosphere & Weather"));

    expect(find.text("None"), findsOneWidget);
    expect(find.text("Air Temperature"), findsOneWidget);
    expect(find.text("No sky conditions"), findsOneWidget);
    expect(find.text("Wind Direction"), findsOneWidget);
    expect(find.text("Wind Speed"), findsOneWidget);
    expect(find.text("Atmospheric Pressure"), findsOneWidget);
    expect(find.text("Air Visibility"), findsOneWidget);
    expect(find.text("Air Humidity"), findsOneWidget);
    expect(find.text("Moon Phase"), findsOneWidget);
    expect(find.text("Time of Sunrise"), findsOneWidget);
    expect(find.text("Time of Sunset"), findsOneWidget);
  });

  testWidgets("Only fields in preferences are shown", (tester) async {
    when(appManager.userPreferenceManager.atmosphereFieldIds).thenReturn([
      atmosphereFieldIdTemperature,
      atmosphereFieldIdSkyCondition,
    ]);

    await tester.pumpWidget(Testable(
      (_) => AtmosphereInput(
        fetcher: fetcher,
        controller: controller,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Atmosphere & Weather"));

    expect(find.text("None"), findsOneWidget);
    expect(find.text("Air Temperature"), findsOneWidget);
    expect(find.text("No sky conditions"), findsOneWidget);
    expect(find.text("Wind Direction"), findsNothing);
    expect(find.text("Wind Speed"), findsNothing);
    expect(find.text("Atmospheric Pressure"), findsNothing);
    expect(find.text("Air Visibility"), findsNothing);
    expect(find.text("Air Humidity"), findsNothing);
    expect(find.text("Moon Phase"), findsNothing);
    expect(find.text("Time of Sunrise"), findsNothing);
    expect(find.text("Time of Sunset"), findsNothing);
  });

  testWidgets("Editing atmosphere data", (tester) async {
    controller.value = defaultAtmosphere();

    await tester.pumpWidget(Testable(
      (_) => AtmosphereInput(
        fetcher: fetcher,
        controller: controller,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_right));

    var newAtmosphere = Atmosphere(
      temperature: Measurement(
        unit: Unit.celsius,
        value: 20,
      ),
      skyConditions: [
        SkyCondition.cloudy,
        SkyCondition.drizzle,
        SkyCondition.clear,
      ],
      windSpeed: Measurement(
        unit: Unit.kilometers_per_hour,
        value: 8.5,
      ),
      windDirection: Direction.north_east,
      pressure: Measurement(
        unit: Unit.millibars,
        value: 1200,
      ),
      humidity: Measurement(
        unit: Unit.percent,
        value: 60,
      ),
      visibility: Measurement(
        unit: Unit.kilometers,
        value: 12,
      ),
      moonPhase: MoonPhase.new_,
      sunriseMillis: Int64(32400000),
      // 09:00
      sunsetMillis: Int64(54000000), // 15:00
    );

    // Set all values to something different.
    await enterTextFieldAndSettle(
        tester, "Air Temperature", newAtmosphere.temperature.value.toString());

    await tapAndSettle(tester, find.text("Cloudy"));
    await tapAndSettle(tester, findListItemCheckbox(tester, "Clear"));
    await tapAndSettle(tester, find.byType(BackButton).last);

    await tapAndSettle(tester, find.text("Wind Direction"));
    await tapAndSettle(tester, find.text("NE"));

    await enterTextFieldAndSettle(
        tester, "Wind Speed", newAtmosphere.windSpeed.value.toString());
    await enterTextFieldAndSettle(tester, "Atmospheric Pressure",
        newAtmosphere.pressure.value.toString());
    await enterTextFieldAndSettle(
        tester, "Air Visibility", newAtmosphere.visibility.value.toString());
    await enterTextFieldAndSettle(
        tester, "Air Humidity", newAtmosphere.humidity.toString());

    await tester.ensureVisible(find.text("Moon Phase"));
    await tapAndSettle(tester, find.text("Moon Phase"));
    await tapAndSettle(tester, find.text("New"));

    await tester.ensureVisible(find.text("Time of Sunrise"));
    await tapAndSettle(tester, find.text("Time of Sunrise"));
    await tapAndSettle(tester, find.text("AM"));
    var center = tester
        .getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
    await tester.tapAt(Offset(center.dx - 10, center.dy));
    await tapAndSettle(tester, find.text("OK"));

    await tester.ensureVisible(find.text("Time of Sunset"));
    await tapAndSettle(tester, find.text("Time of Sunset"));
    await tapAndSettle(tester, find.text("PM"));
    await tester.tapAt(Offset(center.dx + 10, center.dy));
    await tapAndSettle(tester, find.text("OK"));

    await tapAndSettle(tester, find.byType(BackButton).last);

    expect(controller.hasValue, isTrue);
    expect(controller.value, newAtmosphere);
  });

  testWidgets("Selecting fields updates preferences and controller",
      (tester) async {
    controller.value = defaultAtmosphere();

    await tester.pumpWidget(Testable(
      (_) => AtmosphereInput(
        fetcher: fetcher,
        controller: controller,
      ),
      appManager: appManager,
    ));

    expect(controller.hasValue, isTrue);
    expect(controller.value!.hasTemperature(), isTrue);
    expect(controller.value!.hasWindDirection(), isTrue);

    await tapAndSettle(tester, find.byIcon(Icons.chevron_right));
    await tapAndSettle(tester, find.byIcon(Icons.more_vert));
    await tapAndSettle(tester, find.text("Manage Fields"));
    await tapAndSettle(tester, findListItemCheckbox(tester, "Temperature"));
    await tapAndSettle(tester, findListItemCheckbox(tester, "Wind Direction"));
    await tapAndSettle(tester, find.byType(CloseButton));

    expect(controller.hasValue, isTrue);
    expect(controller.value!.hasTemperature(), isFalse);
    expect(controller.value!.hasWindDirection(), isFalse);
  });

  testWidgets("Selecting 'None' clears controller", (tester) async {
    controller.value = defaultAtmosphere();

    await tester.pumpWidget(Testable(
      (_) => AtmosphereInput(
        fetcher: fetcher,
        controller: controller,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_right));
    await tapAndSettle(tester, find.text("None"));

    expect(controller.hasValue, isFalse);
  });

  testWidgets("Fetching as free user opens pro page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => AtmosphereInput(
        fetcher: fetcher,
        controller: controller,
      ),
      appManager: appManager,
    ));

    when(appManager.subscriptionManager.isFree).thenReturn(true);
    when(appManager.subscriptionManager.isPro).thenReturn(false);
    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_right));
    await tester.drag(find.byType(RefreshIndicator), Offset(0, 300));
    await tester.pumpAndSettle();

    expect(find.byType(ProPage), findsOneWidget);
  });

  testWidgets("Fetching error shows error message", (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(false);
    when(fetcher.fetch()).thenAnswer((_) => Future.value(null));

    await tester.pumpWidget(Testable(
      (_) => AtmosphereInput(
        fetcher: fetcher,
        controller: controller,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_right));
    await tester.drag(find.byType(RefreshIndicator), Offset(0, 300));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets("Successful fetch updates fields and controller", (tester) async {
    var newAtmosphere = Atmosphere(
      temperature: Measurement(
        unit: Unit.celsius,
        value: 20,
      ),
      skyConditions: [
        SkyCondition.cloudy,
        SkyCondition.drizzle,
        SkyCondition.clear,
      ],
      windSpeed: Measurement(
        unit: Unit.kilometers_per_hour,
        value: 8.5,
      ),
      windDirection: Direction.north_east,
      pressure: Measurement(
        unit: Unit.millibars,
        value: 1200,
      ),
      humidity: Measurement(
        unit: Unit.percent,
        value: 60,
      ),
      visibility: Measurement(
        unit: Unit.kilometers,
        value: 12,
      ),
      moonPhase: MoonPhase.new_,
      // 09:00
      sunriseMillis: Int64(32400000),
      // 15:00
      sunsetMillis: Int64(54000000),
    );

    when(appManager.subscriptionManager.isFree).thenReturn(false);
    when(fetcher.fetch()).thenAnswer((_) => Future.value(newAtmosphere));

    await tester.pumpWidget(
      Testable(
        (_) => AtmosphereInput(
          fetcher: fetcher,
          controller: controller,
        ),
        appManager: appManager,
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.chevron_right));
    await tester.drag(find.byType(RefreshIndicator), Offset(0, 300));
    await tester.pumpAndSettle();

    expect(controller.hasValue, isTrue);
    expect(controller.value, newAtmosphere);
  });
}
