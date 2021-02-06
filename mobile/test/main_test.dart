import 'package:flutter_test/flutter_test.dart';
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
      mockAuthManager: true,
      mockBaitCategoryManager: true,
      mockBaitManager: true,
      mockCatchManager: true,
      mockComparisonReportManager: true,
      mockCustomEntityManager: true,
      mockDataManager: true,
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
    when(appManager.mockPreferencesManager.didOnboard).thenReturn(false);

    await tester.pumpWidget(AnglersLog(appManager));

    expect(find.byType(LandingPage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(OnboardingJourney), findsNothing);
    expect(find.byType(MainPage), findsNothing);

    // Wait for delayed initialization.
    await tester.pumpAndSettle(Duration(milliseconds: 60));

    expect(find.byType(LandingPage), findsNothing);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(OnboardingJourney), findsOneWidget);
    expect(find.byType(MainPage), findsNothing);
  });

  testWidgets("Onboarding shown", (tester) async {
    when(appManager.mockPreferencesManager.didOnboard).thenReturn(false);
    await tester.pumpWidget(AnglersLog(appManager));
    await tester.pumpAndSettle(Duration(milliseconds: 50));
    expect(find.byType(OnboardingJourney), findsOneWidget);
    expect(find.byType(MainPage), findsNothing);
  });

  testWidgets("Onboarding not shown", (tester) async {
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

  testWidgets("Preferences is updated only after onboarding finishes",
      (tester) async {
    when(appManager.mockPreferencesManager.catchCustomEntityIds).thenReturn([]);
    when(appManager.mockPreferencesManager.didOnboard).thenReturn(false);
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
    await tester.pumpAndSettle(Duration(milliseconds: 150));
    expect(find.byType(OnboardingJourney), findsOneWidget);
    expect(find.byType(MainPage), findsNothing);
    verifyNever(appManager.mockPreferencesManager.didOnboard = true);

    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("SET PERMISSION"));
    await tapAndSettle(tester, find.text("FINISH"));

    verify(appManager.mockPreferencesManager.didOnboard = true).called(1);
  });

  testWidgets("LoginPage shown", (tester) async {
    when(appManager.mockAuthManager.userId).thenReturn(null);

    await tester.pumpWidget(AnglersLog(appManager));

    // Don't settle. Since progress indicator is always animating, pumpAndSettle
    // will time out.
    await tester.pump();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
