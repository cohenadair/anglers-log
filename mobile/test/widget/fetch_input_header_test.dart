import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/widgets/fetch_input_header.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late InputController<Atmosphere> controller;

  setUp(() {
    appManager = StubbedAppManager();
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

  testWidgets("Selecting 'None' clears controller", (tester) async {
    controller.value = defaultAtmosphere();

    await tester.pumpWidget(Testable(
      (_) => FetchInputHeader<Atmosphere>(
        fishingSpot: null,
        defaultErrorMessage: "",
        dateTime: dateTimestamp(10000),
        onFetch: () => Future.value(FetchResult()),
        onFetchSuccess: (_) {},
        controller: controller,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("None"));
    expect(controller.hasValue, isFalse);
  });

  testWidgets("Fetching as free user opens pro page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FetchInputHeader<Atmosphere>(
        fishingSpot: null,
        defaultErrorMessage: "",
        dateTime: dateTimestamp(10000),
        onFetch: () => Future.value(FetchResult()),
        onFetchSuccess: (_) {},
        controller: controller,
      ),
      appManager: appManager,
    ));

    when(appManager.subscriptionManager.isFree).thenReturn(true);
    when(appManager.subscriptionManager.isPro).thenReturn(false);
    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));

    await tapAndSettle(tester, find.text("FETCH"));
    expect(find.byType(ProPage), findsOneWidget);
  });

  testWidgets("Fetching error shows default error message", (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => Scaffold(
        body: FetchInputHeader<Atmosphere>(
          fishingSpot: null,
          defaultErrorMessage: "Default error message",
          dateTime: dateTimestamp(10000),
          onFetch: () => Future.value(FetchResult()),
          onFetchSuccess: (_) {},
          controller: controller,
        ),
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("FETCH"));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Default error message"), findsOneWidget);
  });

  testWidgets("Null fishing spot shows 'Current Location'", (tester) async {
    controller.value = defaultAtmosphere();

    await tester.pumpWidget(Testable(
      (_) => FetchInputHeader<Atmosphere>(
        fishingSpot: null,
        defaultErrorMessage: "",
        dateTime: dateTimestamp(10000),
        onFetch: () => Future.value(FetchResult()),
        onFetchSuccess: (_) {},
        controller: controller,
      ),
      appManager: appManager,
    ));

    expect(find.text("Current Location"), findsOneWidget);
  });

  testWidgets("Fishing spot display name shown", (tester) async {
    when(appManager.fishingSpotManager.displayName(
      any,
      any,
      useLatLngFallback: anyNamed("useLatLngFallback"),
      includeLatLngLabels: anyNamed("includeLatLngLabels"),
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
    )).thenReturn("Fishing Spot Name");

    controller.value = defaultAtmosphere();

    await tester.pumpWidget(Testable(
      (_) => FetchInputHeader<Atmosphere>(
        fishingSpot: FishingSpot(),
        defaultErrorMessage: "",
        dateTime: dateTimestamp(10000),
        onFetch: () => Future.value(FetchResult()),
        onFetchSuccess: (_) {},
        controller: controller,
      ),
      appManager: appManager,
    ));

    expect(find.text("Current Location"), findsNothing);
    expect(find.text("Fishing Spot Name"), findsOneWidget);
  });

  testWidgets("Fetching a result", (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(false);
    controller.value = defaultAtmosphere();

    var onFetchSuccessCalled = false;
    await tester.pumpWidget(Testable(
      (_) => FetchInputHeader<Atmosphere>(
        fishingSpot: null,
        defaultErrorMessage: "",
        dateTime: dateTimestamp(10000),
        onFetch: () => Future.delayed(const Duration(milliseconds: 5),
            () => FetchResult(data: Atmosphere())),
        onFetchSuccess: (_) => onFetchSuccessCalled = true,
        controller: controller,
      ),
      appManager: appManager,
    ));

    await tester.tap(find.text("FETCH"));
    await tester.pump();
    expect(find.byType(Loading), findsOneWidget);

    await tester.pumpAndSettle(const Duration(milliseconds: 10));
    expect(find.byType(Loading), findsNothing);
    expect(find.text("FETCH"), findsOneWidget);
    expect(onFetchSuccessCalled, isTrue);
  });
}
