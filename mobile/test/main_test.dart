import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/onboarding/onboarding_journey.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockDataManager: true,
      mockBaitCategoryManager: true,
      mockBaitManager: true,
      mockCatchManager: true,
      mockComparisonReportManager: true,
      mockCustomEntityManager: true,
      mockFishingSpotManager: true,
      mockImageManager: true,
      mockLocationMonitor: true,
      mockPropertiesManager: true,
      mockPreferencesManager: true,
      mockSpeciesManager: true,
      mockSummaryReportManager: true,
      mockTimeManager: true,
      mockPermissionHandlerWrapper: true,
    );
  });

  testWidgets("Onboarding shown", (tester) async {
    when(appManager.mockPreferencesManager.didOnboard).thenReturn(false);
    await tester.pumpWidget(AnglersLog(appManager));
    await tester.pumpAndSettle(Duration(milliseconds: 250));
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
    await tester.pumpAndSettle(Duration(milliseconds: 250));

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
    await tester.pumpAndSettle(Duration(milliseconds: 250));
    expect(find.byType(OnboardingJourney), findsOneWidget);
    expect(find.byType(MainPage), findsNothing);
    verifyNever(appManager.mockPreferencesManager.didOnboard = true);

    await tapAndSettle(tester, find.text("GET STARTED"));
    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("SET PERMISSION"));
    await tapAndSettle(tester, find.text("FINISH"));

    verify(appManager.mockPreferencesManager.didOnboard = true).called(1);
  });
}
