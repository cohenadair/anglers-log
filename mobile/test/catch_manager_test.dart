import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/gen/google/protobuf/timestamp.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'test_utils.dart';

class MockAppManager extends Mock implements AppManager {}
class MockBaitCategoryManager extends Mock implements BaitCategoryManager {}
class MockBaitManager extends Mock implements BaitManager {}
class MockCatchListener extends Mock implements EntityListener<Catch> {}
class MockDataManager extends Mock implements DataManager {}
class MockFishingSpotManager extends Mock implements FishingSpotManager {}
class MockImageManager extends Mock implements ImageManager {}
class MockSpeciesManager extends Mock implements SpeciesManager {}

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
    appManager = MockAppManager();

    dataManager = MockDataManager();
    when(appManager.dataManager).thenReturn(dataManager);
    when(dataManager.insertOrUpdateEntity(any, any, any)).thenAnswer((_) =>
        Future.value(true));

    baitCategoryManager = MockBaitCategoryManager();
    when(appManager.baitCategoryManager).thenReturn(baitCategoryManager);
    when(baitCategoryManager.addListener(any)).thenAnswer((_) {});

    imageManager = MockImageManager();
    when(appManager.imageManager).thenReturn(imageManager);
    when(imageManager
        .save(any, compress: anyNamed("compress")))
        .thenAnswer((_) => Future.value([]));

    fishingSpotManager = FishingSpotManager(appManager);
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);

    baitManager = BaitManager(appManager);
    when(appManager.baitManager).thenReturn(baitManager);
    
    speciesManager = MockSpeciesManager();
    when(appManager.speciesManager).thenReturn(speciesManager);

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
    Id baitId0 = Id.random();
    Bait bait = Bait()
      ..id = baitId0.bytes
      ..name = "Rapala";
    await baitManager.addOrUpdate(bait);

    // Add a couple catches that use the new bait.
    Id catchId0 = Id.random();
    Id catchId1 = Id.random();
    await catchManager.addOrUpdate(Catch()
      ..id = catchId0.bytes
      ..baitId = baitId0.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = catchId1.bytes
      ..baitId = baitId0.bytes);
    verify(catchListener.onAddOrUpdate).called(2);
    expect(catchManager.entity(catchId0).baitId, baitId0.bytes);
    expect(catchManager.entity(catchId1).baitId, baitId0.bytes);

    // Delete the new bait.
    await baitManager.delete(baitId0);

    // Verify listeners are notified and memory cache updated.
    verify(catchListener.onAddOrUpdate).called(1);
    expect(catchManager.entity(catchId0).baitId, isEmpty);
    expect(catchManager.entity(catchId1).baitId, isEmpty);
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
    Id fishingSpotId0 = Id.random();
    FishingSpot fishingSpot = FishingSpot()
      ..id = fishingSpotId0.bytes;
    await fishingSpotManager.addOrUpdate(fishingSpot);

    // Add a couple catches that use the new fishing spot.
    Id catchId0 = Id.random();
    Id catchId1 = Id.random();
    await catchManager.addOrUpdate(Catch()
      ..id = catchId0.bytes
      ..fishingSpotId = fishingSpotId0.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = catchId1.bytes
      ..fishingSpotId = fishingSpotId0.bytes);
    verify(catchListener.onAddOrUpdate).called(2);
    expect(catchManager.entity(catchId0).fishingSpotId, fishingSpotId0.bytes);
    expect(catchManager.entity(catchId1).fishingSpotId, fishingSpotId0.bytes);

    // Delete the new fishing spot.
    await fishingSpotManager.delete(fishingSpotId0);

    // Verify listeners are notified and memory cache updated.
    verify(catchListener.onAddOrUpdate).called(1);
    expect(catchManager.entity(catchId0).fishingSpotId, isEmpty);
    expect(catchManager.entity(catchId1).fishingSpotId, isEmpty);
  });

  testWidgets("Filtering by search query; non-ID reference properties",
      (WidgetTester tester) async
  {
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..timestamp = Timestamp.fromDateTime(DateTime(2020, 1, 1)));
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..timestamp = Timestamp.fromDateTime(DateTime(2020, 4, 4)));

    BuildContext context = await buildContext(tester);

    List<Catch> catches = catchManager.filteredCatches(context, filter: "");
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context, filter: "janua");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, filter: "april");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, filter: "4");
    expect(catches.length, 1);

    // TODO: Test custom entity values
  });

  testWidgets("Filtering by search query; bait", (WidgetTester tester) async {
    var baitManager = MockBaitManager();
    when(appManager.baitManager).thenReturn(baitManager);
    when(baitManager.matchesFilter(any, any)).thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..baitId = Id.random().bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..baitId = Id.random().bytes);

    BuildContext context = await buildContext(tester);
    expect(catchManager.filteredCatches(context, filter: "Bait").length, 2);
  });

  testWidgets("Filtering by search query; fishing spot", (WidgetTester tester)
      async
  {
    var fishingSpotManager = MockFishingSpotManager();
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);
    when(fishingSpotManager.matchesFilter(any, any)).thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..fishingSpotId = Id.random().bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..fishingSpotId = Id.random().bytes);

    BuildContext context = await buildContext(tester);
    expect(catchManager.filteredCatches(context, filter: "Spot").length, 2);
  });

  testWidgets("Filtering by search query; species", (WidgetTester tester)
      async
  {
    var speciesManager = MockSpeciesManager();
    when(appManager.speciesManager).thenReturn(speciesManager);
    when(speciesManager.matchesFilter(any, any)).thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..speciesId = Id.random().bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..speciesId = Id.random().bytes);

    BuildContext context = await buildContext(tester);
    expect(catchManager.filteredCatches(context, filter: "Species").length, 2);
  });

  testWidgets("Filtering by species", (WidgetTester tester) async {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    Id speciesId0 = Id.random();
    Id speciesId1 = Id.random();
    Id speciesId2 = Id.random();

    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..timestamp = Timestamp.fromDateTime(DateTime(2020, 1, 1))
      ..speciesId = speciesId0.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..timestamp = Timestamp.fromDateTime(DateTime(2020, 2, 2))
      ..speciesId = speciesId1.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..timestamp = Timestamp.fromDateTime(DateTime(2020, 2, 2))
      ..speciesId = speciesId1.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..timestamp = Timestamp.fromDateTime(DateTime(2020, 4, 4))
      ..speciesId = speciesId2.bytes);

    BuildContext context = await buildContext(tester);
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
      speciesIds: {Id.random()},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by date range", (WidgetTester tester) async {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..timestamp = Timestamps.fromMillis(5000));
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..timestamp = Timestamps.fromMillis(10000));
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..timestamp = Timestamps.fromMillis(20000));

    BuildContext context = await buildContext(tester);
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

    Id fishingSpotId0 = Id.random();
    Id fishingSpotId1 = Id.random();
    Id fishingSpotId2 = Id.random();
    Id fishingSpotId3 = Id.random();

    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..fishingSpotId = fishingSpotId0.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..fishingSpotId = fishingSpotId1.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..fishingSpotId = fishingSpotId0.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..fishingSpotId = fishingSpotId3.bytes);

    BuildContext context = await buildContext(tester);
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

    Id baitId0 = Id.random();
    Id baitId1 = Id.random();
    Id baitId2 = Id.random();
    Id baitId3 = Id.random();

    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..baitId = baitId0.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..baitId = baitId1.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..baitId = baitId0.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..baitId = baitId3.bytes);

    BuildContext context = await buildContext(tester);
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

    Id catchId0 = Id.random();
    Id catchId1 = Id.random();
    Id catchId2 = Id.random();
    Id catchId3 = Id.random();

    await catchManager.addOrUpdate(Catch()
      ..id = catchId0.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = catchId1.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = catchId2.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = catchId3.bytes);

    BuildContext context = await buildContext(tester);
    List<Catch> catches = catchManager.filteredCatches(context,
      catchIds: {catchId2, catchId0},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(context,
      catchIds: {Id.random()},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by multiple things", (WidgetTester tester) async {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    Id catchId0 = Id.random();

    Id speciesId0 = Id.random();
    Id speciesId1 = Id.random();

    Id baitId0 = Id.random();
    Id baitId1 = Id.random();

    Id fishingSpotId0 = Id.random();
    Id fishingSpotId1 = Id.random();

    await catchManager.addOrUpdate(Catch()
      ..id = catchId0.bytes
      ..timestamp = Timestamps.fromMillis(5000)
      ..speciesId = speciesId0.bytes
      ..baitId = baitId0.bytes
      ..fishingSpotId = fishingSpotId0.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..timestamp = Timestamps.fromMillis(10000)
      ..speciesId = speciesId1.bytes
      ..baitId = baitId1.bytes
      ..fishingSpotId = fishingSpotId1.bytes);
    await catchManager.addOrUpdate(Catch()
      ..id = Id.random().bytes
      ..timestamp = Timestamps.fromMillis(20000)
      ..speciesId = speciesId1.bytes
      ..baitId = baitId0.bytes
      ..fishingSpotId = fishingSpotId1.bytes);

    BuildContext context = await buildContext(tester);
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
      speciesIds: {Id.random()},
      baitIds: {baitId0},
    );
    expect(catches.isEmpty, true);
  });

  // TODO: Add test for imageNamesSortedByTimestamp
  // TODO: Add test for addOrUpdate; specifically, images
}