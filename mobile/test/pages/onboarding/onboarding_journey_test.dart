import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/channels/migration_channel.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/onboarding/catch_field_picker_page.dart';
import 'package:mobile/pages/onboarding/how_to_feedback_page.dart';
import 'package:mobile/pages/onboarding/how_to_manage_fields_page.dart';
import 'package:mobile/pages/onboarding/location_permission_page.dart';
import 'package:mobile/pages/onboarding/onboarding_migration_page.dart';
import 'package:mobile/pages/onboarding/onboarding_journey.dart';
import 'package:mobile/pages/onboarding/onboarding_pro_page.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mocks.mocks.dart';
import '../../mocks/stubbed_app_manager.dart';
import '../../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.anglerManager.entityExists(any)).thenReturn(false);

    when(appManager.baitManager.attachmentsDisplayValues(any, any))
        .thenReturn([]);

    when(appManager.customEntityManager.entityExists(any)).thenReturn(false);

    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    when(appManager.locationMonitor.initialize())
        .thenAnswer((_) => Future.value(null));
    when(appManager.locationMonitor.currentLatLng).thenReturn(null);

    when(appManager.pollManager.canVote).thenReturn(false);

    when(appManager.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingGear).thenReturn(true);
    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.autoFetchAtmosphere)
        .thenReturn(false);
    when(appManager.userPreferenceManager.autoFetchTide).thenReturn(false);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());

    when(appManager.permissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.isFree).thenReturn(false);

    when(appManager.speciesManager.entityExists(any)).thenReturn(false);

    when(appManager.waterClarityManager.entityExists(any)).thenReturn(false);

    var dir = MockDirectory();
    when(dir.listSync()).thenReturn([]);
    when(dir.deleteSync()).thenAnswer((_) {});
    when(dir.deleteSync(recursive: false)).thenAnswer((_) {});
    when(appManager.ioWrapper.directory(any)).thenReturn(dir);
  });

  testWidgets("Navigation skips permission page", (tester) async {
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(true));

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

    expect(find.byType(OnboardingMigrationPage), findsOneWidget);
    await tapAndSettle(tester, find.text("START"));
    await tapAndSettle(tester, find.text("NEXT"));

    expect(find.byType(CatchFieldPickerPage), findsOneWidget);
    await tapAndSettle(tester, find.text("NEXT"));

    expect(find.byType(HowToManageFieldsPage), findsOneWidget);
    await tapAndSettle(tester, find.text("NEXT"));

    expect(find.byType(HowToFeedbackPage), findsOneWidget);
    await tapAndSettle(tester, find.text("FINISH"));

    expect(finished, isTrue);
  });

  testWidgets("Navigation", (tester) async {
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.requestLocationAlways())
        .thenAnswer((_) => Future.value(false));
    when(appManager.ioWrapper.isIOS).thenReturn(true);
    when(appManager.ioWrapper.isAndroid).thenReturn(false);

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

    await tapAndSettle(tester, find.text("NEXT"));

    expect(find.byType(OnboardingMigrationPage), findsOneWidget);
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
    await tapAndSettle(tester, find.text("CANCEL"));

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

  testWidgets("ProPage shown", (tester) async {
    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isFree).thenReturn(true);
    when(appManager.subscriptionManager.isPro).thenReturn(false);
    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));

    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(true));

    var finished = false;
    await tester.pumpWidget(
      Testable(
        (_) => OnboardingJourney(
          onFinished: () => finished = true,
          legacyJsonResult: null,
        ),
        appManager: appManager,
      ),
    );

    expect(find.byType(CatchFieldPickerPage), findsOneWidget);
    await tapAndSettle(tester, find.text("NEXT"));

    expect(find.byType(HowToManageFieldsPage), findsOneWidget);
    await tapAndSettle(tester, find.text("NEXT"));

    expect(find.byType(HowToFeedbackPage), findsOneWidget);
    await tapAndSettle(tester, find.text("NEXT"));

    expect(find.byType(OnboardingProPage), findsOneWidget);
    await tapAndSettle(tester, find.text("NOT NOW"));

    expect(finished, isTrue);
  });
}
