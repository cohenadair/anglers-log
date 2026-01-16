import 'dart:async';

import 'package:adair_flutter_lib/pages/landing_page.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/onboarding/change_log_page.dart';
import 'package:mobile/pages/onboarding/onboarding_journey.dart';
import 'package:mobile/pages/onboarding/translation_warning_page.dart';
import 'package:mobile/pages/save_bait_variant_page.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/trip_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timezone/timezone.dart';

import '../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../adair-flutter-lib/test/test_utils/widget.dart';
import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_managers.dart';
import 'test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(false);

    when(managers.catchManager.hasEntities).thenReturn(false);
    when(managers.catchManager.list()).thenReturn([]);
    when(
      managers.catchManager.listen(any),
    ).thenAnswer((_) => MockStreamSubscription());

    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    when(
      managers.gpsTrailManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.gpsTrailManager.hasActiveTrail).thenReturn(false);
    when(managers.gpsTrailManager.activeTrial).thenReturn(null);

    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
    when(managers.lib.ioWrapper.isIOS).thenReturn(true);

    when(managers.reportManager.entityExists(any)).thenReturn(false);
    when(managers.reportManager.defaultReport).thenReturn(Report());
    when(managers.reportManager.displayName(any, any)).thenReturn("Test");

    when(managers.locationMonitor.currentLatLng).thenReturn(null);

    when(
      managers.notificationManager.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(managers.pollManager.canVote).thenReturn(false);
    when(managers.pollManager.stream).thenAnswer((_) => const Stream.empty());

    when(managers.propertiesManager.mapboxApiKey).thenReturn("");

    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.lib.subscriptionManager.isPro).thenReturn(true);
    when(
      managers.lib.subscriptionManager.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(managers.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(
      managers.userPreferenceManager.isTrackingFishingSpots,
    ).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(
      managers.userPreferenceManager.isTrackingWaterClarities,
    ).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingGear).thenReturn(true);
    when(managers.userPreferenceManager.didOnboard).thenReturn(true);
    when(managers.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.selectedReportId).thenReturn(null);
    when(
      managers.userPreferenceManager.setSelectedReportId(any),
    ).thenAnswer((_) => Future.value());
    when(
      managers.userPreferenceManager.setWaterDepthSystem(any),
    ).thenAnswer((_) => Future.value());
    when(
      managers.userPreferenceManager.waterDepthSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.setWaterTemperatureSystem(any),
    ).thenAnswer((_) => Future.value());
    when(
      managers.userPreferenceManager.waterTemperatureSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.setCatchLengthSystem(any),
    ).thenAnswer((_) => Future.value());
    when(
      managers.userPreferenceManager.catchLengthSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.setCatchWeightSystem(any),
    ).thenAnswer((_) => Future.value());
    when(
      managers.userPreferenceManager.catchWeightSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(managers.userPreferenceManager.autoFetchAtmosphere).thenReturn(false);
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.userPreferenceManager.mapType).thenReturn(null);
    when(managers.userPreferenceManager.themeMode).thenReturn(ThemeMode.light);
    when(managers.userPreferenceManager.autoFetchTide).thenReturn(false);
    when(managers.userPreferenceManager.autoBackup).thenReturn(false);
    when(managers.userPreferenceManager.tripFieldIds).thenReturn([]);

    when(
      managers.lib.timeManager.currentDateTime,
    ).thenReturn(dateTime(2020, 1, 1));

    when(managers.tripManager.list()).thenReturn([]);
    when(
      managers.tripManager.listen(any),
    ).thenAnswer((_) => MockStreamSubscription());

    var channel = MockMethodChannel();
    when(channel.invokeMethod(any)).thenAnswer((_) => Future.value(null));
    when(managers.servicesWrapper.methodChannel(any)).thenReturn(channel);
  });

  testWidgets("LandingPage is shown until app initializes", (tester) async {
    // Stub an initialization method taking some time.
    when(managers.locationMonitor.initialize()).thenAnswer(
      (_) => Future.delayed(const Duration(milliseconds: 50), () => true),
    );
    when(managers.userPreferenceManager.didOnboard).thenReturn(false);

    await tester.pumpWidget(const AnglersLog());

    expect(find.byType(LandingPage), findsOneWidget);
    expect(find.byType(OnboardingJourney), findsNothing);
    expect(find.byType(MainPage), findsNothing);

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 210));

    expect(find.byType(LandingPage), findsNothing);
    expect(find.byType(OnboardingJourney), findsOneWidget);
    expect(find.byType(MainPage), findsNothing);
  });

  testWidgets("App initialization throws an error", (tester) async {
    when(managers.app.init()).thenThrow(LocationNotFoundException(""));

    await tester.pumpWidget(const AnglersLog());

    expect(find.byType(LandingPage), findsOneWidget);
    expect(
      find.text(
        "Uh oh! Something went wrong during initialization. The Test App team has been notified, and we apologize for the inconvenience.",
      ),
      findsNothing,
    );
    expect(find.byType(OnboardingJourney), findsNothing);
    expect(find.byType(MainPage), findsNothing);

    // Wait for initialization future + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 205));

    expect(
      find.text(
        "Uh oh! Something went wrong during initialization. The Test App team has been notified, and we apologize for the inconvenience.",
      ),
      findsOneWidget,
    );
    expect(find.byType(OnboardingJourney), findsNothing);
    expect(find.byType(MainPage), findsNothing);

    verify(
      managers.lib.crashlyticsWrapper.recordError(
        any,
        any,
        reason: anyNamed("reason"),
        fatal: anyNamed("fatal"),
      ),
    ).called(1);
  });

  testWidgets("Preferences is updated only after onboarding finishes", (
    tester,
  ) async {
    // Stub an initialization method taking some time.
    when(managers.locationMonitor.initialize()).thenAnswer(
      (_) => Future.delayed(const Duration(milliseconds: 50), () => true),
    );
    when(managers.userPreferenceManager.didOnboard).thenReturn(false);
    when(
      managers.userPreferenceManager.updateAppVersion(),
    ).thenAnswer((_) => Future.value());
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.lib.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.lib.permissionHandlerWrapper.requestLocation(),
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.lib.permissionHandlerWrapper.requestLocationAlways(),
    ).thenAnswer((_) => Future.value(false));
    when(managers.fishingSpotManager.list()).thenReturn([]);
    when(
      managers.catchManager.catches(
        any,
        filter: anyNamed("filter"),
        opt: anyNamed("opt"),
      ),
    ).thenReturn([]);
    when(managers.customEntityManager.entityExists(any)).thenReturn(false);
    when(
      managers.baitManager.attachmentsDisplayValues(any, any),
    ).thenReturn([]);
    when(managers.anglerManager.entityExists(any)).thenReturn(false);
    when(managers.speciesManager.entityExists(any)).thenReturn(false);
    when(managers.waterClarityManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(const AnglersLog());

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(OnboardingJourney), findsOneWidget);
    expect(find.byType(MainPage), findsNothing);
    verifyNever(managers.userPreferenceManager.setDidOnboard(true));

    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("SET PERMISSION"));
    await tapAndSettle(tester, find.text("CANCEL"));
    await tapAndSettle(tester, find.text("FINISH"));

    verify(managers.userPreferenceManager.setDidOnboard(true)).called(1);

    // Wait for futures to finish..
    await tester.pump(const Duration(milliseconds: 250));
  });

  testWidgets("Main page shown", (tester) async {
    when(managers.userPreferenceManager.didOnboard).thenReturn(true);
    when(managers.userPreferenceManager.appVersion).thenReturn("2.0.0");
    when(managers.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "1.0.0",
          packageName: "test.com",
        ),
      ),
    );
    when(managers.fishingSpotManager.list()).thenReturn([]);
    when(
      managers.catchManager.catches(
        any,
        filter: anyNamed("filter"),
        opt: anyNamed("opt"),
      ),
    ).thenReturn([]);

    await tester.pumpWidget(const AnglersLog());
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.byType(OnboardingJourney), findsNothing);
    expect(find.byType(MainPage), findsOneWidget);
  });

  testWidgets("Legacy JSON is fetched if the user hasn't yet onboarded", (
    tester,
  ) async {
    // Stub an initialization method taking some time.
    when(managers.locationMonitor.initialize()).thenAnswer(
      (_) => Future.delayed(const Duration(milliseconds: 50), () => true),
    );
    when(managers.userPreferenceManager.didOnboard).thenReturn(false);

    var channel = MockMethodChannel();
    when(
      channel.invokeMethod(any),
    ).thenAnswer((_) => Future.value({"db": "test/db"}));
    when(managers.servicesWrapper.methodChannel(any)).thenReturn(channel);
    await tester.pumpWidget(const AnglersLog());

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 210));

    verify(managers.servicesWrapper.methodChannel(any)).called(1);
    var onboardingJourney = findFirst<OnboardingJourney>(tester);
    expect(onboardingJourney.legacyJsonResult, isNotNull);
  });

  testWidgets("Show change log page with lower old version", (tester) async {
    when(managers.userPreferenceManager.didOnboard).thenReturn(true);
    when(managers.userPreferenceManager.appVersion).thenReturn("1.0.0");
    when(managers.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.0.0",
          packageName: "test.com",
        ),
      ),
    );

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(ChangeLogPage), findsOneWidget);
    expect(find.byType(OnboardingJourney), findsNothing);
    expect(find.byType(MainPage), findsNothing);
    verifyNever(managers.userPreferenceManager.setTripFieldIds(any));
  });

  testWidgets("Show change log page with empty old version", (tester) async {
    when(managers.userPreferenceManager.didOnboard).thenReturn(true);
    when(managers.userPreferenceManager.appVersion).thenReturn(null);
    when(managers.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.0.0",
          packageName: "test.com",
        ),
      ),
    );

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(ChangeLogPage), findsOneWidget);
    expect(find.byType(OnboardingJourney), findsNothing);
    expect(find.byType(MainPage), findsNothing);
    verifyNever(managers.userPreferenceManager.setTripFieldIds(any));
  });

  testWidgets("Trip field IDs do not update if empty updating from 2.2.0", (
    tester,
  ) async {
    when(managers.userPreferenceManager.didOnboard).thenReturn(true);
    when(managers.userPreferenceManager.appVersion).thenReturn("2.2.0");
    when(
      managers.userPreferenceManager.setTripFieldIds(any),
    ).thenAnswer((_) => Future.value());
    when(managers.userPreferenceManager.tripFieldIds).thenReturn([]);
    when(managers.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.3.0",
          packageName: "test.com",
        ),
      ),
    );

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    verifyNever(managers.userPreferenceManager.setTripFieldIds(any));
  });

  testWidgets("UserPreferenceManager listener", (tester) async {
    // Stub AppManager so MainPage is shown. This is the path that uses
    // ThemeMode from UserPreferenceManager.
    when(managers.userPreferenceManager.didOnboard).thenReturn(true);
    when(managers.userPreferenceManager.appVersion).thenReturn("2.0.0");
    when(managers.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "1.0.0",
          packageName: "test.com",
        ),
      ),
    );
    when(managers.fishingSpotManager.list()).thenReturn([]);
    when(
      managers.catchManager.catches(
        any,
        filter: anyNamed("filter"),
        opt: anyNamed("opt"),
      ),
    ).thenReturn([]);

    var controller = StreamController<String>.broadcast();
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => controller.stream);

    await pumpContext(tester, (_) => const AnglersLog());
    await tester.pump(const Duration(milliseconds: 300));

    // Verify default theme.
    var app = findLast<MaterialApp>(tester);
    expect(app.themeMode, ThemeMode.system);

    // Trigger preference change, and verify theme didn't change.
    controller.add("not a real event");
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    app = findLast<MaterialApp>(tester);
    expect(app.themeMode, ThemeMode.system);

    // Trigger theme change.
    when(managers.lib.appConfig.themeMode).thenReturn(() => ThemeMode.dark);
    controller.add(UserPreferenceManager.keyThemeMode);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    app = findLast<MaterialApp>(tester);
    expect(app.themeMode, ThemeMode.dark);
  });

  // ignore_for_file: deprecated_member_use_from_same_package
  testWidgets("Migrate tide from 2.6 to 2.7", (tester) async {
    when(managers.userPreferenceManager.didOnboard).thenReturn(true);
    when(managers.userPreferenceManager.appVersion).thenReturn("2.6.0");
    when(managers.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.0",
          packageName: "test.com",
        ),
      ),
    );
    when(managers.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.tripFieldIds).thenReturn([]);

    var cat = Catch(
      id: randomId(),
      tide: Tide(
        firstLowTimestamp: Int64(5000),
        firstHighTimestamp: Int64(10000),
        secondLowTimestamp: Int64(15000),
        secondHighTimestamp: Int64(20000),
      ),
    );
    when(managers.catchManager.list()).thenReturn([cat, Catch(id: randomId())]);
    when(
      managers.catchManager.addOrUpdate(any, setImages: anyNamed("setImages")),
    ).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    var result = verify(
      managers.catchManager.addOrUpdate(
        captureAny,
        setImages: anyNamed("setImages"),
      ),
    );
    result.called(1);

    Catch capturedCatch = result.captured.first;
    expect(capturedCatch.hasTide(), isTrue);
    expect(capturedCatch.tide.firstLowHeight.timestamp.toInt(), 5000);
    expect(capturedCatch.tide.firstHighHeight.timestamp.toInt(), 10000);
    expect(capturedCatch.tide.secondLowHeight.timestamp.toInt(), 15000);
    expect(capturedCatch.tide.secondHighHeight.timestamp.toInt(), 20000);
    expect(capturedCatch.tide.hasFirstLowTimestamp(), isFalse);
    expect(capturedCatch.tide.hasFirstHighTimestamp(), isFalse);
    expect(capturedCatch.tide.hasSecondLowTimestamp(), isFalse);
    expect(capturedCatch.tide.hasSecondLowTimestamp(), isFalse);
  });

  testWidgets("Include photo field for bait variants when updating to 2.7", (
    tester,
  ) async {
    when(managers.userPreferenceManager.didOnboard).thenReturn(true);
    when(managers.userPreferenceManager.appVersion).thenReturn("2.6.0");
    when(managers.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.0",
          packageName: "test.com",
        ),
      ),
    );
    when(
      managers.userPreferenceManager.baitVariantFieldIds,
    ).thenReturn([randomId()]);
    when(managers.catchManager.list()).thenReturn([]);

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    // Photo field is shown for bait variants.
    var result = verify(
      managers.userPreferenceManager.setBaitVariantFieldIds(captureAny),
    );
    result.called(1);
    List<Id> ids = result.captured.first;
    expect(ids.contains(SaveBaitVariantPageState.imageFieldId), isTrue);
  });

  testWidgets("Bait variant fields not set when updating from 2.7+", (
    tester,
  ) async {
    when(managers.userPreferenceManager.didOnboard).thenReturn(true);
    when(managers.userPreferenceManager.appVersion).thenReturn("2.7.0");
    when(managers.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.1",
          packageName: "test.com",
        ),
      ),
    );
    when(
      managers.userPreferenceManager.baitVariantFieldIds,
    ).thenReturn([randomId()]);
    when(managers.catchManager.list()).thenReturn([]);

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    verifyNever(managers.userPreferenceManager.setBaitVariantFieldIds(any));
  });

  testWidgets("Bait variant fields not set when prefs is empty", (
    tester,
  ) async {
    when(managers.userPreferenceManager.didOnboard).thenReturn(true);
    when(managers.userPreferenceManager.appVersion).thenReturn("2.7.0");
    when(managers.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.1",
          packageName: "test.com",
        ),
      ),
    );
    when(managers.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(managers.catchManager.list()).thenReturn([]);

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    verifyNever(managers.userPreferenceManager.setBaitVariantFieldIds(any));
  });

  testWidgets("Include water fields for trips when updating to 2.7", (
    tester,
  ) async {
    when(managers.userPreferenceManager.didOnboard).thenReturn(true);
    when(managers.userPreferenceManager.appVersion).thenReturn("2.6.0");
    when(managers.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.0",
          packageName: "test.com",
        ),
      ),
    );
    when(managers.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.tripFieldIds).thenReturn([randomId()]);
    when(managers.catchManager.list()).thenReturn([]);

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    // Photo field is shown for bait variants.
    var result = verify(
      managers.userPreferenceManager.setTripFieldIds(captureAny),
    );
    result.called(1);
    List<Id> ids = result.captured.first;
    expect(ids.contains(tripFieldIdWaterClarity), isTrue);
    expect(ids.contains(tripFieldIdWaterDepth), isTrue);
    expect(ids.contains(tripFieldIdWaterTemperature), isTrue);
  });

  testWidgets("Trip fields not set when updating from 2.7+", (tester) async {
    when(managers.userPreferenceManager.didOnboard).thenReturn(true);
    when(managers.userPreferenceManager.appVersion).thenReturn("2.7.0");
    when(managers.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.1",
          packageName: "test.com",
        ),
      ),
    );
    when(managers.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.tripFieldIds).thenReturn([randomId()]);
    when(managers.catchManager.list()).thenReturn([]);

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    verifyNever(managers.userPreferenceManager.setTripFieldIds(any));
  });

  testWidgets("Trip fields not set when prefs is empty", (tester) async {
    when(managers.userPreferenceManager.didOnboard).thenReturn(true);
    when(managers.userPreferenceManager.appVersion).thenReturn("2.7.0");
    when(managers.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.1",
          packageName: "test.com",
        ),
      ),
    );
    when(managers.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.tripFieldIds).thenReturn([]);
    when(managers.catchManager.list()).thenReturn([]);

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    verifyNever(managers.userPreferenceManager.setTripFieldIds(any));
  });

  testWidgets("Update water temperature systems", (tester) async {
    when(managers.userPreferenceManager.didOnboard).thenReturn(true);
    when(managers.userPreferenceManager.appVersion).thenReturn("2.7.4");
    when(managers.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.5",
          packageName: "test.com",
        ),
      ),
    );
    when(
      managers.userPreferenceManager.waterTemperatureSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(managers.catchManager.list()).thenReturn([
      Catch(
        waterTemperature: MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
        ),
      ),
      Catch(
        waterTemperature: MultiMeasurement(system: MeasurementSystem.metric),
      ),
      Catch(
        waterTemperature: MultiMeasurement(
          system: MeasurementSystem.imperial_decimal,
        ),
      ),
      Catch(
        waterTemperature: MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
        ),
      ),
    ]);
    when(
      managers.catchManager.addOrUpdate(any, setImages: false),
    ).thenAnswer((_) => Future.value(true));
    when(managers.tripManager.list()).thenReturn([
      Trip(
        waterTemperature: MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
        ),
      ),
      Trip(
        waterTemperature: MultiMeasurement(system: MeasurementSystem.metric),
      ),
      Trip(
        waterTemperature: MultiMeasurement(
          system: MeasurementSystem.imperial_decimal,
        ),
      ),
      Trip(
        waterTemperature: MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
        ),
      ),
    ]);
    when(
      managers.tripManager.addOrUpdate(any, setImages: false),
    ).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    verify(
      managers.userPreferenceManager.setWaterTemperatureSystem(
        MeasurementSystem.imperial_decimal,
      ),
    ).called(1);

    var result = verify(
      managers.catchManager.addOrUpdate(captureAny, setImages: false),
    );
    result.called(2);
    expect(
      (result.captured.first as Catch).waterTemperature.system,
      MeasurementSystem.imperial_decimal,
    );
    expect(
      (result.captured.last as Catch).waterTemperature.system,
      MeasurementSystem.imperial_decimal,
    );

    result = verify(
      managers.tripManager.addOrUpdate(captureAny, setImages: false),
    );
    result.called(2);
    expect(
      (result.captured.first as Trip).waterTemperature.system,
      MeasurementSystem.imperial_decimal,
    );
    expect(
      (result.captured.last as Trip).waterTemperature.system,
      MeasurementSystem.imperial_decimal,
    );
  });

  testWidgets("Translation warning page is shown", (tester) async {
    when(
      managers.userPreferenceManager.didShowTranslationWarning,
    ).thenReturn(false);
    when(managers.userPreferenceManager.didOnboard).thenReturn(false);

    await tester.pumpWidget(const AnglersLog(locale: Locale("es")));
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(TranslationWarningPage), findsOneWidget);

    await tester.tap(find.text("Está bien".toUpperCase()));
    verify(
      managers.userPreferenceManager.setDidShowTranslationWarning(true),
    ).called(1);
    when(
      managers.userPreferenceManager.didShowTranslationWarning,
    ).thenReturn(true);

    // Verify set state is updated and the next page is shown.
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(OnboardingJourney), findsOneWidget);
  });

  testWidgets("Translation warning page is not shown for English", (
    tester,
  ) async {
    when(
      managers.userPreferenceManager.didShowTranslationWarning,
    ).thenReturn(false);
    when(managers.userPreferenceManager.didOnboard).thenReturn(false);

    await tester.pumpWidget(const AnglersLog(locale: Locale("en")));
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(TranslationWarningPage), findsNothing);
  });

  testWidgets("Translation warning page is not shown again", (tester) async {
    when(
      managers.userPreferenceManager.didShowTranslationWarning,
    ).thenReturn(true);
    when(managers.userPreferenceManager.didOnboard).thenReturn(false);

    await tester.pumpWidget(const AnglersLog(locale: Locale("es")));
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(TranslationWarningPage), findsNothing);
  });
}
