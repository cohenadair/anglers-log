import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/landing_page.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/onboarding/onboarding_journey.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'mocks/stubbed_map_controller.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late StubbedMapController mapController;

  setUp(() {
    appManager = StubbedAppManager();
    mapController = StubbedMapController();

    when(appManager.catchManager.hasEntities).thenReturn(false);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    when(appManager.reportManager.entityExists(any)).thenReturn(false);
    when(appManager.reportManager.defaultReport).thenReturn(Report());
    when(appManager.reportManager.displayName(any, any)).thenReturn("Test");

    when(appManager.locationMonitor.currentLocation).thenReturn(null);

    when(appManager.propertiesManager.mapboxApiKey).thenReturn("");

    when(appManager.subscriptionManager.isFree).thenReturn(false);
    when(appManager.subscriptionManager.isPro).thenReturn(true);
    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());

    when(appManager.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(true);
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.selectedReportId).thenReturn(null);
    when(appManager.userPreferenceManager.setSelectedReportId(any))
        .thenAnswer((_) => Future.value());
    when(appManager.userPreferenceManager.setWaterDepthSystem(any))
        .thenAnswer((_) => Future.value());
    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.setWaterTemperatureSystem(any))
        .thenAnswer((_) => Future.value());
    when(appManager.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.setCatchLengthSystem(any))
        .thenAnswer((_) => Future.value());
    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.setCatchWeightSystem(any))
        .thenAnswer((_) => Future.value());
    when(appManager.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.autoFetchAtmosphere)
        .thenReturn(false);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.userPreferenceManager.mapType).thenReturn(null);

    when(appManager.timeManager.currentDateTime)
        .thenReturn(dateTime(2020, 1, 1));

    var channel = MockMethodChannel();
    when(channel.invokeMethod(any)).thenAnswer((_) => Future.value(null));
    when(appManager.servicesWrapper.methodChannel(any)).thenReturn(channel);
  });

  testWidgets("LandingPage is shown until app initializes", (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.locationMonitor.initialize()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => true));
    when(appManager.userPreferenceManager.didOnboard).thenReturn(false);

    await tester.pumpWidget(AnglersLog(appManager.app));

    expect(find.byType(LandingPage), findsOneWidget);
    expect(find.byType(OnboardingJourney), findsNothing);
    expect(find.byType(MainPage), findsNothing);

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 210));

    expect(find.byType(LandingPage), findsNothing);
    expect(find.byType(OnboardingJourney), findsOneWidget);
    expect(find.byType(MainPage), findsNothing);
  });

  testWidgets("Preferences is updated only after onboarding finishes",
      (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.locationMonitor.initialize()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => true));
    when(appManager.userPreferenceManager.didOnboard).thenReturn(false);
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(false));
    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      dateRange: anyNamed("dateRange"),
      catchIds: anyNamed("catchIds"),
      speciesIds: anyNamed("speciesIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      baits: anyNamed("baits"),
    )).thenReturn([]);
    when(appManager.customEntityManager.entityExists(any)).thenReturn(false);
    when(appManager.baitManager.attachmentsDisplayValues(any, any))
        .thenReturn([]);
    when(appManager.anglerManager.entityExists(any)).thenReturn(false);
    when(appManager.speciesManager.entityExists(any)).thenReturn(false);
    when(appManager.waterClarityManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(AnglersLog(appManager.app));

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 210));

    expect(find.byType(OnboardingJourney), findsOneWidget);
    expect(find.byType(MainPage), findsNothing);
    verifyNever(appManager.userPreferenceManager.setDidOnboard(true));

    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("SET PERMISSION"));
    await tapAndSettle(tester, find.text("FINISH"));

    verify(appManager.userPreferenceManager.setDidOnboard(true)).called(1);
  });

  testWidgets("Main page shown", (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      dateRange: anyNamed("dateRange"),
      catchIds: anyNamed("catchIds"),
      speciesIds: anyNamed("speciesIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      baits: anyNamed("baits"),
    )).thenReturn([]);

    await tester.pumpWidget(AnglersLog(appManager.app));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);

    expect(find.byType(OnboardingJourney), findsNothing);
    expect(find.byType(MainPage), findsOneWidget);
  });

  testWidgets("Legacy JSON is fetched if the user hasn't yet onboarded",
      (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.locationMonitor.initialize()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => true));
    when(appManager.userPreferenceManager.didOnboard).thenReturn(false);

    var channel = MockMethodChannel();
    when(channel.invokeMethod(any)).thenAnswer((_) => Future.value({
          "db": "test/db",
        }));
    when(appManager.servicesWrapper.methodChannel(any)).thenReturn(channel);
    await tester.pumpWidget(AnglersLog(appManager.app));

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 210));

    verify(appManager.servicesWrapper.methodChannel(any)).called(1);
    var onboardingJourney = findFirst<OnboardingJourney>(tester);
    expect(onboardingJourney.legacyJsonResult, isNotNull);
  });
}
