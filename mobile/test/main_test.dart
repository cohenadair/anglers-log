import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/landing_page.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/onboarding/change_log_page.dart';
import 'package:mobile/pages/onboarding/onboarding_journey.dart';
import 'package:mobile/pages/save_bait_variant_page.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/trip_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.backupRestoreManager.progressStream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.backupRestoreManager.hasLastProgressError)
        .thenReturn(false);

    when(appManager.catchManager.hasEntities).thenReturn(false);
    when(appManager.catchManager.list()).thenReturn([]);
    when(appManager.catchManager.listen(any))
        .thenAnswer((_) => MockStreamSubscription());

    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    when(appManager.gpsTrailManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.gpsTrailManager.hasActiveTrail).thenReturn(false);
    when(appManager.gpsTrailManager.activeTrial).thenReturn(null);

    when(appManager.ioWrapper.isAndroid).thenReturn(false);
    when(appManager.ioWrapper.isIOS).thenReturn(true);

    when(appManager.reportManager.entityExists(any)).thenReturn(false);
    when(appManager.reportManager.defaultReport).thenReturn(Report());
    when(appManager.reportManager.displayName(any, any)).thenReturn("Test");

    when(appManager.locationMonitor.currentLatLng).thenReturn(null);

    when(appManager.notificationManager.stream)
        .thenAnswer((_) => const Stream.empty());

    when(appManager.pollManager.canVote).thenReturn(false);
    when(appManager.pollManager.stream).thenAnswer((_) => const Stream.empty());

    when(appManager.propertiesManager.mapboxApiKey).thenReturn("");

    when(appManager.subscriptionManager.isFree).thenReturn(false);
    when(appManager.subscriptionManager.isPro).thenReturn(true);
    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());

    when(appManager.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingGear).thenReturn(true);
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
    when(appManager.userPreferenceManager.mapType).thenReturn(null);
    when(appManager.userPreferenceManager.themeMode)
        .thenReturn(ThemeMode.light);
    when(appManager.userPreferenceManager.autoFetchTide).thenReturn(false);
    when(appManager.userPreferenceManager.autoBackup).thenReturn(false);
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([]);

    when(appManager.timeManager.currentDateTime)
        .thenReturn(dateTime(2020, 1, 1));

    when(appManager.tripManager.list()).thenReturn([]);
    when(appManager.tripManager.listen(any))
        .thenAnswer((_) => MockStreamSubscription());

    var channel = MockMethodChannel();
    when(channel.invokeMethod(any)).thenAnswer((_) => Future.value(null));
    when(appManager.servicesWrapper.methodChannel(any)).thenReturn(channel);
  });

  testWidgets("LandingPage is shown until app initializes", (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.locationMonitor.initialize()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => true));
    when(appManager.userPreferenceManager.didOnboard).thenReturn(false);

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

  testWidgets("Preferences is updated only after onboarding finishes",
      (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.locationMonitor.initialize()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => true));
    when(appManager.userPreferenceManager.didOnboard).thenReturn(false);
    when(appManager.userPreferenceManager.updateAppVersion())
        .thenAnswer((_) => Future.value());
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.requestLocationAlways())
        .thenAnswer((_) => Future.value(false));
    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([]);
    when(appManager.customEntityManager.entityExists(any)).thenReturn(false);
    when(appManager.baitManager.attachmentsDisplayValues(any, any))
        .thenReturn([]);
    when(appManager.anglerManager.entityExists(any)).thenReturn(false);
    when(appManager.speciesManager.entityExists(any)).thenReturn(false);
    when(appManager.waterClarityManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(const AnglersLog());

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(OnboardingJourney), findsOneWidget);
    expect(find.byType(MainPage), findsNothing);
    verifyNever(appManager.userPreferenceManager.setDidOnboard(true));

    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("SET PERMISSION"));
    await tapAndSettle(tester, find.text("CANCEL"));
    await tapAndSettle(tester, find.text("FINISH"));

    verify(appManager.userPreferenceManager.setDidOnboard(true)).called(1);

    // Wait for futures to finish..
    await tester.pump(const Duration(milliseconds: 250));
  });

  testWidgets("Main page shown", (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn("2.0.0");
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "1.0.0",
          packageName: "test.com",
        ),
      ),
    );
    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([]);

    await tester.pumpWidget(const AnglersLog());
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.byType(OnboardingJourney), findsNothing);
    expect(find.byType(MainPage), findsOneWidget);
  });

  testWidgets("Legacy JSON is fetched if the user hasn't yet onboarded",
      (tester) async {
    // Stub an initialization method taking some time.
    when(appManager.locationMonitor.initialize()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => true));
    when(appManager.userPreferenceManager.didOnboard).thenReturn(false);

    var channel = MockMethodChannel();
    when(channel.invokeMethod(any)).thenAnswer(
      (_) => Future.value({
        "db": "test/db",
      }),
    );
    when(appManager.servicesWrapper.methodChannel(any)).thenReturn(channel);
    await tester.pumpWidget(const AnglersLog());

    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 210));

    verify(appManager.servicesWrapper.methodChannel(any)).called(1);
    var onboardingJourney = findFirst<OnboardingJourney>(tester);
    expect(onboardingJourney.legacyJsonResult, isNotNull);
  });

  testWidgets("Show change log page with lower old version", (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn("1.0.0");
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
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
    verifyNever(appManager.userPreferenceManager.setTripFieldIds(any));
  });

  testWidgets("Show change log page with empty old version", (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn(null);
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
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
    verifyNever(appManager.userPreferenceManager.setTripFieldIds(any));
  });

  testWidgets("Trip field IDs do not update if empty updating from 2.2.0",
      (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn("2.2.0");
    when(appManager.userPreferenceManager.setTripFieldIds(any))
        .thenAnswer((_) => Future.value());
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([]);
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
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

    verifyNever(appManager.userPreferenceManager.setTripFieldIds(any));
  });

  testWidgets("UserPreferenceManager listener", (tester) async {
    // Stub AppManager so MainPage is shown. This is the path that uses
    // ThemeMode from UserPreferenceManager.
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn("2.0.0");
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "1.0.0",
          packageName: "test.com",
        ),
      ),
    );
    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([]);

    var controller = StreamController<String>.broadcast();
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => controller.stream);

    await pumpContext(
      tester,
      (_) => const AnglersLog(),
      appManager: appManager,
    );
    await tester.pump(const Duration(milliseconds: 300));

    // Verify default theme.
    var app = findLast<MaterialApp>(tester);
    expect(app.themeMode, ThemeMode.light);

    // Trigger preference change, and verify theme didn't change.
    controller.add("not a real event");
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    app = findLast<MaterialApp>(tester);
    expect(app.themeMode, ThemeMode.light);

    // Trigger theme change.
    when(appManager.userPreferenceManager.themeMode).thenReturn(ThemeMode.dark);
    controller.add(UserPreferenceManager.keyThemeMode);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    app = findLast<MaterialApp>(tester);
    expect(app.themeMode, ThemeMode.dark);
  });

  // ignore_for_file: deprecated_member_use_from_same_package
  testWidgets("Migrate tide from 2.6 to 2.7", (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn("2.6.0");
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.0",
          packageName: "test.com",
        ),
      ),
    );
    when(appManager.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([]);

    var cat = Catch(
      id: randomId(),
      tide: Tide(
        firstLowTimestamp: Int64(5000),
        firstHighTimestamp: Int64(10000),
        secondLowTimestamp: Int64(15000),
        secondHighTimestamp: Int64(20000),
      ),
    );
    when(appManager.catchManager.list()).thenReturn([
      cat,
      Catch(id: randomId()),
    ]);
    when(appManager.catchManager.addOrUpdate(
      any,
      setImages: anyNamed("setImages"),
    )).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    var result = verify(appManager.catchManager.addOrUpdate(
      captureAny,
      setImages: anyNamed("setImages"),
    ));
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

  testWidgets("Include photo field for bait variants when updating to 2.7",
      (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn("2.6.0");
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.0",
          packageName: "test.com",
        ),
      ),
    );
    when(appManager.userPreferenceManager.baitVariantFieldIds)
        .thenReturn([randomId()]);
    when(appManager.catchManager.list()).thenReturn([]);

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    // Photo field is shown for bait variants.
    var result = verify(
        appManager.userPreferenceManager.setBaitVariantFieldIds(captureAny));
    result.called(1);
    List<Id> ids = result.captured.first;
    expect(ids.contains(SaveBaitVariantPageState.imageFieldId), isTrue);
  });

  testWidgets("Bait variant fields not set when updating from 2.7+",
      (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn("2.7.0");
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.1",
          packageName: "test.com",
        ),
      ),
    );
    when(appManager.userPreferenceManager.baitVariantFieldIds)
        .thenReturn([randomId()]);
    when(appManager.catchManager.list()).thenReturn([]);

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    verifyNever(appManager.userPreferenceManager.setBaitVariantFieldIds(any));
  });

  testWidgets("Bait variant fields not set when prefs is empty",
      (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn("2.7.0");
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.1",
          packageName: "test.com",
        ),
      ),
    );
    when(appManager.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(appManager.catchManager.list()).thenReturn([]);

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    verifyNever(appManager.userPreferenceManager.setBaitVariantFieldIds(any));
  });

  testWidgets("Include water fields for trips when updating to 2.7",
      (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn("2.6.0");
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.0",
          packageName: "test.com",
        ),
      ),
    );
    when(appManager.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.tripFieldIds)
        .thenReturn([randomId()]);
    when(appManager.catchManager.list()).thenReturn([]);

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    // Photo field is shown for bait variants.
    var result =
        verify(appManager.userPreferenceManager.setTripFieldIds(captureAny));
    result.called(1);
    List<Id> ids = result.captured.first;
    expect(ids.contains(tripFieldIdWaterClarity), isTrue);
    expect(ids.contains(tripFieldIdWaterDepth), isTrue);
    expect(ids.contains(tripFieldIdWaterTemperature), isTrue);
  });

  testWidgets("Trip fields not set when updating from 2.7+", (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn("2.7.0");
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.1",
          packageName: "test.com",
        ),
      ),
    );
    when(appManager.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.tripFieldIds)
        .thenReturn([randomId()]);
    when(appManager.catchManager.list()).thenReturn([]);

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    verifyNever(appManager.userPreferenceManager.setTripFieldIds(any));
  });

  testWidgets("Trip fields not set when prefs is empty", (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn("2.7.0");
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.1",
          packageName: "test.com",
        ),
      ),
    );
    when(appManager.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([]);
    when(appManager.catchManager.list()).thenReturn([]);

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    verifyNever(appManager.userPreferenceManager.setTripFieldIds(any));
  });

  testWidgets("Update water temperature systems", (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn("2.7.4");
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.7.5",
          packageName: "test.com",
        ),
      ),
    );
    when(appManager.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.catchManager.list()).thenReturn([
      Catch(
        waterTemperature: MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
        ),
      ),
      Catch(
        waterTemperature: MultiMeasurement(
          system: MeasurementSystem.metric,
        ),
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
    when(appManager.catchManager.addOrUpdate(
      any,
      setImages: false,
    )).thenAnswer((_) => Future.value(true));
    when(appManager.tripManager.list()).thenReturn([
      Trip(
        waterTemperature: MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
        ),
      ),
      Trip(
        waterTemperature: MultiMeasurement(
          system: MeasurementSystem.metric,
        ),
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
    when(appManager.tripManager.addOrUpdate(
      any,
      setImages: false,
    )).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(const AnglersLog());
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    verify(appManager.userPreferenceManager
            .setWaterTemperatureSystem(MeasurementSystem.imperial_decimal))
        .called(1);

    var result = verify(
        appManager.catchManager.addOrUpdate(captureAny, setImages: false));
    result.called(2);
    expect((result.captured.first as Catch).waterTemperature.system,
        MeasurementSystem.imperial_decimal);
    expect((result.captured.last as Catch).waterTemperature.system,
        MeasurementSystem.imperial_decimal);

    result = verify(
        appManager.tripManager.addOrUpdate(captureAny, setImages: false));
    result.called(2);
    expect((result.captured.first as Trip).waterTemperature.system,
        MeasurementSystem.imperial_decimal);
    expect((result.captured.last as Trip).waterTemperature.system,
        MeasurementSystem.imperial_decimal);
  });
}
