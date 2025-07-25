import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../../../adair-flutter-lib/test/test_utils/testable.dart';
import 'mocks/stubbed_managers.dart';
import 'test_utils.dart';

void main() {
  late StubbedManagers managers;
  late TripManager tripManager;

  List<Trip> trips() => [
    Trip(
      id: randomId(),
      name: "Trip 1",
      startTimestamp: Int64(dateTime(2020, 1, 1, 9).millisecondsSinceEpoch),
      endTimestamp: Int64(dateTime(2020, 1, 3, 17).millisecondsSinceEpoch),
    ),
    Trip(
      id: randomId(),
      name: "Trip 2",
      startTimestamp: Int64(dateTime(2020, 1, 10, 8).millisecondsSinceEpoch),
      endTimestamp: Int64(dateTime(2020, 1, 15, 18).millisecondsSinceEpoch),
    ),
    Trip(
      id: randomId(),
      name: "Trip 3",
      startTimestamp: Int64(dateTime(2020, 1, 20, 8).millisecondsSinceEpoch),
      endTimestamp: Int64(dateTime(2020, 1, 23, 18).millisecondsSinceEpoch),
    ),
  ];

  Trip defaultTrip() {
    return Trip(
      id: randomId(),
      name: "Trip Name",
      startTimestamp: Int64(dateTime(2020, 1, 1, 9).millisecondsSinceEpoch),
      endTimestamp: Int64(dateTime(2020, 1, 3, 17).millisecondsSinceEpoch),
    );
  }

  Future<void> stubDefaultTrips() async {
    for (var trip in trips()) {
      await tripManager.addOrUpdate(trip);
    }
  }

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.imageManager.save(any, compress: anyNamed("compress")),
    ).thenAnswer((_) => Future.value([]));

    when(
      managers.localDatabaseManager.insertOrReplace(any, any),
    ).thenAnswer((_) => Future.value(true));

    when(
      managers.lib.subscriptionManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);

    when(
      managers.userPreferenceManager.airTemperatureSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.airPressureSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.airVisibilitySystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.windSpeedSystem,
    ).thenReturn(MeasurementSystem.metric);

    tripManager = TripManager(managers.app);
  });

  testWidgets("displayName returns name", (tester) async {
    var context = await buildContext(tester);
    expect(
      tripManager.displayName(
        context,
        Trip(
          name: "Trip Name",
          startTimestamp: Int64(dateTime(2020, 1, 1, 9).millisecondsSinceEpoch),
          endTimestamp: Int64(dateTime(2020, 1, 3, 17).millisecondsSinceEpoch),
        ),
      ),
      "Trip Name",
    );
  });

  testWidgets("displayName returns time range", (tester) async {
    var context = await buildContext(tester);
    expect(
      tripManager.displayName(
        context,
        Trip(
          startTimestamp: Int64(dateTime(2020, 1, 1, 9).millisecondsSinceEpoch),
          endTimestamp: Int64(dateTime(2020, 1, 3, 17).millisecondsSinceEpoch),
        ),
      ),
      "Jan 1, 2020 at 9:00 AM to Jan 3, 2020 at 5:00 PM",
    );
  });

  testWidgets(
    "isolatedFilteredTrips returns trips that fall within a given date range",
    (tester) async {
      await stubDefaultTrips();

      var trips = tripManager.trips(
        await buildContext(tester),
        opt: TripFilterOptions(
          dateRange: DateRange(
            startTimestamp: Int64(
              dateTime(2020, 1, 9, 8).millisecondsSinceEpoch,
            ),
            endTimestamp: Int64(
              dateTime(2020, 1, 11, 8).millisecondsSinceEpoch,
            ),
          ),
        ),
      );

      expect(trips.length, 1);
      expect(trips[0].name, "Trip 2");
    },
  );

  testWidgets(
    "isolatedFilteredTrips adds default time zone to given DateRange",
    (tester) async {
      await stubDefaultTrips();

      var dateRange = DateRange(
        startTimestamp: Int64(dateTime(2020, 1, 9, 8).millisecondsSinceEpoch),
        endTimestamp: Int64(dateTime(2020, 1, 11, 8).millisecondsSinceEpoch),
      );
      expect(dateRange.hasTimeZone(), isFalse);

      tripManager.trips(
        await buildContext(tester),
        opt: TripFilterOptions(dateRange: dateRange),
      );
      expect(dateRange.hasTimeZone(), isTrue);
    },
  );

  testWidgets(
    "isolatedFilteredTrips excludes trips that don't fall within a given date range",
    (tester) async {
      await stubDefaultTrips();

      var trips = tripManager.trips(
        await buildContext(tester),
        opt: TripFilterOptions(
          dateRange: DateRange(
            startTimestamp: Int64(
              dateTime(2021, 1, 9, 8).millisecondsSinceEpoch,
            ),
            endTimestamp: Int64(
              dateTime(2021, 1, 11, 8).millisecondsSinceEpoch,
            ),
          ),
        ),
      );

      expect(trips, isEmpty);
    },
  );

  testWidgets("trips with no filters", (tester) async {
    await stubDefaultTrips();
    expect(tripManager.trips(await buildContext(tester)).length, 3);
  });

  testWidgets("trips adds missing fields to filter options", (tester) async {
    await stubDefaultTrips();
    expect(tripManager.trips(await buildContext(tester)).length, 3);

    verify(managers.lib.timeManager.currentTimeZone).called(1);
    verify(managers.lib.timeManager.currentTimestamp).called(1);
  });

  testWidgets("trips that match a string filter", (tester) async {
    when(managers.catchManager.idsMatchFilter(any, any, any)).thenReturn(false);
    when(
      managers.speciesManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.fishingSpotManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.anglerManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.baitManager.attachmentsMatchesFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.waterClarityManager.matchesFilter(any, any, any),
    ).thenReturn(false);

    await stubDefaultTrips();

    var trips = tripManager.trips(await buildContext(tester), filter: "3");
    expect(trips.length, 1);
    expect(trips[0].name, "Trip 3");
  });

  testWidgets("trips returns empty with valid filters", (tester) async {
    when(managers.catchManager.idsMatchFilter(any, any, any)).thenReturn(false);
    when(
      managers.speciesManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.fishingSpotManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.anglerManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.baitManager.attachmentsMatchesFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.waterClarityManager.matchesFilter(any, any, any),
    ).thenReturn(false);

    await stubDefaultTrips();
    expect(tripManager.trips(await buildContext(tester), filter: "4"), isEmpty);
  });

  testWidgets("matchesFilter returns false if Trip is null", (tester) async {
    expect(
      tripManager.matchesFilter(randomId(), await buildContext(tester), null),
      isFalse,
    );
  });

  testWidgets("matchesFilter true for super.matchesFilter", (tester) async {
    var trip = defaultTrip()..name = "Test Trip Name";
    await tripManager.addOrUpdate(trip);
    expect(
      tripManager.matchesFilter(trip.id, await buildContext(tester), "Name"),
      isTrue,
    );
  });

  testWidgets("matchesFilter true for CatchManager", (tester) async {
    when(managers.catchManager.idsMatchFilter(any, any, any)).thenReturn(true);

    var trip = defaultTrip();
    await tripManager.addOrUpdate(trip);

    expect(
      tripManager.matchesFilter(
        trip.id,
        await buildContext(tester),
        "Bad filter",
      ),
      isTrue,
    );
    verifyNever(managers.speciesManager.idsMatchFilter(any, any, any));
  });

  testWidgets("matchesFilter true for SpeciesManager", (tester) async {
    when(managers.catchManager.idsMatchFilter(any, any, any)).thenReturn(false);
    when(
      managers.speciesManager.idsMatchFilter(any, any, any),
    ).thenReturn(true);

    var trip = defaultTrip();
    await tripManager.addOrUpdate(trip);

    expect(
      tripManager.matchesFilter(
        trip.id,
        await buildContext(tester),
        "Bad filter",
      ),
      isTrue,
    );
    verifyNever(managers.fishingSpotManager.idsMatchFilter(any, any, any));
  });

  testWidgets("matchesFilter true for FishingSpotManager", (tester) async {
    when(managers.catchManager.idsMatchFilter(any, any, any)).thenReturn(false);
    when(
      managers.speciesManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.fishingSpotManager.idsMatchFilter(any, any, any),
    ).thenReturn(true);

    var trip = defaultTrip();
    await tripManager.addOrUpdate(trip);

    expect(
      tripManager.matchesFilter(
        trip.id,
        await buildContext(tester),
        "Bad filter",
      ),
      isTrue,
    );
    verifyNever(managers.anglerManager.idsMatchFilter(any, any, any));
  });

  testWidgets("matchesFilter true for AnglerManager", (tester) async {
    when(managers.catchManager.idsMatchFilter(any, any, any)).thenReturn(false);
    when(
      managers.speciesManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.fishingSpotManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(managers.anglerManager.idsMatchFilter(any, any, any)).thenReturn(true);

    var trip = defaultTrip();
    await tripManager.addOrUpdate(trip);

    expect(
      tripManager.matchesFilter(
        trip.id,
        await buildContext(tester),
        "Bad filter",
      ),
      isTrue,
    );
    verifyNever(managers.baitManager.idsMatchFilter(any, any, any));
  });

  testWidgets("matchesFilter false for null BuildContext", (tester) async {
    when(managers.catchManager.idsMatchFilter(any, any, any)).thenReturn(false);
    when(
      managers.speciesManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.fishingSpotManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.anglerManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.baitManager.attachmentsMatchesFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.waterClarityManager.matchesFilter(any, any, any),
    ).thenReturn(false);

    var trip = defaultTrip();
    await tripManager.addOrUpdate(trip);

    expect(
      tripManager.matchesFilter(
        trip.id,
        await buildContext(tester),
        "Bad filter",
      ),
      isFalse,
    );
    verifyNever(managers.baitManager.idsMatchFilter(any, any, any));
  });

  testWidgets("matchesFilter true for BaitManager", (tester) async {
    when(managers.catchManager.idsMatchFilter(any, any, any)).thenReturn(false);
    when(
      managers.speciesManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.fishingSpotManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.anglerManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.baitManager.attachmentsMatchesFilter(any, any, any),
    ).thenReturn(true);

    var context = await buildContext(tester);
    var trip = defaultTrip();
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, context, "Bad filter"), isTrue);
  });

  testWidgets("matchesFilter true for WaterClarityManager", (tester) async {
    when(managers.catchManager.idsMatchFilter(any, any, any)).thenReturn(false);
    when(
      managers.speciesManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.fishingSpotManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.anglerManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.baitManager.attachmentsMatchesFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.waterClarityManager.matchesFilter(any, any, any),
    ).thenReturn(true);

    var context = await buildContext(tester);
    var trip = defaultTrip();
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, context, "Bad filter"), isTrue);
  });

  testWidgets("matchesFilter true for notes", (tester) async {
    when(managers.catchManager.idsMatchFilter(any, any, any)).thenReturn(false);
    when(
      managers.speciesManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.fishingSpotManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.anglerManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.baitManager.attachmentsMatchesFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.waterClarityManager.matchesFilter(any, any, any),
    ).thenReturn(false);

    var context = await buildContext(tester);
    var trip = defaultTrip()..notes = "Some notes for the trip.";
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, context, "the trip."), isTrue);
  });

  testWidgets("matchesFilter true for atmosphere", (tester) async {
    when(managers.catchManager.idsMatchFilter(any, any, any)).thenReturn(false);
    when(
      managers.speciesManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.fishingSpotManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.anglerManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.baitManager.attachmentsMatchesFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.waterClarityManager.matchesFilter(any, any, any),
    ).thenReturn(false);

    var context = await buildContext(tester);
    var trip = defaultTrip()
      ..atmosphere = Atmosphere(skyConditions: [SkyCondition.clear]);
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, context, "clear"), isTrue);
  });

  testWidgets("matchesFilter true for custom entity values", (tester) async {
    when(managers.catchManager.idsMatchFilter(any, any, any)).thenReturn(false);
    when(
      managers.speciesManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.fishingSpotManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.anglerManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.baitManager.attachmentsMatchesFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.waterClarityManager.matchesFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.customEntityManager.matchesFilter(any, any, any),
    ).thenReturn(true);

    var context = await buildContext(tester);
    var trip = defaultTrip()
      ..customEntityValues.add(
        CustomEntityValue(customEntityId: randomId(), value: "Value"),
      );
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, context, "Value"), isTrue);
  });

  testWidgets("matchesFilter true for water depth", (tester) async {
    when(managers.catchManager.idsMatchFilter(any, any, any)).thenReturn(false);
    when(
      managers.speciesManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.fishingSpotManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.anglerManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.baitManager.attachmentsMatchesFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.waterClarityManager.matchesFilter(any, any, any),
    ).thenReturn(false);

    var context = await buildContext(tester);
    var trip = defaultTrip()
      ..waterDepth = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(unit: Unit.meters, value: 12),
      );
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, context, "12 m"), isTrue);
  });

  testWidgets("matchesFilter true for WaterClarityManager", (tester) async {
    when(managers.catchManager.idsMatchFilter(any, any, any)).thenReturn(false);
    when(
      managers.speciesManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.fishingSpotManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.anglerManager.idsMatchFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.baitManager.attachmentsMatchesFilter(any, any, any),
    ).thenReturn(false);
    when(
      managers.waterClarityManager.matchesFilter(any, any, any),
    ).thenReturn(false);

    var context = await buildContext(tester);
    var trip = defaultTrip()
      ..waterTemperature = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(unit: Unit.celsius, value: 65),
      );
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, context, "65\u00B0C"), isTrue);
  });

  test("numberOfCatches with multiple/null catches", () {
    var catchId0 = randomId();
    var catchId1 = randomId();
    var catchId2 = randomId();
    when(
      managers.catchManager.entity(catchId0),
    ).thenReturn(Catch(id: catchId0, quantity: 5));
    when(
      managers.catchManager.entity(catchId1),
    ).thenReturn(Catch(id: catchId1, quantity: 10));
    when(managers.catchManager.entity(catchId2)).thenReturn(null);

    var trip = defaultTrip()..catchIds.addAll([catchId0, catchId1, catchId2]);
    expect(tripManager.numberOfCatches(trip), 15);
  });

  test("numberOfCatches with multiple species", () {
    var trip = defaultTrip()
      ..catchesPerSpecies.addAll([
        Trip_CatchesPerEntity(entityId: randomId(), value: 5),
        Trip_CatchesPerEntity(entityId: randomId(), value: 5),
      ]);
    expect(tripManager.numberOfCatches(trip), 10);
  });

  test("numberOfCatches with catchesPerSpecies set", () {
    var trip = defaultTrip()
      ..catchesPerSpecies.addAll([
        Trip_CatchesPerEntity(entityId: randomId(), value: 5),
        Trip_CatchesPerEntity(entityId: randomId(), value: 5),
      ]);
    expect(tripManager.numberOfCatches(trip), 10);
  });

  test("numberOfCatches with attached catches", () {
    var catchId0 = randomId();
    var catchId1 = randomId();
    var catchId2 = randomId();
    when(
      managers.catchManager.entity(catchId0),
    ).thenReturn(Catch(id: catchId0, quantity: 5));
    when(
      managers.catchManager.entity(catchId1),
    ).thenReturn(Catch(id: catchId1, quantity: 10));
    when(managers.catchManager.entity(catchId2)).thenReturn(null);

    var trip = defaultTrip()..catchIds.addAll([catchId0, catchId1, catchId2]);
    expect(tripManager.numberOfCatches(trip), 15);
  });

  testWidgets("isCatchInTrip", (tester) async {
    var catchId0 = randomId();
    var catchId1 = randomId();
    var trip = defaultTrip()..catchIds.addAll([catchId0, catchId1]);
    await tripManager.addOrUpdate(trip);

    expect(tripManager.isCatchIdInTrip(catchId0), isTrue);
    expect(tripManager.isCatchIdInTrip(randomId()), isFalse);
  });

  test("initialize updates trip time zones", () async {
    var tripId1 = randomId();
    var tripId2 = randomId();
    var tripId3 = randomId();
    when(managers.localDatabaseManager.fetchAll(any)).thenAnswer((_) {
      return Future.value([
        {"id": tripId1.uint8List, "bytes": Trip(id: tripId1).writeToBuffer()},
        {
          "id": tripId2.uint8List,
          "bytes": Trip(id: tripId2, timeZone: defaultTimeZone).writeToBuffer(),
        },
        {"id": tripId3.uint8List, "bytes": Trip(id: tripId3).writeToBuffer()},
      ]);
    });
    when(
      managers.lib.timeManager.currentTimeZone,
    ).thenReturn("America/Chicago");

    await tripManager.initialize();

    var reports = tripManager.list();
    expect(reports.length, 3);
    expect(reports[0].timeZone, "America/Chicago");
    expect(reports[1].timeZone, "America/New_York");
    expect(reports[2].timeZone, "America/Chicago");

    verify(
      managers.localDatabaseManager.insertOrReplace(any, any, any),
    ).called(2);
  });

  test("initialize updates trip atmospheres", () async {
    var tripId1 = randomId();
    var tripId2 = randomId();
    var tripId3 = randomId();
    when(managers.localDatabaseManager.fetchAll(any)).thenAnswer((_) {
      return Future.value([
        {
          "id": tripId1.uint8List,
          "bytes": Trip(
            id: tripId1,
            timeZone: defaultTimeZone,
            atmosphere: Atmosphere(
              temperatureDeprecated: Measurement(unit: Unit.celsius, value: 15),
            ),
          ).writeToBuffer(),
        },
        {
          "id": tripId2.uint8List,
          "bytes": Trip(id: tripId2, timeZone: defaultTimeZone).writeToBuffer(),
        },
        {
          "id": tripId3.uint8List,
          "bytes": Trip(
            id: tripId3,
            timeZone: defaultTimeZone,
            atmosphere: Atmosphere(
              windSpeedDeprecated: Measurement(
                unit: Unit.kilometers_per_hour,
                value: 6,
              ),
            ),
          ).writeToBuffer(),
        },
      ]);
    });

    await tripManager.initialize();

    var trips = tripManager.list();
    expect(trips.length, 3);
    expect(trips[0].atmosphere.hasTemperatureDeprecated(), isFalse);
    expect(trips[0].atmosphere.hasTemperature(), isTrue);
    expect(trips[1].hasAtmosphere(), isFalse);
    expect(trips[2].atmosphere.hasWindSpeedDeprecated(), isFalse);
    expect(trips[2].atmosphere.hasWindSpeed(), isTrue);

    verify(
      managers.localDatabaseManager.insertOrReplace(any, any, any),
    ).called(2);
  });

  test("addOrUpdate, setImages=false", () async {
    await tripManager.addOrUpdate(Trip()..id = randomId(), setImages: false);
    verifyNever(
      managers.imageManager.save(any, compress: anyNamed("compress")),
    );
    verify(
      managers.localDatabaseManager.insertOrReplace(any, any, any),
    ).called(1);
  });

  test("addOrUpdate, setImages=true", () async {
    await tripManager.addOrUpdate(Trip()..id = randomId(), setImages: true);
    verify(
      managers.imageManager.save(any, compress: anyNamed("compress")),
    ).called(1);
    verify(
      managers.localDatabaseManager.insertOrReplace(any, any, any),
    ).called(1);
  });
}
