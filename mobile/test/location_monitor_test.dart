import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;
  late LocationMonitor locationMonitor;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.ioWrapper.isIOS).thenReturn(true);
    when(
      managers.permissionHandlerWrapper.requestNotification(),
    ).thenAnswer((_) => Future.value(true));

    when(managers.geolocatorWrapper.getLastKnownPosition()).thenAnswer(
      (_) => Future.value(
        Position(
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
        ),
      ),
    );
    when(
      managers.geolocatorWrapper.getPositionStream(
        locationSettings: anyNamed("locationSettings"),
      ),
    ).thenAnswer((_) => const Stream.empty());

    locationMonitor = LocationMonitor(managers.app);
  });

  test("initialize exists early if already initialized", () async {
    when(
      managers.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(true));

    await locationMonitor.initialize();
    verify(managers.geolocatorWrapper.getLastKnownPosition()).called(1);

    await locationMonitor.initialize();
    verifyNever(managers.geolocatorWrapper.getLastKnownPosition());
  });

  test("initialize exists early if permission is not granted", () async {
    when(
      managers.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(false));

    await locationMonitor.initialize();
    verifyNever(managers.geolocatorWrapper.getLastKnownPosition());
  });

  test("Location changed exits early", () async {
    when(
      managers.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(true));

    var controller = StreamController<Position>.broadcast();
    when(
      managers.geolocatorWrapper.getPositionStream(
        locationSettings: anyNamed("locationSettings"),
      ),
    ).thenAnswer((_) => controller.stream);

    await locationMonitor.initialize();

    // Stream should only add one event.
    locationMonitor.stream.listen(expectAsync1((_) => true, count: 1));

    controller.add(Position.fromMap({"latitude": 0.0, "longitude": 0.0}));
    controller.add(
      Position.fromMap({"latitude": 5.0, "longitude": 8.0, "heading": 1.0}),
    );
  });

  test("Geocoder exceptions are handled", () async {
    when(
      managers.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(true));

    var controller = StreamController<Position>.broadcast(sync: true);
    when(
      managers.geolocatorWrapper.getPositionStream(
        locationSettings: anyNamed("locationSettings"),
      ),
    ).thenAnswer((_) => controller.stream);

    await locationMonitor.initialize();
    controller.addError(const LocationServiceDisabledException());

    // The fact that the test passes (and doesn't fail via exception) means
    // the code was corrected.
  });

  test("enableBackgroundMode for iOS", () async {
    when(managers.ioWrapper.isIOS).thenReturn(true);
    when(managers.ioWrapper.isAndroid).thenReturn(false);

    await locationMonitor.enableBackgroundMode("Test Notification");

    var result = verify(
      managers.geolocatorWrapper.getPositionStream(
        locationSettings: captureAnyNamed("locationSettings"),
      ),
    );
    result.called(1);

    var settings = result.captured.first as AppleSettings;
    expect(settings.showBackgroundLocationIndicator, isTrue);
    expect(settings.allowBackgroundLocationUpdates, isTrue);
    expect(settings.pauseLocationUpdatesAutomatically, isFalse);
  });

  test("enableBackgroundMode for Android", () async {
    when(managers.ioWrapper.isIOS).thenReturn(false);
    when(managers.ioWrapper.isAndroid).thenReturn(true);

    await locationMonitor.enableBackgroundMode("Test Notification");

    var result = verify(
      managers.geolocatorWrapper.getPositionStream(
        locationSettings: captureAnyNamed("locationSettings"),
      ),
    );
    result.called(1);
    verify(managers.permissionHandlerWrapper.requestNotification()).called(1);

    var settings = result.captured.first as AndroidSettings;
    expect(settings.foregroundNotificationConfig, isNotNull);
    expect(
      settings.foregroundNotificationConfig!.notificationTitle,
      "Test Notification",
    );
  });

  test("disableBackgroundMode for iOS", () async {
    when(managers.ioWrapper.isIOS).thenReturn(true);

    locationMonitor.disableBackgroundMode();

    var result = verify(
      managers.geolocatorWrapper.getPositionStream(
        locationSettings: captureAnyNamed("locationSettings"),
      ),
    );
    result.called(1);

    var settings = result.captured.first as AppleSettings;
    expect(settings.showBackgroundLocationIndicator, isFalse);
    expect(settings.allowBackgroundLocationUpdates, isFalse);
    expect(settings.pauseLocationUpdatesAutomatically, isTrue);
  });

  test("disableBackgroundMode for Android", () async {
    when(managers.ioWrapper.isIOS).thenReturn(false);
    when(managers.ioWrapper.isAndroid).thenReturn(true);

    locationMonitor.disableBackgroundMode();

    var result = verify(
      managers.geolocatorWrapper.getPositionStream(
        locationSettings: captureAnyNamed("locationSettings"),
      ),
    );
    result.called(1);

    var settings = result.captured.first as AndroidSettings;
    expect(settings.foregroundNotificationConfig, isNull);
  });
}
