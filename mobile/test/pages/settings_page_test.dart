import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/pages/settings_page.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.subscriptionManager.isPro).thenReturn(false);

    when(appManager.userPreferenceManager.autoFetchAtmosphere)
        .thenReturn(false);
    when(appManager.userPreferenceManager.autoFetchTide).thenReturn(false);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.userPreferenceManager.fishingSpotDistance).thenReturn(
      MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 20,
        ),
      ),
    );
    when(appManager.userPreferenceManager.minGpsTrailDistance)
        .thenReturn(MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.feet,
        value: 150,
      ),
    ));
  });

  testWidgets("Pro user sets auto fetch atmosphere", (tester) async {
    when(appManager.userPreferenceManager.autoFetchAtmosphere)
        .thenReturn(false);
    when(appManager.subscriptionManager.isPro).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => SettingsPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);

    var result = verify(
        appManager.userPreferenceManager.setAutoFetchAtmosphere(captureAny));
    result.called(1);

    bool autoFetch = result.captured.first;
    expect(autoFetch, isTrue);
  });

  testWidgets("Free user sets auto fetch atmosphere", (tester) async {
    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));
    when(appManager.userPreferenceManager.autoFetchAtmosphere)
        .thenReturn(false);
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => SettingsPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);

    var result = verify(
        appManager.userPreferenceManager.setAutoFetchAtmosphere(captureAny));
    result.called(1);

    bool autoFetch = result.captured.first;
    expect(autoFetch, isFalse);

    expect(find.byType(ProPage), findsOneWidget);
  });

  testWidgets("Pro user sets auto fetch tide", (tester) async {
    when(appManager.userPreferenceManager.autoFetchTide).thenReturn(false);
    when(appManager.subscriptionManager.isPro).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => SettingsPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byType(PaddedCheckbox).last);

    var result =
        verify(appManager.userPreferenceManager.setAutoFetchTide(captureAny));
    result.called(1);

    bool autoFetch = result.captured.first;
    expect(autoFetch, isTrue);
  });

  testWidgets("Free user sets auto fetch tide", (tester) async {
    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));
    when(appManager.userPreferenceManager.autoFetchTide).thenReturn(false);
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => SettingsPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byType(PaddedCheckbox).last);

    var result =
        verify(appManager.userPreferenceManager.setAutoFetchTide(captureAny));
    result.called(1);

    bool autoFetch = result.captured.first;
    expect(autoFetch, isFalse);

    expect(find.byType(ProPage), findsOneWidget);
  });

  testWidgets("User sets auto fetch atmosphere to false", (tester) async {
    when(appManager.userPreferenceManager.autoFetchAtmosphere).thenReturn(true);
    when(appManager.subscriptionManager.isPro).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => SettingsPage(),
      appManager: appManager,
    ));

    expect(findFirst<PaddedCheckbox>(tester).checked, isTrue);
    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);

    var result = verify(
        appManager.userPreferenceManager.setAutoFetchAtmosphere(captureAny));
    result.called(1);

    bool autoFetch = result.captured.first;
    expect(autoFetch, isFalse);

    expect(find.byType(ProPage), findsNothing);
  });

  testWidgets("Fishing spot distance updated in preferences", (tester) async {
    when(appManager.userPreferenceManager.setFishingSpotDistance(any))
        .thenAnswer((_) => Future.value());

    await tester.pumpWidget(Testable(
      (_) => SettingsPage(),
      appManager: appManager,
    ));

    await enterTextAndSettle(tester, find.text("20"), "50");

    var result = verify(
        appManager.userPreferenceManager.setFishingSpotDistance(captureAny));
    result.called(1);

    MultiMeasurement value = result.captured.first;
    expect(value.mainValue.value, 50);
  });

  testWidgets("GPS trail distance updated in preferences", (tester) async {
    when(appManager.userPreferenceManager.setMinGpsTrailDistance(any))
        .thenAnswer((_) => Future.value());

    await tester.pumpWidget(Testable(
      (_) => SettingsPage(),
      appManager: appManager,
    ));

    await enterTextAndSettle(tester, find.text("150"), "100");

    var result = verify(
        appManager.userPreferenceManager.setMinGpsTrailDistance(captureAny));
    result.called(1);

    MultiMeasurement value = result.captured.first;
    expect(value.mainValue.value, 100);
  });

  testWidgets("Picking dark theme updates preferences", (tester) async {
    when(appManager.userPreferenceManager.mapType).thenReturn(MapType.light.id);

    await pumpContext(tester, (_) => SettingsPage(), appManager: appManager);
    expect(find.text("Dark"), findsNothing);
    expect(find.text("Light"), findsOneWidget);

    await tapAndSettle(tester, find.text("Theme"));
    expect(find.text("Select Theme"), findsOneWidget);

    await tapAndSettle(tester, find.text("Dark"));
    expect(find.text("Select Theme"), findsNothing);

    verify(appManager.userPreferenceManager.setMapType(MapType.dark.id))
        .called(1);
    verify(appManager.userPreferenceManager.setThemeMode(ThemeMode.dark))
        .called(1);
  });

  testWidgets("Picking light theme updates preferences", (tester) async {
    when(appManager.userPreferenceManager.mapType).thenReturn(MapType.dark.id);

    await pumpContext(
      tester,
      (_) => SettingsPage(),
      appManager: appManager,
      themeMode: ThemeMode.dark,
    );
    expect(find.text("Dark"), findsOneWidget);
    expect(find.text("Light"), findsNothing);

    await tapAndSettle(tester, find.text("Theme"));
    expect(find.text("Select Theme"), findsOneWidget);

    await tapAndSettle(tester, find.text("Light"));
    expect(find.text("Select Theme"), findsNothing);

    verify(appManager.userPreferenceManager.setMapType(MapType.light.id))
        .called(1);
    verify(appManager.userPreferenceManager.setThemeMode(ThemeMode.light))
        .called(1);
  });

  testWidgets("Current theme is system", (tester) async {
    await pumpContext(
      tester,
      (_) => SettingsPage(),
      appManager: appManager,
      themeMode: ThemeMode.system,
    );
    expect(find.text("System"), findsOneWidget);
  });

  testWidgets("Picking a theme doesn't update preferences", (tester) async {
    when(appManager.userPreferenceManager.mapType)
        .thenReturn(MapType.satellite.id);

    await pumpContext(tester, (_) => SettingsPage(), appManager: appManager);
    expect(find.text("Dark"), findsNothing);
    expect(find.text("Light"), findsOneWidget);

    await tapAndSettle(tester, find.text("Theme"));
    expect(find.text("Select Theme"), findsOneWidget);

    await tapAndSettle(tester, find.text("Dark"));
    expect(find.text("Select Theme"), findsNothing);

    verifyNever(appManager.userPreferenceManager.setMapType(any));
    verify(appManager.userPreferenceManager.setThemeMode(ThemeMode.dark))
        .called(1);
  });
}
