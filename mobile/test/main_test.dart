import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/main.dart';
import 'package:mobile/pages/landing_page.dart';
import 'package:mobile/pages/login_page.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/onboarding/onboarding_journey.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockAppPreferenceManager: true,
      mockAuthManager: true,
      mockBaitCategoryManager: true,
      mockBaitManager: true,
      mockCatchManager: true,
      mockComparisonReportManager: true,
      mockCustomEntityManager: true,
      mockLocalDatabaseManager: true,
      mockFishingSpotManager: true,
      mockImageManager: true,
      mockLocationMonitor: true,
      mockPropertiesManager: true,
      mockPreferencesManager: true,
      mockSpeciesManager: true,
      mockSummaryReportManager: true,
      mockTimeManager: true,
      mockFirebaseWrapper: true,
      mockPermissionHandlerWrapper: true,
      mockServicesWrapper: true,
    );

    when(appManager.mockAuthManager.userId).thenReturn(Uuid().v4());
    when(appManager.mockAuthManager.stream).thenAnswer((_) => Stream.empty());

    when(appManager.mockPreferencesManager.didOnboard).thenReturn(true);

    var channel = MockMethodChannel();
    when(channel.invokeMethod(any)).thenAnswer((_) => Future.value(null));
    when(appManager.mockServicesWrapper.methodChannel(any)).thenReturn(channel);
  });

  testWidgets("LandingPage is shown until app initializes", (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.mockFirebaseWrapper.initializeApp()).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: 50), () => true));
    when(appManager.mockAuthManager.state).thenReturn(AuthState.loggedOut);

    await tester.pumpWidget(AnglersLog(appManager));

    expect(find.byType(LandingPage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(OnboardingJourney), findsNothing);
    expect(find.byType(MainPage), findsNothing);

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(Duration(milliseconds: 210));

    expect(find.byType(LandingPage), findsNothing);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(OnboardingJourney), findsNothing);
    expect(find.byType(MainPage), findsNothing);
  });

  testWidgets("Landing page shown while AuthState is unknown", (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.mockFirebaseWrapper.initializeApp()).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: 50), () => true));
    when(appManager.mockAuthManager.state).thenReturn(AuthState.unknown);

    await tester.pumpWidget(AnglersLog(appManager));

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(Duration(milliseconds: 210));

    expect(find.byType(LandingPage), findsOneWidget);
  });

  testWidgets("Onboarding shown after login", (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.mockFirebaseWrapper.initializeApp()).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: 50), () => true));
    when(appManager.mockPreferencesManager.didOnboard).thenReturn(false);
    when(appManager.mockAuthManager.state).thenReturn(AuthState.loggedIn);

    await tester.pumpWidget(AnglersLog(appManager));

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(Duration(milliseconds: 210));

    expect(find.byType(OnboardingJourney), findsOneWidget);
    expect(find.byType(MainPage), findsNothing);
  });

  testWidgets("Preferences is updated only after onboarding finishes",
      (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.mockFirebaseWrapper.initializeApp()).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: 50), () => true));
    when(appManager.mockPreferencesManager.catchCustomEntityIds).thenReturn([]);
    when(appManager.mockPreferencesManager.didOnboard).thenReturn(false);
    when(appManager.mockAuthManager.state).thenReturn(AuthState.loggedIn);
    when(appManager.mockPermissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(false));
    when(appManager.mockFishingSpotManager.list()).thenReturn([]);
    when(appManager.mockCatchManager.catchesSortedByTimestamp(
      any,
      filter: anyNamed("filter"),
      dateRange: anyNamed("dateRange"),
      catchIds: anyNamed("catchIds"),
      speciesIds: anyNamed("speciesIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      baitIds: anyNamed("baitIds"),
    )).thenReturn([]);

    await tester.pumpWidget(AnglersLog(appManager));

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(Duration(milliseconds: 210));

    expect(find.byType(OnboardingJourney), findsOneWidget);
    expect(find.byType(MainPage), findsNothing);
    verifyNever(appManager.mockPreferencesManager.didOnboard = true);

    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("SET PERMISSION"));
    await tapAndSettle(tester, find.text("FINISH"));

    verify(appManager.mockPreferencesManager.didOnboard = true).called(1);
  });

  testWidgets("Main page shown after login", (tester) async {
    when(appManager.mockAuthManager.state).thenReturn(AuthState.loggedIn);
    when(appManager.mockPreferencesManager.didOnboard).thenReturn(true);
    when(appManager.mockFishingSpotManager.list()).thenReturn([]);
    when(appManager.mockCatchManager.catchesSortedByTimestamp(
      any,
      filter: anyNamed("filter"),
      dateRange: anyNamed("dateRange"),
      catchIds: anyNamed("catchIds"),
      speciesIds: anyNamed("speciesIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      baitIds: anyNamed("baitIds"),
    )).thenReturn([]);

    await tester.pumpWidget(AnglersLog(appManager));
    await tester.pumpAndSettle(Duration(milliseconds: 150));

    expect(find.byType(OnboardingJourney), findsNothing);
    expect(find.byType(MainPage), findsOneWidget);
  });

  testWidgets("LoginPage shown when not logged in", (tester) async {
    when(appManager.mockAuthManager.state).thenReturn(AuthState.loggedOut);
    when(appManager.mockAuthManager.userId).thenReturn(null);

    await tester.pumpWidget(AnglersLog(appManager));

    // Don't settle. Since progress indicator is always animating, pumpAndSettle
    // will time out.
    await tester.pump();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets("LoginPage shown while waiting to login", (tester) async {
    var controller = StreamController<AuthState>.broadcast();
    when(appManager.mockAuthManager.stream)
        .thenAnswer((_) => controller.stream);
    when(appManager.mockAuthManager.state).thenReturn(AuthState.loggedOut);
    when(appManager.mockPreferencesManager.didOnboard).thenReturn(true);
    when(appManager.mockFishingSpotManager.list()).thenReturn([]);
    when(appManager.mockCatchManager.catchesSortedByTimestamp(
      any,
      filter: anyNamed("filter"),
      dateRange: anyNamed("dateRange"),
      catchIds: anyNamed("catchIds"),
      speciesIds: anyNamed("speciesIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      baitIds: anyNamed("baitIds"),
    )).thenReturn([]);

    await tester.pumpWidget(AnglersLog(appManager));

    // Don't settle. Since progress indicator is always animating, pumpAndSettle
    // will time out.
    await tester.pump();
    expect(find.byType(LoginPage), findsOneWidget);

    when(appManager.mockAuthManager.state).thenReturn(AuthState.initializing);
    controller.add(AuthState.initializing);
    await tester.pump();
    expect(find.byType(LoginPage), findsOneWidget);

    when(appManager.mockAuthManager.state).thenReturn(AuthState.loggedIn);
    controller.add(AuthState.loggedIn);
    await tester.pumpAndSettle(Duration(milliseconds: 150));
    expect(find.byType(MainPage), findsOneWidget);
  });

  testWidgets("LandingPage shown while waiting for auth state", (tester) async {
    var controller = StreamController<AuthState>.broadcast();
    when(appManager.mockAuthManager.stream)
        .thenAnswer((_) => controller.stream);
    when(appManager.mockAuthManager.state).thenReturn(AuthState.initializing);
    when(appManager.mockPreferencesManager.didOnboard).thenReturn(true);
    when(appManager.mockFishingSpotManager.list()).thenReturn([]);
    when(appManager.mockCatchManager.catchesSortedByTimestamp(
      any,
      filter: anyNamed("filter"),
      dateRange: anyNamed("dateRange"),
      catchIds: anyNamed("catchIds"),
      speciesIds: anyNamed("speciesIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      baitIds: anyNamed("baitIds"),
    )).thenReturn([]);

    await tester.pumpWidget(AnglersLog(appManager));

    // Don't settle. Since progress indicator is always animating, pumpAndSettle
    // will time out.
    await tester.pump();
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(LandingPage), findsOneWidget);

    when(appManager.mockAuthManager.state).thenReturn(AuthState.loggedIn);
    controller.add(AuthState.loggedIn);
    await tester.pumpAndSettle(Duration(milliseconds: 150));
    expect(find.byType(MainPage), findsOneWidget);
  });

  testWidgets("Legacy JSON is fetched if the user hasn't yet onboarded",
      (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.mockFirebaseWrapper.initializeApp()).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: 50), () => true));
    when(appManager.mockAuthManager.state).thenReturn(AuthState.loggedIn);
    when(appManager.mockPreferencesManager.didOnboard).thenReturn(false);

    var channel = MockMethodChannel();
    when(channel.invokeMethod(any)).thenAnswer((_) => Future.value({
          "db": "test/db",
        }));
    when(appManager.mockServicesWrapper.methodChannel(any)).thenReturn(channel);
    await tester.pumpWidget(AnglersLog(appManager));

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(Duration(milliseconds: 210));

    verify(appManager.mockServicesWrapper.methodChannel(any)).called(1);
    var onboardingJourney = findFirst<OnboardingJourney>(tester);
    expect(onboardingJourney.legacyJsonResult, isNotNull);
  });
}
