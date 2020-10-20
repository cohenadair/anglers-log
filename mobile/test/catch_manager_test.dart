import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/gen/google/protobuf/timestamp.pb.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

class MockCatchListener extends Mock implements EntityListener<Catch> {}

void main() {
  MockAppManager appManager;
  MockBaitCategoryManager baitCategoryManager;
  MockDataManager dataManager;
  MockImageManager imageManager;
  MockSpeciesManager speciesManager;
  BaitManager baitManager;
  CatchManager catchManager;
  FishingSpotManager fishingSpotManager;

  setUp(() {
    appManager = MockAppManager(
      mockBaitCategoryManager: true,
      mockDataManager: true,
      mockImageManager: true,
      mockSpeciesManager: true,
      mockTimeManager: true,
    );

    baitCategoryManager = appManager.mockBaitCategoryManager;
    when(appManager.baitCategoryManager).thenReturn(baitCategoryManager);
    when(baitCategoryManager.addListener(any)).thenAnswer((_) {});

    dataManager = appManager.mockDataManager;
    when(appManager.dataManager).thenReturn(dataManager);
    when(dataManager.insertOrUpdateEntity(any, any, any)).thenAnswer((_) =>
        Future.value(true));

    imageManager = appManager.mockImageManager;
    when(appManager.imageManager).thenReturn(imageManager);
    when(imageManager
        .save(any, compress: anyNamed("compress")))
        .thenAnswer((invocation) => Future.value((invocation.positionalArguments
            .first as List<File>)?.map((f) => f.path)?.toList() ?? []));

    fishingSpotManager = FishingSpotManager(appManager);
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);

    baitManager = BaitManager(appManager);
    when(appManager.baitManager).thenReturn(baitManager);
    
    speciesManager = appManager.mockSpeciesManager;
    when(appManager.speciesManager).thenReturn(speciesManager);
    when(speciesManager.matchesFilter(any, any)).thenReturn(false);

    catchManager = CatchManager(appManager);
  });

  test("When a bait is deleted, existing catches are updated", () async {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.replaceRows(any, any)).thenAnswer((_) => Future.value());

    MockCatchListener catchListener = MockCatchListener();
    when(catchListener.onDelete).thenReturn((_) {});
    when(catchListener.onAddOrUpdate).thenReturn(() {});
    catchManager.addListener(catchListener);

    // Add a bait.
    Id baitId0 = randomId();
    Bait bait = Bait()
      ..id = baitId0
      ..name = "Rapala";
    await baitManager.addOrUpdate(bait);

    // Add a couple catches that use the new bait.
    Id catchId0 = randomId();
    Id catchId1 = randomId();
    await catchManager.addOrUpdate(Catch()
      ..id = catchId0
      ..baitId = baitId0);
    await catchManager.addOrUpdate(Catch()
      ..id = catchId1
      ..baitId = baitId0);
    verify(catchListener.onAddOrUpdate).called(2);
    expect(catchManager.entity(catchId0).baitId, baitId0);
    expect(catchManager.entity(catchId1).baitId, baitId0);

    // Delete the new bait.
    await baitManager.delete(baitId0);

    // Verify listeners are notified and memory cache updated.
    verify(catchListener.onAddOrUpdate).called(1);
    expect(catchManager.entity(catchId0).hasBaitId(), false);
    expect(catchManager.entity(catchId1).hasBaitId(), false);
  });

  test("When a fishing spot is deleted, existing catches are updated", () async
  {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.replaceRows(any, any)).thenAnswer((_) => Future.value());

    MockCatchListener catchListener = MockCatchListener();
    when(catchListener.onDelete).thenReturn((_) { });
    when(catchListener.onAddOrUpdate).thenReturn(() { });
    catchManager.addListener(catchListener);

    // Add a fishing spot.
    Id fishingSpotId0 = randomId();
    FishingSpot fishingSpot = FishingSpot()
      ..id = fishingSpotId0;
    await fishingSpotManager.addOrUpdate(fishingSpot);

    // Add a couple catches that use the new fishing spot.
    Id catchId0 = randomId();
    Id catchId1 = randomId();
    await catchManager.addOrUpdate(Catch()
      ..id = catchId0
      ..fishingSpotId = fishingSpotId0);
    await catchManager.addOrUpdate(Catch()
      ..id = catchId1
      ..fishingSpotId = fishingSpotId0);
    verify(catchListener.onAddOrUpdate).called(2);
    expect(catchManager.entity(catchId0).fishingSpotId, fishingSpotId0);
    expect(catchManager.entity(catchId1).fishingSpotId, fishingSpotId0);

    // Delete the new fishing spot.
    await fishingSpotManager.delete(fishingSpotId0);

    // Verify listeners are notified and memory cache updated.
    verify(catchListener.onAddOrUpdate).called(1);
    expect(catchManager.entity(catchId0).hasFishingSpotId(), false);
    expect(catchManager.entity(catchId1).hasFishingSpotId(), false);
  });

  testWidgets("Filtering by search query; non-ID reference properties",
      (WidgetTester tester) async
  {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Timestamp.fromDateTime(DateTime(2020, 1, 1)));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Timestamp.fromDateTime(DateTime(2020, 4, 4)));

    BuildContext context = await buildContext(tester, appManager: appManager);

    List<Catch> catches = catchManager.filteredCatches(context, filter: "");
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context, filter: "janua");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, filter: "april");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, filter: "4");
    expect(catches.length, 1);
  });

  testWidgets("Filtering by search query; bait", (WidgetTester tester) async {
    var baitManager = MockBaitManager();
    when(appManager.baitManager).thenReturn(baitManager);
    when(baitManager.matchesFilter(any, any)).thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baitId = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baitId = randomId());

    BuildContext context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "Bait").length, 2);
  });

  testWidgets("Filtering by search query; fishing spot", (WidgetTester tester)
      async
  {
    var fishingSpotManager = MockFishingSpotManager();
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);
    when(fishingSpotManager.matchesFilter(any, any)).thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..fishingSpotId = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..fishingSpotId = randomId());

    BuildContext context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "Spot").length, 2);
  });

  testWidgets("Filtering by search query; species", (WidgetTester tester)
      async
  {
    var speciesManager = MockSpeciesManager();
    when(appManager.speciesManager).thenReturn(speciesManager);
    when(speciesManager.matchesFilter(any, any)).thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..speciesId = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..speciesId = randomId());

    BuildContext context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "Species").length, 2);
  });

  testWidgets("Filtering by species", (WidgetTester tester) async {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    Id speciesId0 = randomId();
    Id speciesId1 = randomId();
    Id speciesId2 = randomId();

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Timestamp.fromDateTime(DateTime(2020, 1, 1))
      ..speciesId = speciesId0);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Timestamp.fromDateTime(DateTime(2020, 2, 2))
      ..speciesId = speciesId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Timestamp.fromDateTime(DateTime(2020, 2, 2))
      ..speciesId = speciesId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Timestamp.fromDateTime(DateTime(2020, 4, 4))
      ..speciesId = speciesId2);

    BuildContext context = await buildContext(tester, appManager: appManager);
    List<Catch> catches = catchManager.filteredCatches(context,
      speciesIds: {speciesId1},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context,
      speciesIds: {speciesId1, speciesId2},
    );
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(context,
      speciesIds: {randomId()},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by date range", (WidgetTester tester) async {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = timestampFromMillis(5000));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = timestampFromMillis(10000));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = timestampFromMillis(20000));

    BuildContext context = await buildContext(tester, appManager: appManager);
    List<Catch> catches = catchManager.filteredCatches(context,
      dateRange: DateRange(
        startDate: DateTime.fromMillisecondsSinceEpoch(0),
        endDate: DateTime.fromMillisecondsSinceEpoch(15000),
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(context,
      dateRange: DateRange(
        startDate: DateTime.fromMillisecondsSinceEpoch(20001),
        endDate: DateTime.fromMillisecondsSinceEpoch(30000),
      ),
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by fishing spot", (WidgetTester tester) async {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    Id fishingSpotId0 = randomId();
    Id fishingSpotId1 = randomId();
    Id fishingSpotId2 = randomId();
    Id fishingSpotId3 = randomId();

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

    BuildContext context = await buildContext(tester, appManager: appManager);
    List<Catch> catches = catchManager.filteredCatches(context,
      fishingSpotIds: {fishingSpotId0},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context,
      fishingSpotIds: {fishingSpotId0, fishingSpotId3},
    );
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(context,
      fishingSpotIds: {fishingSpotId2},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by bait", (WidgetTester tester) async {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    Id baitId0 = randomId();
    Id baitId1 = randomId();
    Id baitId2 = randomId();
    Id baitId3 = randomId();

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

    BuildContext context = await buildContext(tester, appManager: appManager);
    List<Catch> catches = catchManager.filteredCatches(context,
      baitIds: {baitId0},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context,
      baitIds: {baitId0, baitId3},
    );
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(context,
      baitIds: {baitId2},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by catch", (WidgetTester tester) async {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    Id catchId0 = randomId();
    Id catchId1 = randomId();
    Id catchId2 = randomId();
    Id catchId3 = randomId();

    await catchManager.addOrUpdate(Catch()
      ..id = catchId0);
    await catchManager.addOrUpdate(Catch()
      ..id = catchId1);
    await catchManager.addOrUpdate(Catch()
      ..id = catchId2);
    await catchManager.addOrUpdate(Catch()
      ..id = catchId3);

    BuildContext context = await buildContext(tester, appManager: appManager);
    List<Catch> catches = catchManager.filteredCatches(context,
      catchIds: {catchId2, catchId0},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(context,
      catchIds: {randomId()},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by multiple things", (WidgetTester tester) async {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    Id catchId0 = randomId();

    Id speciesId0 = randomId();
    Id speciesId1 = randomId();

    Id baitId0 = randomId();
    Id baitId1 = randomId();

    Id fishingSpotId0 = randomId();
    Id fishingSpotId1 = randomId();

    await catchManager.addOrUpdate(Catch()
      ..id = catchId0
      ..timestamp = timestampFromMillis(5000)
      ..speciesId = speciesId0
      ..baitId = baitId0
      ..fishingSpotId = fishingSpotId0);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = timestampFromMillis(10000)
      ..speciesId = speciesId1
      ..baitId = baitId1
      ..fishingSpotId = fishingSpotId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = timestampFromMillis(20000)
      ..speciesId = speciesId1
      ..baitId = baitId0
      ..fishingSpotId = fishingSpotId1);

    BuildContext context = await buildContext(tester, appManager: appManager);
    List<Catch> catches = catchManager.filteredCatches(context,
      catchIds: {catchId0},
      speciesIds: {speciesId0},
      baitIds: {baitId0},
      fishingSpotIds: {fishingSpotId0},
    );
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(context,
      catchIds: {catchId0},
      speciesIds: {randomId()},
      baitIds: {baitId0},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("imageNamesSortedByTimestamp", (WidgetTester tester) async {
    Catch catch1 = Catch()
      ..id = randomId()
      ..timestamp = timestampFromMillis(10000);
    catch1.imageNames.addAll(["img0", "img1"]);

    Catch catch2 = Catch()
      ..id = randomId()
      ..timestamp = timestampFromMillis(20000);
    catch2.imageNames.addAll(["img2", "img3"]);

    Catch catch3 = Catch()
      ..id = randomId()
      ..timestamp = timestampFromMillis(5000);
    catch3.imageNames.add("img4");

    await catchManager.addOrUpdate(catch1,
        imageFiles: catch1.imageNames.map((e) => File(e)).toList());
    await catchManager.addOrUpdate(catch2,
        imageFiles: catch2.imageNames.map((e) => File(e)).toList());
    await catchManager.addOrUpdate(catch3,
        imageFiles: catch3.imageNames.map((e) => File(e)).toList());

    BuildContext context = await buildContext(tester, appManager: appManager);
    expect(catchManager.imageNamesSortedByTimestamp(context), [
      "img2", "img3", "img0", "img1", "img4",
    ]);
  });

  group("deleteMessage", () {
    testWidgets("Input", (WidgetTester tester) async {
      expect(() => catchManager.deleteMessage(null, Catch()
        ..id = randomId()
      ), throwsAssertionError);

      BuildContext context = await buildContext(tester, appManager: appManager);
      expect(() => baitManager.deleteMessage(context, null),
          throwsAssertionError);
    });

    testWidgets("No species", (WidgetTester tester) async {
      Catch cat = Catch()
        ..id = randomId()
        ..timestamp = Timestamp.fromDateTime(DateTime(2020, 9, 25));

      when(appManager.mockTimeManager.currentDateTime).thenReturn(DateTime(2020, 9, 25));
      BuildContext context = await buildContext(tester, appManager: appManager);
      expect(catchManager.deleteMessage(context, cat),
          "Are you sure you want to delete catch (Today at 4:00 AM)? "
              "This cannot be undone.");
    });

    testWidgets("With species", (WidgetTester tester) async {
      Species species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      Catch cat = Catch()
        ..id = randomId()
        ..timestamp = Timestamp.fromDateTime(DateTime(2020, 9, 25))
        ..speciesId = species.id;

      when(speciesManager.entity(any)).thenReturn(species);
      when(appManager.mockTimeManager.currentDateTime).thenReturn(DateTime(2020, 9, 25));
      BuildContext context = await buildContext(tester, appManager: appManager);
      expect(catchManager.deleteMessage(context, cat),
          "Are you sure you want to delete catch Steelhead (Today at 4:00 AM)? "
              "This cannot be undone.");
    });
  });
}