import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/main.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/landing_page.dart';
import 'package:mobile/pages/login_page.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/onboarding/onboarding_journey.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

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

    when(appManager.appPreferenceManager.lastLoggedInEmail).thenReturn(null);

    when(appManager.authManager.initialize())
        .thenAnswer((_) => Future.value(null));
    when(appManager.authManager.userId).thenReturn(const Uuid().v4());
    when(appManager.authManager.stream).thenAnswer((_) => const Stream.empty());

    when(appManager.reportManager.entityExists(any)).thenReturn(false);

    when(appManager.locationMonitor.currentLocation).thenReturn(null);

    when(appManager.propertiesManager.mapboxApiKey).thenReturn("");

    when(appManager.subscriptionManager.isFree).thenReturn(false);

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

    var channel = MockMethodChannel();
    when(channel.invokeMethod(any)).thenAnswer((_) => Future.value(null));
    when(appManager.servicesWrapper.methodChannel(any)).thenReturn(channel);
  });

  testWidgets("LandingPage is shown until app initializes", (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.firebaseWrapper.initializeApp()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => true));
    when(appManager.authManager.state).thenReturn(AuthState.loggedOut);

    await tester.pumpWidget(AnglersLog(appManager.app));

    expect(find.byType(LandingPage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(OnboardingJourney), findsNothing);
    expect(find.byType(MainPage), findsNothing);

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 210));

    expect(find.byType(LandingPage), findsNothing);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(OnboardingJourney), findsNothing);
    expect(find.byType(MainPage), findsNothing);
  });

  testWidgets("Landing page shown while AuthState is unknown", (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.firebaseWrapper.initializeApp()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => true));
    when(appManager.authManager.state).thenReturn(AuthState.unknown);

    await tester.pumpWidget(AnglersLog(appManager.app));

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 210));

    expect(find.byType(LandingPage), findsOneWidget);
  });

  testWidgets("Onboarding shown after login", (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.firebaseWrapper.initializeApp()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => true));
    when(appManager.userPreferenceManager.didOnboard).thenReturn(false);
    when(appManager.authManager.state).thenReturn(AuthState.loggedIn);

    await tester.pumpWidget(AnglersLog(appManager.app));

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 210));

    expect(find.byType(OnboardingJourney), findsOneWidget);
    expect(find.byType(MainPage), findsNothing);
  });

  testWidgets("Preferences is updated only after onboarding finishes",
      (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.firebaseWrapper.initializeApp()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => true));
    when(appManager.userPreferenceManager.didOnboard).thenReturn(false);
    when(appManager.authManager.state).thenReturn(AuthState.loggedIn);
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(false));
    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.catchManager.catchesSortedByTimestamp(
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

  testWidgets("Main page shown after login", (tester) async {
    when(appManager.authManager.state).thenReturn(AuthState.loggedIn);
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.catchManager.catchesSortedByTimestamp(
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

  testWidgets("LoginPage shown when not logged in", (tester) async {
    when(appManager.authManager.state).thenReturn(AuthState.loggedOut);
    when(appManager.authManager.userId).thenReturn(null);

    await tester.pumpWidget(AnglersLog(appManager.app));

    // Don't settle. Since progress indicator is always animating, pumpAndSettle
    // will time out.
    await tester.pump();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets("LoginPage shown while waiting to login", (tester) async {
    var controller = StreamController<AuthState>.broadcast();
    when(appManager.authManager.stream).thenAnswer((_) => controller.stream);
    when(appManager.authManager.state).thenReturn(AuthState.loggedOut);
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.catchManager.catchesSortedByTimestamp(
      any,
      filter: anyNamed("filter"),
      dateRange: anyNamed("dateRange"),
      catchIds: anyNamed("catchIds"),
      speciesIds: anyNamed("speciesIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      baits: anyNamed("baits"),
    )).thenReturn([]);

    await tester.pumpWidget(AnglersLog(appManager.app));

    // Don't settle. Since progress indicator is always animating, pumpAndSettle
    // will time out.
    await tester.pump();
    expect(find.byType(LoginPage), findsOneWidget);

    when(appManager.authManager.state).thenReturn(AuthState.initializing);
    controller.add(AuthState.initializing);
    await tester.pump();
    expect(find.byType(LoginPage), findsOneWidget);

    when(appManager.authManager.state).thenReturn(AuthState.loggedIn);
    controller.add(AuthState.loggedIn);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);
    expect(find.byType(MainPage), findsOneWidget);
  });

  testWidgets("LandingPage shown while waiting for auth state", (tester) async {
    var controller = StreamController<AuthState>.broadcast();
    when(appManager.authManager.stream).thenAnswer((_) => controller.stream);
    when(appManager.authManager.state).thenReturn(AuthState.initializing);
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.catchManager.catchesSortedByTimestamp(
      any,
      filter: anyNamed("filter"),
      dateRange: anyNamed("dateRange"),
      catchIds: anyNamed("catchIds"),
      speciesIds: anyNamed("speciesIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      baits: anyNamed("baits"),
    )).thenReturn([]);

    await tester.pumpWidget(AnglersLog(appManager.app));

    // Don't settle. Since progress indicator is always animating, pumpAndSettle
    // will time out.
    await tester.pump();
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(LandingPage), findsOneWidget);

    when(appManager.authManager.state).thenReturn(AuthState.loggedIn);
    controller.add(AuthState.loggedIn);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);
    expect(find.byType(MainPage), findsOneWidget);
  });

  testWidgets("Legacy JSON is fetched if the user hasn't yet onboarded",
      (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.firebaseWrapper.initializeApp()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => true));
    when(appManager.authManager.state).thenReturn(AuthState.loggedIn);
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
