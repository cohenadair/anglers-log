import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/channels/migration_channel.dart';
import 'package:mobile/pages/onboarding/catch_field_picker_page.dart';
import 'package:mobile/pages/onboarding/how_to_feedback_page.dart';
import 'package:mobile/pages/onboarding/how_to_manage_fields_page.dart';
import 'package:mobile/pages/onboarding/location_permission_page.dart';
import 'package:mobile/pages/onboarding/migration_page.dart';
import 'package:mobile/pages/onboarding/onboarding_journey.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../../mock_app_manager.dart';
import '../../test_utils.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockBaitManager: true,
      mockBaitCategoryManager: true,
      mockCustomEntityManager: true,
      mockFishingSpotManager: true,
      mockLocationMonitor: true,
      mockPreferencesManager: true,
      mockSpeciesManager: true,
      mockTimeManager: true,
      mockIoWrapper: true,
      mockPermissionHandlerWrapper: true,
    );

    when(appManager.mockLocationMonitor.initialize())
        .thenAnswer((_) => Future.value(null));
    when(appManager.mockPreferencesManager.catchCustomEntityIds).thenReturn([]);
    when(appManager.mockPermissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(true));
  });

  testWidgets("Navigation", (tester) async {
    var finished = false;
    await tester.pumpWidget(
      Testable(
        (_) => OnboardingJourney(
          onFinished: () => finished = true,
          legacyJsonResult: LegacyJsonResult(
            imagesPath: "path/to/images",
            databasePath: "path/to/database",
            json: {},
          ),
        ),
        appManager: appManager,
      ),
    );

    expect(find.byType(MigrationPage), findsOneWidget);
    await tapAndSettle(tester, find.text("START"));
    await tapAndSettle(tester, find.text("NEXT"));

    expect(find.byType(CatchFieldPickerPage), findsOneWidget);
    await tapAndSettle(tester, find.text("NEXT"));

    expect(find.byType(HowToManageFieldsPage), findsOneWidget);
    await tapAndSettle(tester, find.text("NEXT"));

    // Next button is disabled for this page. We want to force the user to set
    // location permissions.
    expect(find.byType(LocationPermissionPage), findsOneWidget);
    expect(findFirstWithText<ActionButton>(tester, "NEXT").onPressed, isNull);
    await tapAndSettle(tester, find.text("SET PERMISSION"));

    expect(find.byType(HowToFeedbackPage), findsOneWidget);
    await tapAndSettle(tester, find.text("FINISH"));

    expect(finished, isTrue);
  });

  testWidgets("Migration page shown", (tester) async {
    // This scenario is tested in the "Navigation" test.
  });

  testWidgets("Migration page skipped", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => OnboardingJourney(
          onFinished: () {},
        ),
        appManager: appManager,
      ),
    );
    expect(find.byType(CatchFieldPickerPage), findsOneWidget);
  });
}
