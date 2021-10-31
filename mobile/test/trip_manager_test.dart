import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late TripManager tripManager;

  Trip defaultTrip() {
    return Trip(
      id: randomId(),
      name: "Trip Name",
      startTimestamp: Int64(DateTime(2020, 1, 1, 9).millisecondsSinceEpoch),
      endTimestamp: Int64(DateTime(2020, 1, 3, 17).millisecondsSinceEpoch),
    );
  }

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.authManager.stream).thenAnswer((_) => const Stream.empty());

    when(appManager.imageManager.save(any, compress: anyNamed("compress")))
        .thenAnswer((_) => Future.value([]));

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    tripManager = TripManager(appManager.app);
  });

  testWidgets("displayName returns name", (tester) async {
    var context = await buildContext(tester);
    expect(
      tripManager.displayName(
        context,
        Trip(
          name: "Trip Name",
          startTimestamp: Int64(DateTime(2020, 1, 1, 9).millisecondsSinceEpoch),
          endTimestamp: Int64(DateTime(2020, 1, 3, 17).millisecondsSinceEpoch),
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
          startTimestamp: Int64(DateTime(2020, 1, 1, 9).millisecondsSinceEpoch),
          endTimestamp: Int64(DateTime(2020, 1, 3, 17).millisecondsSinceEpoch),
        ),
      ),
      "Jan 1, 2020 at 9:00 AM to Jan 3, 2020 at 5:00 PM",
    );
  });

  test("matchesFilter returns false if Trip is null", () {
    expect(
      tripManager.matchesFilter(randomId(), null),
      isFalse,
    );
  });

  test("matchesFilter true for super.matchesFilter", () async {
    var trip = defaultTrip()..name = "Test Trip Name";
    await tripManager.addOrUpdate(trip);
    expect(tripManager.matchesFilter(trip.id, "Name"), isTrue);
  });

  test("matchesFilter true for CatchManager", () async {
    when(appManager.catchManager.idsMatchesFilter(any, any)).thenReturn(true);

    var trip = defaultTrip();
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, "Bad filter"), isTrue);
    verifyNever(appManager.speciesManager.idsMatchesFilter(any, any));
  });

  test("matchesFilter true for SpeciesManager", () async {
    when(appManager.catchManager.idsMatchesFilter(any, any)).thenReturn(false);
    when(appManager.speciesManager.idsMatchesFilter(any, any)).thenReturn(true);

    var trip = defaultTrip();
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, "Bad filter"), isTrue);
    verifyNever(appManager.fishingSpotManager.idsMatchesFilter(any, any));
  });

  test("matchesFilter true for FishingSpotManager", () async {
    when(appManager.catchManager.idsMatchesFilter(any, any)).thenReturn(false);
    when(appManager.speciesManager.idsMatchesFilter(any, any))
        .thenReturn(false);
    when(appManager.fishingSpotManager.idsMatchesFilter(any, any))
        .thenReturn(true);

    var trip = defaultTrip();
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, "Bad filter"), isTrue);
    verifyNever(appManager.anglerManager.idsMatchesFilter(any, any));
  });

  test("matchesFilter true for AnglerManager", () async {
    when(appManager.catchManager.idsMatchesFilter(any, any)).thenReturn(false);
    when(appManager.speciesManager.idsMatchesFilter(any, any))
        .thenReturn(false);
    when(appManager.fishingSpotManager.idsMatchesFilter(any, any))
        .thenReturn(false);
    when(appManager.anglerManager.idsMatchesFilter(any, any)).thenReturn(true);

    var trip = defaultTrip();
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, "Bad filter"), isTrue);
    verifyNever(appManager.baitManager.idsMatchesFilter(any, any));
  });

  test("matchesFilter true for null BuildContext", () async {
    when(appManager.catchManager.idsMatchesFilter(any, any)).thenReturn(false);
    when(appManager.speciesManager.idsMatchesFilter(any, any))
        .thenReturn(false);
    when(appManager.fishingSpotManager.idsMatchesFilter(any, any))
        .thenReturn(false);
    when(appManager.anglerManager.idsMatchesFilter(any, any)).thenReturn(false);

    var trip = defaultTrip();
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, "Bad filter", null), isTrue);
    verifyNever(appManager.baitManager.idsMatchesFilter(any, any));
  });

  testWidgets("matchesFilter true for BaitManager", (tester) async {
    when(appManager.catchManager.idsMatchesFilter(any, any)).thenReturn(false);
    when(appManager.speciesManager.idsMatchesFilter(any, any))
        .thenReturn(false);
    when(appManager.fishingSpotManager.idsMatchesFilter(any, any))
        .thenReturn(false);
    when(appManager.anglerManager.idsMatchesFilter(any, any)).thenReturn(false);
    when(appManager.baitManager.attachmentsMatchesFilter(any, any, any))
        .thenReturn(true);

    var context = await buildContext(tester);
    var trip = defaultTrip();
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, "Bad filter", context), isTrue);
  });

  testWidgets("matchesFilter true for notes", (tester) async {
    when(appManager.catchManager.idsMatchesFilter(any, any)).thenReturn(false);
    when(appManager.speciesManager.idsMatchesFilter(any, any))
        .thenReturn(false);
    when(appManager.fishingSpotManager.idsMatchesFilter(any, any))
        .thenReturn(false);
    when(appManager.anglerManager.idsMatchesFilter(any, any)).thenReturn(false);
    when(appManager.baitManager.attachmentsMatchesFilter(any, any, any))
        .thenReturn(false);

    var context = await buildContext(tester);
    var trip = defaultTrip()..notes = "Some notes for the trip.";
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, "the trip.", context), isTrue);
  });

  testWidgets("matchesFilter true for atmosphere", (tester) async {
    when(appManager.catchManager.idsMatchesFilter(any, any)).thenReturn(false);
    when(appManager.speciesManager.idsMatchesFilter(any, any))
        .thenReturn(false);
    when(appManager.fishingSpotManager.idsMatchesFilter(any, any))
        .thenReturn(false);
    when(appManager.anglerManager.idsMatchesFilter(any, any)).thenReturn(false);
    when(appManager.baitManager.attachmentsMatchesFilter(any, any, any))
        .thenReturn(false);

    var context = await buildContext(tester);
    var trip = defaultTrip()
      ..atmosphere = Atmosphere(
        skyConditions: [SkyCondition.clear],
      );
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, "clear", context), isTrue);
  });

  testWidgets("matchesFilter true for custom entity values", (tester) async {
    when(appManager.catchManager.idsMatchesFilter(any, any)).thenReturn(false);
    when(appManager.speciesManager.idsMatchesFilter(any, any))
        .thenReturn(false);
    when(appManager.fishingSpotManager.idsMatchesFilter(any, any))
        .thenReturn(false);
    when(appManager.anglerManager.idsMatchesFilter(any, any)).thenReturn(false);
    when(appManager.baitManager.attachmentsMatchesFilter(any, any, any))
        .thenReturn(false);
    when(appManager.customEntityManager.matchesFilter(any, any))
        .thenReturn(true);

    var context = await buildContext(tester);
    var trip = defaultTrip()
      ..customEntityValues.add(CustomEntityValue(
        customEntityId: randomId(),
        value: "Value",
      ));
    await tripManager.addOrUpdate(trip);

    expect(tripManager.matchesFilter(trip.id, "Value", context), isTrue);
  });

  test("numberOfCatches with multiple/null catches", () {
    var catchId0 = randomId();
    var catchId1 = randomId();
    var catchId2 = randomId();
    when(appManager.catchManager.entity(catchId0)).thenReturn(Catch(
      id: catchId0,
      quantity: 5,
    ));
    when(appManager.catchManager.entity(catchId1)).thenReturn(Catch(
      id: catchId1,
      quantity: 10,
    ));
    when(appManager.catchManager.entity(catchId2)).thenReturn(null);

    var trip = defaultTrip()..catchIds.addAll([catchId0, catchId1, catchId2]);
    expect(tripManager.numberOfCatches(trip), 15);
  });

  test("numberOfCatches with multiple species", () {
    var trip = defaultTrip()
      ..catchesPerSpecies.addAll([
        Trip_CatchesPerEntity(
          entityId: randomId(),
          value: 5,
        ),
        Trip_CatchesPerEntity(
          entityId: randomId(),
          value: 5,
        ),
      ]);
    expect(tripManager.numberOfCatches(trip), 10);
  });

  test("numberOfCatches with catches and species", () {
    var catchId0 = randomId();
    var catchId1 = randomId();
    var catchId2 = randomId();
    when(appManager.catchManager.entity(catchId0)).thenReturn(Catch(
      id: catchId0,
      quantity: 5,
    ));
    when(appManager.catchManager.entity(catchId1)).thenReturn(Catch(
      id: catchId1,
      quantity: 10,
    ));
    when(appManager.catchManager.entity(catchId2)).thenReturn(null);

    var trip = defaultTrip()
      ..catchIds.addAll([catchId0, catchId1, catchId2])
      ..catchesPerSpecies.addAll([
        Trip_CatchesPerEntity(
          entityId: randomId(),
          value: 5,
        ),
        Trip_CatchesPerEntity(
          entityId: randomId(),
          value: 5,
        ),
      ]);
    expect(tripManager.numberOfCatches(trip), 25);
  });

  test("allImageNames empty result", () {
    expect(tripManager.allImageNames(defaultTrip()), isEmpty);
  });

  test("allImageNames with trip names", () {
    expect(
      tripManager
          .allImageNames(defaultTrip()..imageNames.addAll(["1.png", "2.png"]))
          .length,
      2,
    );
  });

  test("allImageNames with catch image names", () {
    var catchId0 = randomId();
    var catchId1 = randomId();
    var catchId2 = randomId();
    when(appManager.catchManager.entity(catchId0)).thenReturn(Catch(
      id: catchId0,
      imageNames: ["1.png", "2.png"],
    ));
    when(appManager.catchManager.entity(catchId1)).thenReturn(Catch(
      id: catchId1,
      imageNames: ["3.png", "4.png"],
    ));
    when(appManager.catchManager.entity(catchId2)).thenReturn(null);

    expect(
      tripManager
          .allImageNames(defaultTrip()..catchIds.addAll([catchId0, catchId1]))
          .length,
      4,
    );
  });

  test("allImageNames with catch and trip image names", () {
    var catchId0 = randomId();
    var catchId1 = randomId();
    var catchId2 = randomId();
    when(appManager.catchManager.entity(catchId0)).thenReturn(Catch(
      id: catchId0,
      imageNames: ["1.png", "2.png"],
    ));
    when(appManager.catchManager.entity(catchId1)).thenReturn(Catch(
      id: catchId1,
      imageNames: ["3.png", "4.png"],
    ));
    when(appManager.catchManager.entity(catchId2)).thenReturn(null);

    expect(
      tripManager
          .allImageNames(defaultTrip()
            ..catchIds.addAll([catchId0, catchId1])
            ..imageNames.addAll(["5.png", "6.png"]))
          .length,
      6,
    );
  });

  testWidgets("isCatchInTrip", (tester) async {
    var catchId0 = randomId();
    var catchId1 = randomId();
    var trip = defaultTrip()..catchIds.addAll([catchId0, catchId1]);
    await tripManager.addOrUpdate(trip);

    expect(tripManager.isCatchIdInTrip(catchId0), isTrue);
    expect(tripManager.isCatchIdInTrip(randomId()), isFalse);
  });
}
