import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_app_manager.dart';

void main() {
  late StubbedAppManager appManager;
  late LocationMonitor locationMonitor;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.ioWrapper.isIOS).thenReturn(true);
    when(appManager.permissionHandlerWrapper.requestNotification())
        .thenAnswer((_) => Future.value(true));

    when(appManager.geolocatorWrapper.getLastKnownPosition())
        .thenAnswer((_) => Future.value(Position(
              altitudeAccuracy: 0,
              speedAccuracy: 0,
              headingAccuracy: 0,
              speed: 0,
              altitude: 0,
              accuracy: 0,
              latitude: 0,
              timestamp: DateTime.now(),
              heading: 0,
              longitude: 0,
            )));
    when(appManager.geolocatorWrapper.getPositionStream(
      locationSettings: anyNamed("locationSettings"),
    )).thenAnswer((_) => const Stream.empty());

    locationMonitor = LocationMonitor(appManager.app);
  });

  test("initialize exists early if already initialized", () async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(true));

    await locationMonitor.initialize();
    verify(appManager.geolocatorWrapper.getLastKnownPosition()).called(1);

    await locationMonitor.initialize();
    verifyNever(appManager.geolocatorWrapper.getLastKnownPosition());
  });

  test("initialize exists early if permission is not granted", () async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(false));

    await locationMonitor.initialize();
    verifyNever(appManager.geolocatorWrapper.getLastKnownPosition());
  });

  test("Location changed exits early", () async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(true));

    var controller = StreamController<Position>.broadcast();
    when(appManager.geolocatorWrapper.getPositionStream(
      locationSettings: anyNamed("locationSettings"),
    )).thenAnswer((_) => controller.stream);

    await locationMonitor.initialize();

    // Stream should only add one event.
    locationMonitor.stream.listen(expectAsync1((_) => true, count: 1));

    controller.add(Position.fromMap({
      "latitude": 0.0,
      "longitude": 0.0,
    }));
    controller.add(Position.fromMap({
      "latitude": 5.0,
      "longitude": 8.0,
      "heading": 1.0,
    }));
  });

  test("Geocoder exceptions are handled", () async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(true));

    var controller = StreamController<Position>.broadcast(sync: true);
    when(appManager.geolocatorWrapper.getPositionStream(
      locationSettings: anyNamed("locationSettings"),
    )).thenAnswer((_) => controller.stream);

    await locationMonitor.initialize();
    controller.addError(const LocationServiceDisabledException());

    // The fact that the test passes (and doesn't fail via exception) means
    // the code was corrected.
  });

  test("enableBackgroundMode for iOS", () async {
    when(appManager.ioWrapper.isIOS).thenReturn(true);
    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    await locationMonitor.enableBackgroundMode("Test Notification");

    var result = verify(appManager.geolocatorWrapper.getPositionStream(
      locationSettings: captureAnyNamed("locationSettings"),
    ));
    result.called(1);

    var settings = result.captured.first as AppleSettings;
    expect(settings.showBackgroundLocationIndicator, isTrue);
    expect(settings.allowBackgroundLocationUpdates, isTrue);
    expect(settings.pauseLocationUpdatesAutomatically, isFalse);
  });

  test("enableBackgroundMode for Android", () async {
    when(appManager.ioWrapper.isIOS).thenReturn(false);
    when(appManager.ioWrapper.isAndroid).thenReturn(true);

    await locationMonitor.enableBackgroundMode("Test Notification");

    var result = verify(appManager.geolocatorWrapper.getPositionStream(
      locationSettings: captureAnyNamed("locationSettings"),
    ));
    result.called(1);
    verify(appManager.permissionHandlerWrapper.requestNotification()).called(1);

    var settings = result.captured.first as AndroidSettings;
    expect(settings.foregroundNotificationConfig, isNotNull);
    expect(
      settings.foregroundNotificationConfig!.notificationTitle,
      "Test Notification",
    );
  });

  test("disableBackgroundMode for iOS", () async {
    when(appManager.ioWrapper.isIOS).thenReturn(true);

    locationMonitor.disableBackgroundMode();

    var result = verify(appManager.geolocatorWrapper.getPositionStream(
      locationSettings: captureAnyNamed("locationSettings"),
    ));
    result.called(1);

    var settings = result.captured.first as AppleSettings;
    expect(settings.showBackgroundLocationIndicator, isFalse);
    expect(settings.allowBackgroundLocationUpdates, isFalse);
    expect(settings.pauseLocationUpdatesAutomatically, isTrue);
  });

  test("disableBackgroundMode for Android", () async {
    when(appManager.ioWrapper.isIOS).thenReturn(false);
    when(appManager.ioWrapper.isAndroid).thenReturn(true);

    locationMonitor.disableBackgroundMode();

    var result = verify(appManager.geolocatorWrapper.getPositionStream(
      locationSettings: captureAnyNamed("locationSettings"),
    ));
    result.called(1);

    var settings = result.captured.first as AndroidSettings;
    expect(settings.foregroundNotificationConfig, isNull);
  });
}
