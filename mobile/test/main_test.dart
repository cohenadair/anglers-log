import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/onboarding/onboarding_journey.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockDataManager: true,
      mockLocationMonitor: true,
      mockPropertiesManager: true,
      mockBaitCategoryManager: true,
      mockBaitManager: true,
      mockCatchManager: true,
      mockComparisonReportManager: true,
      mockCustomEntityManager: true,
      mockFishingSpotManager: true,
      mockImageManager: true,
      mockPreferencesManager: true,
      mockSpeciesManager: true,
      mockSummaryReportManager: true,
      mockTimeManager: true,
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
}