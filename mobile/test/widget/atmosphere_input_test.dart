import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/pages/settings_page.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/atmosphere_utils.dart';
import 'package:mobile/widgets/atmosphere_input.dart';
import 'package:mobile/widgets/atmosphere_wrap.dart';
import 'package:mobile/widgets/fetch_input_header.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  late MockAtmosphereFetcher fetcher;
  late InputController<Atmosphere> controller;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.customEntityManager.entityExists(any)).thenReturn(false);

    when(managers.localDatabaseManager.fetchAll(any))
        .thenAnswer((_) => Future.value([]));
    when(managers.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(managers.propertiesManager.visualCrossingApiKey).thenReturn("");

    when(managers.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.subscriptionManager.isPro).thenReturn(false);
    when(managers.subscriptionManager.isFree).thenReturn(true);

    when(managers.userPreferenceManager.autoFetchAtmosphere).thenReturn(false);
    when(managers.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
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
    when(managers.userPreferenceManager.windSpeedMetricUnit)
        .thenReturn(Unit.kilometers_per_hour);
    when(managers.userPreferenceManager.fishingSpotDistance).thenReturn(
      MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 20,
        ),
      ),
    );
    when(managers.userPreferenceManager.minGpsTrailDistance)
        .thenReturn(MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.feet,
        value: 150,
      ),
    ));
    when(managers.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.userPreferenceManager.autoFetchTide).thenReturn(false);

    fetcher = MockAtmosphereFetcher();
    when(fetcher.dateTime).thenReturn(dateTimestamp(10000));

    controller = InputController<Atmosphere>();
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
      sunriseTimestamp: Int64(1624348800000),
      sunsetTimestamp: Int64(1624381200000),
    );
  }

  testWidgets("Null atmosphere shows label only", (tester) async {
    controller.value = null;

    await tester.pumpWidget(Testable(
      (_) => AtmosphereInput(
        fetcher: fetcher,
        controller: controller,
      ),
      managers: managers,
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
      managers: managers,
    ));

    var crossFade = findFirst<AnimatedCrossFade>(tester);
    expect(crossFade.crossFadeState, CrossFadeState.showSecond);
    expect(crossFade.secondChild is AtmosphereWrap, isTrue);
  });

  testWidgets("All input fields show when preferences is empty",
      (tester) async {
    when(managers.userPreferenceManager.atmosphereFieldIds).thenReturn([]);

    await tester.pumpWidget(Testable(
      (_) => AtmosphereInput(
        fetcher: fetcher,
        controller: controller,
      ),
      managers: managers,
    ));

    await tapAndSettle(tester, find.text("Atmosphere and Weather"));

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
    when(managers.userPreferenceManager.atmosphereFieldIds).thenReturn([
      atmosphereFieldIdTemperature,
      atmosphereFieldIdSkyCondition,
    ]);

    await tester.pumpWidget(Testable(
      (_) => AtmosphereInput(
        fetcher: fetcher,
        controller: controller,
      ),
      managers: managers,
    ));

    await tapAndSettle(tester, find.text("Atmosphere and Weather"));

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
      managers: managers,
    ));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_right));

    var newAtmosphere = Atmosphere(
      temperature: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.celsius,
          value: 20,
        ),
      ),
      skyConditions: [
        SkyCondition.cloudy,
        SkyCondition.drizzle,
        SkyCondition.clear,
      ],
      windSpeed: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.kilometers_per_hour,
          value: 8.5,
        ),
      ),
      windDirection: Direction.north_east,
      pressure: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.millibars,
          value: 1200,
        ),
      ),
      humidity: MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.percent,
          value: 60,
        ),
      ),
      visibility: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.kilometers,
          value: 12,
        ),
      ),
      moonPhase: MoonPhase.new_,
      sunriseTimestamp: Int64(1624366800000),
      sunsetTimestamp: Int64(1624388400000),
    );

    // Set all values to something different.
    await enterTextFieldAndSettle(tester, "Air Temperature",
        newAtmosphere.temperature.mainValue.value.toString());

    await tapAndSettle(tester, find.text("Cloudy"));
    await tapAndSettle(tester, findListItemCheckbox(tester, "Clear"));
    await tapAndSettle(tester, find.byType(BackButton).last);

    await tapAndSettle(tester, find.text("Wind Direction"));
    await tapAndSettle(tester, find.text("NE"));

    await enterTextFieldAndSettle(tester, "Wind Speed",
        newAtmosphere.windSpeed.mainValue.value.toString());
    await enterTextFieldAndSettle(tester, "Atmospheric Pressure",
        newAtmosphere.pressure.mainValue.value.toString());
    await enterTextFieldAndSettle(tester, "Air Visibility",
        newAtmosphere.visibility.mainValue.value.toString());
    await enterTextFieldAndSettle(tester, "Air Humidity",
        newAtmosphere.humidity.mainValue.value.toString());

    await tester.ensureVisible(find.text("Moon Phase"));
    await tapAndSettle(tester, find.text("Moon Phase"));
    await tapAndSettle(tester, find.text("New"));

    await ensureVisibleAndSettle(tester, find.text("Time of Sunrise"));
    await tapAndSettle(tester, find.text("Time of Sunrise"));
    await tapAndSettle(tester, find.text("AM"));
    var center = tester
        .getCenter(find.byKey(const ValueKey<String>("time-picker-dial")));
    await tester.tapAt(Offset(center.dx - 10, center.dy));
    await tapAndSettle(tester, find.text("OK"));

    await ensureVisibleAndSettle(tester, find.text("Time of Sunset"));
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
      managers: managers,
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

  testWidgets("Successful fetch updates fields and controller", (tester) async {
    var newAtmosphere = Atmosphere(
      temperature: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.celsius,
          value: 20,
        ),
      ),
      skyConditions: [
        SkyCondition.cloudy,
        SkyCondition.drizzle,
        SkyCondition.clear,
      ],
      windSpeed: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.kilometers_per_hour,
          value: 8.5,
        ),
      ),
      windDirection: Direction.north_east,
      pressure: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.millibars,
          value: 1200,
        ),
      ),
      humidity: MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.percent,
          value: 60,
        ),
      ),
      visibility: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.kilometers,
          value: 12,
        ),
      ),
      moonPhase: MoonPhase.new_,
      sunriseTimestamp: Int64(1624366800000),
      sunsetTimestamp: Int64(1624388400000),
    );

    when(managers.subscriptionManager.isFree).thenReturn(false);
    when(fetcher.fetch(any))
        .thenAnswer((_) => Future.value(FetchInputResult(data: newAtmosphere)));

    await tester.pumpWidget(
      Testable(
        (_) => AtmosphereInput(
          fetcher: fetcher,
          controller: controller,
        ),
        managers: managers,
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.chevron_right));
    await tapAndSettle(tester, find.text("FETCH"));

    // Verify value is set correctly.
    expect(controller.hasValue, isTrue);
    expect(controller.value, newAtmosphere);

    // Verify expected UI elements are showing.
    expect(find.widgetWithText(TextInput, "20"), findsOneWidget);
    expect(find.text("Cloudy"), findsOneWidget);
    expect(find.text("Drizzle"), findsOneWidget);
    expect(find.text("Clear"), findsOneWidget);
    expect(find.widgetWithText(TextInput, "9"), findsOneWidget);
    expect(find.text("NE"), findsOneWidget);
    expect(find.widgetWithText(TextInput, "1200"), findsOneWidget);
    expect(find.widgetWithText(TextInput, "60"), findsOneWidget);
    expect(find.widgetWithText(TextInput, "12"), findsOneWidget);
    expect(find.text("New"), findsOneWidget);
    expect(find.text("9:00 AM"), findsOneWidget);
    expect(find.text("3:00 PM"), findsOneWidget);
  });

  testWidgets("Updating units updates widgets", (tester) async {
    UserPreferenceManager.reset();
    await UserPreferenceManager.get.init();

    await UserPreferenceManager.get
        .setAirTemperatureSystem(MeasurementSystem.metric);
    await UserPreferenceManager.get
        .setAirPressureSystem(MeasurementSystem.metric);
    await UserPreferenceManager.get
        .setAirVisibilitySystem(MeasurementSystem.metric);
    await UserPreferenceManager.get
        .setWindSpeedSystem(MeasurementSystem.metric);

    await tester.pumpWidget(Testable(
      (_) => AtmosphereInput(
        fetcher: fetcher,
        controller: controller,
      ),
      managers: managers,
    ));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_right));

    expect(find.text("MB"), findsOneWidget);
    expect(find.text("\u00B0C"), findsOneWidget);
    expect(find.text("km"), findsOneWidget);
    expect(find.text("km/h"), findsOneWidget);

    await UserPreferenceManager.get
        .setAirTemperatureSystem(MeasurementSystem.imperial_decimal);
    await UserPreferenceManager.get
        .setAirPressureSystem(MeasurementSystem.imperial_decimal);
    await UserPreferenceManager.get
        .setAirVisibilitySystem(MeasurementSystem.imperial_decimal);
    await UserPreferenceManager.get
        .setWindSpeedSystem(MeasurementSystem.imperial_decimal);
    await tester.pumpAndSettle();

    expect(find.text("inHg"), findsOneWidget);
    expect(find.text("\u00B0F"), findsOneWidget);
    expect(find.text("mi"), findsOneWidget);
    expect(find.text("mph"), findsOneWidget);
  });

  testWidgets("Auto-fetch menu item opens Settings", (tester) async {
    controller.value = defaultAtmosphere();

    await tester.pumpWidget(Testable(
      (_) => AtmosphereInput(
        fetcher: fetcher,
        controller: controller,
      ),
      managers: managers,
    ));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_right));
    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Auto-fetch"));

    expect(find.byType(SettingsPage), findsOneWidget);
  });
}
