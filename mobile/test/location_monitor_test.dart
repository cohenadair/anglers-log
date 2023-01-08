import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';

void main() {
  late StubbedAppManager appManager;
  late MockLocation location;
  late LocationMonitor locationMonitor;

  setUp(() {
    appManager = StubbedAppManager();

    location = MockLocation();
    when(location.changeSettings(distanceFilter: anyNamed("distanceFilter")))
        .thenAnswer((_) => Future.value(true));
    when(location.onLocationChanged).thenAnswer((_) => const Stream.empty());
    when(appManager.locationWrapper.newLocation()).thenReturn(location);

    when(appManager.geolocatorWrapper.getCurrentPosition())
        .thenAnswer((_) => Future.value(Position(
              speedAccuracy: 0,
              speed: 0,
              altitude: 0,
              accuracy: 0,
              latitude: 0,
              timestamp: DateTime.now(),
              heading: 0,
              longitude: 0,
            )));

    locationMonitor = LocationMonitor(appManager.app);
  });

  test("initialize exists early if already initialized", () async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(true));

    await locationMonitor.initialize();
    verify(location.onLocationChanged).called(1);

    await locationMonitor.initialize();
    verifyNever(location.onLocationChanged);
  });

  test("initialize exists early if permission is not granted", () async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(false));

    await locationMonitor.initialize();
    verifyNever(location.onLocationChanged);
  });

  test("Location changed exits early", () async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(true));

    var controller = StreamController<LocationData>.broadcast();
    when(location.onLocationChanged).thenAnswer((_) => controller.stream);

    await locationMonitor.initialize();

    // Stream should only add one event.
    locationMonitor.stream.listen(expectAsync1((_) => true, count: 1));

    controller.add(LocationData.fromMap({"latitude": null}));
    controller.add(LocationData.fromMap({"latitude": 0.0}));
    controller.add(LocationData.fromMap({"longitude": 0.0}));
    controller.add(LocationData.fromMap({
      "latitude": 5.0,
      "longitude": 8.0,
    }));
  });
}
