import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/landing_page.dart';
import 'package:mobile/pages/onboarding/catch_field_picker_page.dart';
import 'package:mobile/pages/onboarding/how_to_feedback_page.dart';
import 'package:mobile/pages/onboarding/how_to_manage_fields_page.dart';
import 'package:mobile/pages/onboarding/location_permission_page.dart';
import 'package:mobile/pages/onboarding/migration_page.dart';
import 'package:mobile/pages/onboarding/onboarding_journey.dart';
import 'package:mobile/pages/onboarding/welcome_page.dart';
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
      mockServicesWrapper: true,
    );

    when(appManager.mockLocationMonitor.initialize())
        .thenAnswer((_) => Future.value(null));
    when(appManager.mockPreferencesManager.catchCustomEntityIds).thenReturn([]);
    when(appManager.mockPermissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(true));
  });

  testWidgets("Navigation", (tester) async {
    var channel = MockMethodChannel();
    when(channel.invokeMethod(any))
        .thenAnswer((realInvocation) => Future.value({
              "db": "path/to/db",
              "img": "path/to/images",
              "json": "{}",
            }));
    when(appManager.mockServicesWrapper.methodChannel(any)).thenReturn(channel);

    var finished = false;
    await tester.pumpWidget(
      Testable(
        (_) => OnboardingJourney(
          onFinished: () => finished = true,
        ),
        appManager: appManager,
      ),
    );
    // Wait for legacyJson to finish.
    await tester.pumpAndSettle(Duration(milliseconds: 150));

    expect(find.byType(MigrationPage), findsOneWidget);
    await tapAndSettle(tester, find.text("START"));
    await tapAndSettle(tester, find.text("NEXT"));

    expect(find.byType(WelcomePage), findsOneWidget);
    await tapAndSettle(tester, find.text("GET STARTED"));

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

  testWidgets("LandingPage shown until legacyJson finishes", (tester) async {
    var channel = MockMethodChannel();
    when(channel.invokeMethod(any)).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: 150), () => null));
    when(appManager.mockServicesWrapper.methodChannel(any)).thenReturn(channel);

    await tester.pumpWidget(
      Testable(
        (_) => OnboardingJourney(
          onFinished: () {},
        ),
        appManager: appManager,
      ),
    );
    await tester.pump();
    expect(find.byType(LandingPage), findsOneWidget);

    // Finish legacyJson future.
    await tester.pumpAndSettle(Duration(milliseconds: 175));
    expect(find.byType(LandingPage), findsNothing);
    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets("Migration page shown", (tester) async {
    // This scenario is tested in the "Navigation" test.
  });

  testWidgets("Migration page skipped", (tester) async {
    var channel = MockMethodChannel();
    when(channel.invokeMethod(any)).thenAnswer((_) => Future.value(null));
    when(appManager.mockServicesWrapper.methodChannel(any)).thenReturn(channel);

    await tester.pumpWidget(
      Testable(
        (_) => OnboardingJourney(
          onFinished: () {},
        ),
        appManager: appManager,
      ),
    );
    // Finish legacyJson future.
    await tester.pumpAndSettle(Duration(milliseconds: 50));
    expect(find.byType(WelcomePage), findsOneWidget);
  });
}
