import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/gps_trail_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late GpsTrailManager gpsTrailManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.localDatabaseManager.insertOrReplace(any, any, any))
        .thenAnswer((realInvocation) => Future.value(true));
    when(appManager.localDatabaseManager.fetchAll(any))
        .thenAnswer((_) => Future.value([]));

    when(appManager.locationMonitor.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.locationMonitor.enableBackgroundMode(any))
        .thenAnswer((_) => Future.value());
    when(appManager.locationMonitor.disableBackgroundMode())
        .thenAnswer((_) => Future.value(false));
    when(appManager.locationMonitor.currentLocation).thenReturn(null);

    when(appManager.userPreferenceManager.minGpsTrailDistance)
        .thenReturn(MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.feet,
        value: 150,
      ),
    ));

    gpsTrailManager = GpsTrailManager(appManager.app);
  });

  testWidgets("matchesFilter", (tester) async {
    var context = await buildContext(tester);
    expect(gpsTrailManager.matchesFilter(randomId(), context, null), isFalse);

    when(appManager.bodyOfWaterManager.idsMatchFilter(any, any, any))
        .thenReturn(true);
    var id = randomId();
    await gpsTrailManager.addOrUpdate(GpsTrail(id: id));
    expect(gpsTrailManager.matchesFilter(id, context, null), isTrue);
  });

  testWidgets("startTracking exists early if already tracking", (tester) async {
    var context = await buildContext(tester);

    // Start tracking.
    await gpsTrailManager.startTracking(context);
    expect(gpsTrailManager.activeTrial, isNotNull);
    expect(gpsTrailManager.list().length, 1);
    verify(appManager.timeManager.currentTimestamp).called(1);
    verify(appManager.locationMonitor.enableBackgroundMode(any)).called(1);

    // Verify early exit.
    await gpsTrailManager.startTracking(context);
    expect(gpsTrailManager.list().length, 1);
    verifyNever(appManager.timeManager.currentTimestamp);
    verifyNever(appManager.locationMonitor.enableBackgroundMode(any));
  });

  testWidgets("startTracking adds current location if not null",
      (tester) async {
    when(appManager.locationMonitor.currentLocation)
        .thenReturn(LocationPoint(lat: 1, lng: 2, heading: 3));

    var context = await buildContext(tester);

    await gpsTrailManager.startTracking(context);
    expect(gpsTrailManager.activeTrial!.points.length, 1);
  });

  testWidgets("startTracking notifies listeners", (tester) async {
    var context = await buildContext(tester);

    var count = 0;
    gpsTrailManager.stream.listen(expectAsync1(
      (event) {
        if (count == 0) {
          expect(event.type, EntityEventType.add);
        } else if (count == 1) {
          expect(event.type, GpsTrailEventType.startTracking);
        }
        count++;
      },
      count: 2,
    ));
    await gpsTrailManager.startTracking(context);
  });

  test("stopTracking exists early if not tracking", () async {
    await gpsTrailManager.stopTracking();
    expect(gpsTrailManager.activeTrial, isNull);
    verifyNever(appManager.timeManager.currentTimestamp);
  });

  testWidgets("stopTracking clears active state", (tester) async {
    var context = await buildContext(tester);

    // Start tracking.
    await gpsTrailManager.startTracking(context);
    expect(gpsTrailManager.activeTrial, isNotNull);
    expect(gpsTrailManager.list().length, 1);
    verify(appManager.timeManager.currentTimestamp).called(1);
    verify(appManager.locationMonitor.enableBackgroundMode(any)).called(1);

    // Stop tracking.
    await gpsTrailManager.stopTracking();
    expect(gpsTrailManager.activeTrial, isNull);
    verify(appManager.timeManager.currentTimestamp).called(1);
    verify(appManager.locationMonitor.disableBackgroundMode()).called(1);
  });

  testWidgets("stopTracking notifies listeners", (tester) async {
    var context = await buildContext(tester);
    await gpsTrailManager.startTracking(context);

    var count = 0;
    gpsTrailManager.stream.listen(expectAsync1(
      (event) {
        if (count == 0) {
          expect(event.type, EntityEventType.update);
        } else if (count == 1) {
          expect(event.type, GpsTrailEventType.endTracking);
        }
        count++;
      },
      count: 2,
    ));
    await gpsTrailManager.stopTracking();
  });

  testWidgets("gpsTrails returns filtered list", (tester) async {
    var bodyOfWater = BodyOfWater(
      id: randomId(),
      name: "Lake Huron",
    );
    when(appManager.bodyOfWaterManager.idsMatchFilter(any, any, any))
        .thenAnswer((invocation) =>
            invocation.positionalArguments.first[0] == bodyOfWater.id);

    await gpsTrailManager
        .addOrUpdate(GpsTrail(id: randomId(), startTimestamp: Int64(10)));
    await gpsTrailManager
        .addOrUpdate(GpsTrail(id: randomId(), startTimestamp: Int64(3)));
    await gpsTrailManager
        .addOrUpdate(GpsTrail(id: randomId(), startTimestamp: Int64(8)));
    await gpsTrailManager
        .addOrUpdate(GpsTrail(id: randomId(), startTimestamp: Int64(15)));
    await gpsTrailManager.addOrUpdate(GpsTrail(
      id: randomId(),
      startTimestamp: Int64(1),
      bodyOfWaterId: bodyOfWater.id,
    ));

    var context = await buildContext(tester);
    var trails = gpsTrailManager.gpsTrails(context, filter: "Lake");
    expect(trails.length, 1);
    expect(trails[0].startTimestamp.toInt(), 1);
    expect(trails[0].bodyOfWaterId, bodyOfWater.id);
  });

  testWidgets("gpsTrails returns sorted trails", (tester) async {
    await gpsTrailManager
        .addOrUpdate(GpsTrail(id: randomId(), startTimestamp: Int64(10)));
    await gpsTrailManager
        .addOrUpdate(GpsTrail(id: randomId(), startTimestamp: Int64(3)));
    await gpsTrailManager
        .addOrUpdate(GpsTrail(id: randomId(), startTimestamp: Int64(8)));
    await gpsTrailManager
        .addOrUpdate(GpsTrail(id: randomId(), startTimestamp: Int64(15)));
    await gpsTrailManager
        .addOrUpdate(GpsTrail(id: randomId(), startTimestamp: Int64(1)));

    var trails = gpsTrailManager.gpsTrails(await buildContext(tester));
    expect(trails[0].startTimestamp.toInt(), 15);
    expect(trails[1].startTimestamp.toInt(), 10);
    expect(trails[2].startTimestamp.toInt(), 8);
    expect(trails[3].startTimestamp.toInt(), 3);
    expect(trails[4].startTimestamp.toInt(), 1);
  });

  test("numberOfTrips", () async {
    var gpsTrailId = randomId();
    when(appManager.tripManager.list()).thenReturn([
      Trip(
        id: randomId(),
        gpsTrailIds: [gpsTrailId],
      ),
      Trip(id: randomId()),
      Trip(
        id: randomId(),
        gpsTrailIds: [gpsTrailId],
      ),
      Trip(id: randomId()),
    ]);

    await gpsTrailManager.addOrUpdate(GpsTrail(id: gpsTrailId));
    expect(gpsTrailManager.numberOfTrips(gpsTrailId), 2);
  });

  testWidgets("deleteMessage singular", (tester) async {
    var gpsTrail = GpsTrail(id: randomId());
    when(appManager.tripManager.list()).thenReturn([
      Trip(
        id: randomId(),
        gpsTrailIds: [gpsTrail.id],
      ),
    ]);

    await gpsTrailManager.addOrUpdate(gpsTrail);

    var context = await buildContext(tester);
    expect(
      gpsTrailManager.deleteMessage(context, gpsTrail),
      "This GPS trail is associated with 1 trip; are you sure you want to delete it? This cannot be undone.",
    );
  });

  testWidgets("deleteMessage plural", (tester) async {
    var gpsTrail = GpsTrail(id: randomId());
    when(appManager.tripManager.list()).thenReturn([
      Trip(
        id: randomId(),
        gpsTrailIds: [gpsTrail.id],
      ),
      Trip(
        id: randomId(),
        gpsTrailIds: [gpsTrail.id],
      ),
    ]);

    await gpsTrailManager.addOrUpdate(gpsTrail);

    var context = await buildContext(tester);
    expect(
      gpsTrailManager.deleteMessage(context, gpsTrail),
      "This GPS trail is associated with 2 trips; are you sure you want to delete it? This cannot be undone.",
    );
  });

  test("_onLocationUpdate exits early if trail isn't active", () async {
    var testStreamController = StreamController<LocationPoint>.broadcast();
    when(appManager.locationMonitor.stream)
        .thenAnswer((_) => testStreamController.stream);

    // Reset GpsTrailManager to listen to the updated location stream.
    gpsTrailManager = GpsTrailManager(appManager.app);

    testStreamController.add(LocationPoint(
      lat: 35.75919,
      lng: 105.88602,
      heading: 100,
    ));
    expect(gpsTrailManager.hasActiveTrail, isFalse);
  });

  testWidgets("_onLocationUpdate exits early if point is too close to last",
      (tester) async {
    var testStreamController = StreamController<LocationPoint>.broadcast();
    when(appManager.locationMonitor.stream)
        .thenAnswer((_) => testStreamController.stream);
    when(appManager.locationMonitor.currentLocation)
        .thenReturn(LocationPoint(lat: 35.75919, lng: 105.88602, heading: 3));

    // Reset GpsTrailManager to listen to the updated location stream.
    gpsTrailManager = GpsTrailManager(appManager.app);
    await gpsTrailManager.initialize();

    // Start tracking.
    var context = await buildContext(tester);
    await gpsTrailManager.startTracking(context);
    expect(gpsTrailManager.hasActiveTrail, isTrue);
    expect(gpsTrailManager.activeTrial!.points.length, 1);

    // Add LatLng that's too close to the first and verify it wasn't added.
    testStreamController.add(LocationPoint(
      lat: 35.75919,
      lng: 105.88602,
      heading: 100,
    ));
    expect(gpsTrailManager.activeTrial!.points.length, 1);
  });

  testWidgets("_onLocationUpdate adds point to active trail", (tester) async {
    var testStreamController = StreamController<LocationPoint>.broadcast();
    when(appManager.locationMonitor.stream)
        .thenAnswer((_) => testStreamController.stream);
    when(appManager.locationMonitor.currentLocation)
        .thenReturn(LocationPoint(lat: 35.75919, lng: 105.88602, heading: 3));

    // Reset GpsTrailManager to listen to the updated location stream.
    gpsTrailManager = GpsTrailManager(appManager.app);
    await gpsTrailManager.initialize();

    // Start tracking.
    var context = await buildContext(tester);
    await gpsTrailManager.startTracking(context);
    expect(gpsTrailManager.hasActiveTrail, isTrue);
    expect(gpsTrailManager.activeTrial!.points.length, 1);

    // Verify all new points are added.
    gpsTrailManager.stream.listen(expectAsyncUntil1(
      (_) => true,
      () => gpsTrailManager.activeTrial!.points.length == 4,
    ));

    testStreamController.add(LocationPoint(
      lat: -19.96447,
      lng: 112.55213,
      heading: 100,
    ));
    testStreamController.add(LocationPoint(
      lat: -11.66778,
      lng: -161.35861,
      heading: 100,
    ));
    testStreamController.add(LocationPoint(
      lat: 10.86326,
      lng: -81.34905,
      heading: 100,
    ));
  });
}
