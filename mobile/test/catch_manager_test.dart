import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late MockBaitCategoryManager baitCategoryManager;
  late MockLocalDatabaseManager dataManager;
  late MockImageManager imageManager;
  late MockSpeciesManager speciesManager;

  late BaitManager baitManager;
  late CatchManager catchManager;
  late FishingSpotManager fishingSpotManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.anglerManager.matchesFilter(any, any)).thenReturn(false);

    when(appManager.authManager.stream).thenAnswer((_) => Stream.empty());

    baitCategoryManager = appManager.baitCategoryManager;
    when(baitCategoryManager.addListener(any)).thenAnswer((_) {});

    dataManager = appManager.localDatabaseManager;
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    imageManager = appManager.imageManager;
    when(imageManager.save(any, compress: anyNamed("compress"))).thenAnswer(
      (invocation) => Future.value(
          (invocation.positionalArguments.first as List<File>?)
                  ?.map((f) => f.path)
                  .toList() ??
              []),
    );

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    fishingSpotManager = FishingSpotManager(appManager.app);
    when(appManager.app.fishingSpotManager).thenReturn(fishingSpotManager);

    baitManager = BaitManager(appManager.app);
    when(appManager.app.baitManager).thenReturn(baitManager);

    speciesManager = appManager.speciesManager;
    when(speciesManager.matchesFilter(any, any)).thenReturn(false);

    when(appManager.methodManager.idsMatchFilter(any, any)).thenReturn(false);

    catchManager = CatchManager(appManager.app);
  });

  test("When a bait is deleted, existing catches are updated", () async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.replaceRows(any, any)).thenAnswer((_) => Future.value());

    var catchListener = MockEntityListener<Catch>();
    when(catchListener.onAdd).thenReturn((_) {});
    when(catchListener.onDelete).thenReturn((_) {});

    var updatedCatches = <Catch>[];
    when(catchListener.onUpdate).thenReturn((cat) => updatedCatches.add(cat));
    catchManager.addListener(catchListener);

    // Add a bait.
    var baitId0 = randomId();
    var bait = Bait()
      ..id = baitId0
      ..name = "Rapala";
    await baitManager.addOrUpdate(bait);

    // Add a couple catches that use the new bait.
    var catchId0 = randomId();
    var catchId1 = randomId();
    await catchManager.addOrUpdate(Catch()
      ..id = catchId0
      ..baitId = baitId0);
    await catchManager.addOrUpdate(Catch()
      ..id = catchId1
      ..baitId = baitId0);
    verify(catchListener.onAdd).called(2);
    expect(catchManager.entity(catchId0)!.baitId, baitId0);
    expect(catchManager.entity(catchId1)!.baitId, baitId0);

    // Delete the new bait.
    await baitManager.delete(baitId0);

    // Wait for addOrUpdate calls to finish.
    await Future.delayed(Duration(milliseconds: 50));

    // Verify listeners are notified and memory cache updated.
    verify(catchListener.onUpdate).called(2);
    expect(catchManager.entity(catchId0)!.hasBaitId(), false);
    expect(catchManager.entity(catchId1)!.hasBaitId(), false);
    expect(updatedCatches.length, 2);
  });

  test("When a fishing spot is deleted, existing catches are updated",
      () async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.replaceRows(any, any)).thenAnswer((_) => Future.value());

    var catchListener = MockEntityListener<Catch>();
    when(catchListener.onAdd).thenReturn((_) {});
    when(catchListener.onDelete).thenReturn((_) {});

    var updatedCatches = <Catch>[];
    when(catchListener.onUpdate).thenReturn((cat) => updatedCatches.add(cat));
    catchManager.addListener(catchListener);

    // Add a fishing spot.
    var fishingSpotId0 = randomId();
    var fishingSpot = FishingSpot()..id = fishingSpotId0;
    await fishingSpotManager.addOrUpdate(fishingSpot);

    // Add a couple catches that use the new fishing spot.
    var catchId0 = randomId();
    var catchId1 = randomId();
    await catchManager.addOrUpdate(Catch()
      ..id = catchId0
      ..fishingSpotId = fishingSpotId0);
    await catchManager.addOrUpdate(Catch()
      ..id = catchId1
      ..fishingSpotId = fishingSpotId0);
    verify(catchListener.onAdd).called(2);
    expect(catchManager.entity(catchId0)!.fishingSpotId, fishingSpotId0);
    expect(catchManager.entity(catchId1)!.fishingSpotId, fishingSpotId0);

    // Delete the new fishing spot.
    await fishingSpotManager.delete(fishingSpotId0);

    // Wait for addOrUpdate calls to finish.
    await Future.delayed(Duration(milliseconds: 50));

    // Verify listeners are notified and memory cache updated.
    verify(catchListener.onUpdate).called(2);
    expect(catchManager.entity(catchId0)!.hasFishingSpotId(), false);
    expect(catchManager.entity(catchId1)!.hasFishingSpotId(), false);
    expect(updatedCatches.length, 2);
  });

  testWidgets("Filtering by search query; non-ID reference properties",
      (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 4, 4).millisecondsSinceEpoch));

    var context = await buildContext(tester, appManager: appManager);

    var catches = catchManager.filteredCatches(context, filter: "");
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context, filter: "janua");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, filter: "april");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, filter: "4");
    expect(catches.length, 1);
  });

  testWidgets("Filtering by search query; bait", (tester) async {
    var baitManager = MockBaitManager();
    when(appManager.app.baitManager).thenReturn(baitManager);
    when(baitManager.matchesFilter(any, any)).thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baitId = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baitId = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "Bait").length, 2);
  });

  testWidgets("Filtering by search query; fishing spot", (tester) async {
    var fishingSpotManager = MockFishingSpotManager();
    when(appManager.app.fishingSpotManager).thenReturn(fishingSpotManager);
    when(fishingSpotManager.matchesFilter(any, any)).thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..fishingSpotId = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..fishingSpotId = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "Spot").length, 2);
  });

  testWidgets("Filtering by search query; species", (tester) async {
    var speciesManager = MockSpeciesManager();
    when(appManager.app.speciesManager).thenReturn(speciesManager);
    when(speciesManager.matchesFilter(any, any)).thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..speciesId = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..speciesId = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "Species").length, 2);
  });

  testWidgets("Filtering by search query; angler", (tester) async {
    when(appManager.anglerManager.matchesFilter(any, any)).thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..anglerId = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..anglerId = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "Angler").length, 2);
  });

  testWidgets("Filtering by search query; method", (tester) async {
    when(appManager.methodManager.idsMatchFilter(any, any)).thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..methodIds.add(randomId()));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..methodIds.add(randomId()));

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "Method").length, 2);
  });

  testWidgets("Filtering by angler", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    var anglerId0 = randomId();
    var anglerId1 = randomId();
    var anglerId2 = randomId();

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..anglerId = anglerId0);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..anglerId = anglerId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..anglerId = anglerId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..anglerId = anglerId2);

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      anglerIds: {anglerId1},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(
      context,
      anglerIds: {anglerId1, anglerId2},
    );
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(
      context,
      anglerIds: {randomId()},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by species", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    var speciesId0 = randomId();
    var speciesId1 = randomId();
    var speciesId2 = randomId();

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..speciesId = speciesId0);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..speciesId = speciesId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..speciesId = speciesId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..speciesId = speciesId2);

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      speciesIds: {speciesId1},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(
      context,
      speciesIds: {speciesId1, speciesId2},
    );
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(
      context,
      speciesIds: {randomId()},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by date range", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(5000));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(10000));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(20000));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      dateRange: DateRange(
        startDate: DateTime.fromMillisecondsSinceEpoch(0),
        endDate: DateTime.fromMillisecondsSinceEpoch(15000),
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(
      context,
      dateRange: DateRange(
        startDate: DateTime.fromMillisecondsSinceEpoch(20001),
        endDate: DateTime.fromMillisecondsSinceEpoch(30000),
      ),
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by fishing spot", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    var fishingSpotId0 = randomId();
    var fishingSpotId1 = randomId();
    var fishingSpotId2 = randomId();
    var fishingSpotId3 = randomId();

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..fishingSpotId = fishingSpotId0);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..fishingSpotId = fishingSpotId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..fishingSpotId = fishingSpotId0);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..fishingSpotId = fishingSpotId3);

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      fishingSpotIds: {fishingSpotId0},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(
      context,
      fishingSpotIds: {fishingSpotId0, fishingSpotId3},
    );
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(
      context,
      fishingSpotIds: {fishingSpotId2},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by bait", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    var baitId0 = randomId();
    var baitId1 = randomId();
    var baitId2 = randomId();
    var baitId3 = randomId();

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baitId = baitId0);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baitId = baitId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baitId = baitId0);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baitId = baitId3);

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      baitIds: {baitId0},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(
      context,
      baitIds: {baitId0, baitId3},
    );
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(
      context,
      baitIds: {baitId2},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by catch", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    var catchId0 = randomId();
    var catchId1 = randomId();
    var catchId2 = randomId();
    var catchId3 = randomId();

    await catchManager.addOrUpdate(Catch()..id = catchId0);
    await catchManager.addOrUpdate(Catch()..id = catchId1);
    await catchManager.addOrUpdate(Catch()..id = catchId2);
    await catchManager.addOrUpdate(Catch()..id = catchId3);

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      catchIds: {catchId2, catchId0},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(
      context,
      catchIds: {randomId()},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by fishing methods", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    var methodId0 = randomId();
    var methodId1 = randomId();
    var methodId2 = randomId();

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..methodIds.add(methodId0));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..methodIds.add(methodId1));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..methodIds.add(methodId1));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..methodIds.add(methodId2));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      methodIds: {methodId1},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(
      context,
      methodIds: {methodId1, methodId2},
    );
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(
      context,
      methodIds: {randomId()},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by multiple things", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    var catchId0 = randomId();

    var speciesId0 = randomId();
    var speciesId1 = randomId();

    var baitId0 = randomId();
    var baitId1 = randomId();

    var fishingSpotId0 = randomId();
    var fishingSpotId1 = randomId();

    await catchManager.addOrUpdate(Catch()
      ..id = catchId0
      ..timestamp = Int64(5000)
      ..speciesId = speciesId0
      ..baitId = baitId0
      ..fishingSpotId = fishingSpotId0);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(10000)
      ..speciesId = speciesId1
      ..baitId = baitId1
      ..fishingSpotId = fishingSpotId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(20000)
      ..speciesId = speciesId1
      ..baitId = baitId0
      ..fishingSpotId = fishingSpotId1);

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      catchIds: {catchId0},
      speciesIds: {speciesId0},
      baitIds: {baitId0},
      fishingSpotIds: {fishingSpotId0},
    );
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(
      context,
      catchIds: {catchId0},
      speciesIds: {randomId()},
      baitIds: {baitId0},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("imageNamesSortedByTimestamp", (tester) async {
    var catch1 = Catch()
      ..id = randomId()
      ..timestamp = Int64(10000);
    catch1.imageNames.addAll(["img0", "img1"]);

    var catch2 = Catch()
      ..id = randomId()
      ..timestamp = Int64(20000);
    catch2.imageNames.addAll(["img2", "img3"]);

    var catch3 = Catch()
      ..id = randomId()
      ..timestamp = Int64(5000);
    catch3.imageNames.add("img4");

    await catchManager.addOrUpdate(catch1,
        imageFiles: catch1.imageNames.map((e) => File(e)).toList());
    await catchManager.addOrUpdate(catch2,
        imageFiles: catch2.imageNames.map((e) => File(e)).toList());
    await catchManager.addOrUpdate(catch3,
        imageFiles: catch3.imageNames.map((e) => File(e)).toList());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.imageNamesSortedByTimestamp(context), [
      "img2",
      "img3",
      "img0",
      "img1",
      "img4",
    ]);
  });

  group("deleteMessage", () {
    testWidgets("No species", (tester) async {
      var cat = Catch()
        ..id = randomId()
        ..timestamp = Int64(DateTime(2020, 9, 25).millisecondsSinceEpoch);

      when(appManager.timeManager.currentDateTime)
          .thenReturn(DateTime(2020, 9, 25));
      var context = await buildContext(tester, appManager: appManager);
      expect(
        catchManager.deleteMessage(context, cat),
        "Are you sure you want to delete catch (Today at 12:00 AM)? "
        "This cannot be undone.",
      );
    });

    testWidgets("With species", (tester) async {
      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      var cat = Catch()
        ..id = randomId()
        ..timestamp = Int64(DateTime(2020, 9, 25).millisecondsSinceEpoch)
        ..speciesId = species.id;

      when(speciesManager.entity(any)).thenReturn(species);
      when(appManager.timeManager.currentDateTime)
          .thenReturn(DateTime(2020, 9, 25));
      var context = await buildContext(tester, appManager: appManager);
      expect(
        catchManager.deleteMessage(context, cat),
        "Are you sure you want to delete catch Steelhead (Today at 12:00 AM)? "
        "This cannot be undone.",
      );
    });
  });
}
