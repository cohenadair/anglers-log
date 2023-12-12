import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/landing_page.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/onboarding/change_log_page.dart';
import 'package:mobile/pages/onboarding/onboarding_journey.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.catchManager.hasEntities).thenReturn(false);
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

    when(appManager.timeManager.currentDateTime)
        .thenReturn(dateTime(2020, 1, 1));

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

    await tester.pumpWidget(AnglersLog(appManager.app));

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

    await tester.pumpWidget(AnglersLog(appManager.app));

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

    await tester.pumpWidget(AnglersLog(appManager.app));
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
    await tester.pumpWidget(AnglersLog(appManager.app));

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

    await tester.pumpWidget(AnglersLog(appManager.app));
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

    await tester.pumpWidget(AnglersLog(appManager.app));
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

    await tester.pumpWidget(AnglersLog(appManager.app));
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    verifyNever(appManager.userPreferenceManager.setTripFieldIds(any));
  });

  testWidgets("Update trip field IDs when updating from 2.2.0", (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn("2.2.0");
    when(appManager.userPreferenceManager.setTripFieldIds(any))
        .thenAnswer((_) => Future.value());
    when(appManager.userPreferenceManager.tripFieldIds)
        .thenReturn([randomId()]);
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

    await tester.pumpWidget(AnglersLog(appManager.app));
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    verify(appManager.userPreferenceManager.setTripFieldIds(any)).called(1);
  });

  testWidgets("Clear map type when updating to 2.3.5 and type is not satellite",
      (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn("2.3.4");
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.3.5",
          packageName: "test.com",
        ),
      ),
    );
    when(appManager.userPreferenceManager.mapType).thenReturn(MapType.light.id);

    await tester.pumpWidget(AnglersLog(appManager.app));
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    verify(appManager.userPreferenceManager.setMapType(null)).called(1);
  });

  testWidgets(
      "Don't clear map type when updating to 2.3.5 if type is satellite",
      (tester) async {
    when(appManager.userPreferenceManager.didOnboard).thenReturn(true);
    when(appManager.userPreferenceManager.appVersion).thenReturn("2.3.4");
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.3.5",
          packageName: "test.com",
        ),
      ),
    );
    when(appManager.userPreferenceManager.mapType)
        .thenReturn(MapType.satellite.id);

    await tester.pumpWidget(AnglersLog(appManager.app));
    // Wait for delayed initialization + AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 200));

    verify(appManager.userPreferenceManager.mapType).called(1);
    verifyNever(appManager.userPreferenceManager.setMapType(any));
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
      (_) => AnglersLog(appManager.app),
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
}
