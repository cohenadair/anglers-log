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
import '../../mocks/stubbed_managers.dart';
import '../../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.anglerManager.entityExists(any)).thenReturn(false);

    when(managers.backupRestoreManager.progressStream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(false);

    when(managers.baitManager.attachmentsDisplayValues(any, any))
        .thenReturn([]);

    when(managers.customEntityManager.entityExists(any)).thenReturn(false);

    when(managers.ioWrapper.isAndroid).thenReturn(false);

    when(managers.locationMonitor.initialize())
        .thenAnswer((_) => Future.value(null));
    when(managers.locationMonitor.currentLatLng).thenReturn(null);

    when(managers.pollManager.canVote).thenReturn(false);

    when(managers.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(true);
    when(managers.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(true);
    when(managers.userPreferenceManager.isTrackingGear).thenReturn(true);
    when(managers.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.autoFetchAtmosphere).thenReturn(false);
    when(managers.userPreferenceManager.autoFetchTide).thenReturn(false);
    when(managers.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());

    when(managers.permissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(true));

    when(managers.lib.subscriptionManager.isFree).thenReturn(false);

    when(managers.speciesManager.entityExists(any)).thenReturn(false);

    when(managers.waterClarityManager.entityExists(any)).thenReturn(false);

    var dir = MockDirectory();
    when(dir.listSync()).thenReturn([]);
    when(dir.deleteSync()).thenAnswer((_) {});
    when(dir.deleteSync(recursive: false)).thenAnswer((_) {});
    when(managers.ioWrapper.directory(any)).thenReturn(dir);
  });

  testWidgets("Navigation skips permission page", (tester) async {
    when(managers.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));
    when(managers.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(true));

    var finished = false;
    await tester.pumpWidget(
      Testable(
        (_) => OnboardingJourney(
          onFinished: (_) => finished = true,
          legacyJsonResult: LegacyJsonResult(
            imagesPath: "path/to/images",
            databasePath: "path/to/database",
            json: {},
          ),
        ),
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
    when(managers.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(false));
    when(managers.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(false));
    when(managers.permissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(false));
    when(managers.ioWrapper.isIOS).thenReturn(false);
    when(managers.ioWrapper.isAndroid).thenReturn(true);

    var finished = false;
    await tester.pumpWidget(
      Testable(
        (_) => OnboardingJourney(
          onFinished: (_) => finished = true,
          legacyJsonResult: LegacyJsonResult(
            imagesPath: "path/to/images",
            databasePath: "path/to/database",
            json: {},
          ),
        ),
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
          onFinished: (_) {},
        ),
      ),
    );
    expect(find.byType(CatchFieldPickerPage), findsOneWidget);
  });

  testWidgets("ProPage shown", (tester) async {
    when(managers.lib.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);
    when(managers.lib.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));

    when(managers.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));
    when(managers.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(true));

    var finished = false;
    await tester.pumpWidget(
      Testable(
        (_) => OnboardingJourney(
          onFinished: (_) => finished = true,
          legacyJsonResult: null,
        ),
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
