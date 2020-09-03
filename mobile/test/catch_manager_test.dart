import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/custom_entity_value_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mockito/mockito.dart';

import 'test_utils.dart';

class MockAppManager extends Mock implements AppManager {}
class MockBaitCategoryManager extends Mock implements BaitCategoryManager {}
class MockBaitManager extends Mock implements BaitManager {}
class MockCatchListener extends Mock implements EntityListener<Catch> {}
class MockCustomEntityValueManager extends Mock
    implements CustomEntityValueManager {}
class MockDataManager extends Mock implements DataManager {}
class MockFishingSpotManager extends Mock implements FishingSpotManager {}
class MockImageManager extends Mock implements ImageManager {}
class MockSpeciesManager extends Mock implements SpeciesManager {}

void main() {
  MockAppManager appManager;
  MockBaitCategoryManager baitCategoryManager;
  MockCustomEntityValueManager entityValueManager;
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
    when(dataManager.insertOrUpdateEntity(any, any)).thenAnswer((_) =>
        Future.value(true));

    baitCategoryManager = MockBaitCategoryManager();
    when(appManager.baitCategoryManager).thenReturn(baitCategoryManager);
    when(baitCategoryManager.addListener(any)).thenAnswer((_) {});

    entityValueManager = MockCustomEntityValueManager();
    when(appManager.customEntityValueManager).thenReturn(entityValueManager);
    when(entityValueManager.setValues(any, any)).thenAnswer((_) => null);

    imageManager = MockImageManager();
    when(appManager.imageManager).thenReturn(imageManager);
    when(imageManager.save(any, any)).thenAnswer((_) => null);

    fishingSpotManager = FishingSpotManager(appManager);
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);

    baitManager = BaitManager(appManager);
    when(appManager.baitManager).thenReturn(baitManager);
    
    speciesManager = MockSpeciesManager();
    when(appManager.speciesManager).thenReturn(speciesManager);

    catchManager = CatchManager(appManager);
  });

  test("When a bait is deleted, existing catches are updated", () async {
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    MockCatchListener catchListener = MockCatchListener();
    when(catchListener.onDelete).thenReturn((_) {});
    when(catchListener.onAddOrUpdate).thenReturn(() {});
    catchManager.addListener(catchListener);

    Bait bait = Bait(id: "bait_id", name: "Rapala");
    await baitManager.addOrUpdate(bait);

    // Stub database has nothing to update.
    when(dataManager.rawUpdate(any, any))
        .thenAnswer((_) => Future.value(false));

    // Verify listeners aren't notified.
    await baitManager.delete(bait);
    await untilCalled(dataManager.rawUpdate(any, any));
    verify(dataManager.rawUpdate(any, any)).called(1);
    verifyNever(catchListener.onAddOrUpdate);

    // Stub database does an update.
    when(dataManager.rawUpdate(any, any))
        .thenAnswer((_) => Future.value(true));

    await baitManager.addOrUpdate(bait);
    await catchManager.addOrUpdate(Catch(
      id: "catch_id",
      timestamp: 5,
      baitId: "bait_id",
      speciesId: "species_id",
    ));
    await catchManager.addOrUpdate(Catch(
      id: "catch_id_2",
      timestamp: 5,
      baitId: "bait_id",
      speciesId: "species_id_2",
    ));
    verify(catchListener.onAddOrUpdate).called(2);
    expect(catchManager.entity(id: "catch_id").baitId, "bait_id");
    expect(catchManager.entity(id: "catch_id_2").baitId, "bait_id");

    await baitManager.delete(bait);
    await untilCalled(dataManager.rawUpdate(any, any));
    verify(dataManager.rawUpdate(any, any)).called(1);

    // Verify listeners are notified and memory cache updated.
    verify(catchListener.onAddOrUpdate).called(1);
    expect(catchManager.entity(id: "catch_id").baitId, isNull);
    expect(catchManager.entity(id: "catch_id_2").baitId, isNull);
  });

  test("When a fishing spot is deleted, existing catches are updated", () async
  {
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    MockCatchListener catchListener = MockCatchListener();
    when(catchListener.onDelete).thenReturn((_) { });
    when(catchListener.onAddOrUpdate).thenReturn(() { });
    catchManager.addListener(catchListener);

    FishingSpot fishingSpot = FishingSpot(
      id: "fishing_spot_id",
      lat: 0.0,
      lng: 0.0,
    );
    await fishingSpotManager.addOrUpdate(fishingSpot);

    // Stub database has nothing to update.
    when(dataManager.rawUpdate(any, any))
        .thenAnswer((_) => Future.value(false));

    // Verify listeners aren't notified.
    await fishingSpotManager.delete(fishingSpot);
    await untilCalled(dataManager.rawUpdate(any, any));
    verify(dataManager.rawUpdate(any, any)).called(1);
    verifyNever(catchListener.onAddOrUpdate);

    // Stub database does an update.
    when(dataManager.rawUpdate(any, any))
        .thenAnswer((_) => Future.value(true));

    await fishingSpotManager.addOrUpdate(fishingSpot);
    await catchManager.addOrUpdate(Catch(
      id: "catch_id",
      timestamp: 5,
      baitId: "bait_id",
      speciesId: "species_id",
      fishingSpotId: "fishing_spot_id",
    ));
    await catchManager.addOrUpdate(Catch(
      id: "catch_id_2",
      timestamp: 5,
      baitId: "bait_id_2",
      speciesId: "species_id_2",
      fishingSpotId: "fishing_spot_id",
    ));
    verify(catchListener.onAddOrUpdate).called(2);
    expect(catchManager.entity(id: "catch_id").fishingSpotId,
        "fishing_spot_id");
    expect(catchManager.entity(id: "catch_id_2").fishingSpotId,
        "fishing_spot_id");

    await fishingSpotManager.delete(fishingSpot);
    await untilCalled(dataManager.rawUpdate(any, any));
    verify(dataManager.rawUpdate(any, any)).called(1);

    // Verify listeners are notified and memory cache updated.
    verify(catchListener.onAddOrUpdate).called(1);
    expect(catchManager.entity(id: "catch_id").fishingSpotId, isNull);
    expect(catchManager.entity(id: "catch_id_2").fishingSpotId, isNull);
  });

  testWidgets("Filtering by search query", (WidgetTester tester) async {
    var mockFishingSpotManager = MockFishingSpotManager();
    when(mockFishingSpotManager.addOrUpdate(any)).thenAnswer((_) => null);
    when(appManager.fishingSpotManager).thenReturn(mockFishingSpotManager);

    var mockBaitManager = MockBaitManager();
    when(appManager.baitManager).thenReturn(mockBaitManager);

    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch(
      timestamp: DateTime(2020, 1, 1).millisecondsSinceEpoch,
      speciesId: "species_id_1",
    ));
    await catchManager.addOrUpdate(Catch(
      timestamp: DateTime(2020, 4, 4).millisecondsSinceEpoch,
      speciesId: "species_id_2",
    ));

    when(speciesManager.entity(id: argThat(equals("species_id_1"),
      named: "id",
    ))).thenReturn(Species(name: "Smallmouth Bass"));
    when(speciesManager.entity(id: argThat(equals("species_id_2"),
      named: "id",
    ))).thenReturn(Species(name: "Blue Catfish"));

    BuildContext context = await buildContext(tester);

    List<Catch> catches = catchManager.filteredCatches(context, filter: "");
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context, filter: "Bluegill");
    expect(true, catches.isEmpty);

    catches = catchManager.filteredCatches(context, filter: "bass");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, filter: "BLUE");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, filter: "janua");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, filter: "april");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, filter: "4");
    expect(catches.length, 1);

    await catchManager.addOrUpdate(Catch(
      timestamp: DateTime(2020, 1, 1).millisecondsSinceEpoch,
      speciesId: "species_id_1",
      fishingSpotId: "fishing_spot_id_1",
      baitId: "bait_id_1",
    ));
    await catchManager.addOrUpdate(Catch(
      timestamp: DateTime(2020, 2, 2).millisecondsSinceEpoch,
      speciesId: "species_id_2",
      fishingSpotId: "fishing_spot_id_2",
      baitId: "bait_id_2",
    ));

    when(mockFishingSpotManager.entity(id: argThat(equals("fishing_spot_id_1"),
      named: "id",
    ))).thenReturn(FishingSpot(name: "Tennessee River", lat: 0.0, lng: 0.0));
    when(mockFishingSpotManager.entity(id: argThat(equals("fishing_spot_id_2"),
      named: "id",
    ))).thenReturn(FishingSpot(name: "9 Mile River", lat: 0.0, lng: 0.0));

    when(mockBaitManager.matchesFilter("bait_id_1", any)).thenReturn(false);

    when(mockBaitManager.matchesFilter(any, any)).thenReturn(true);
    catches = catchManager.filteredCatches(context, filter: "RAP");
    expect(catches.length, 2);

    when(mockBaitManager.matchesFilter(any, any)).thenReturn(false);
    catches = catchManager.filteredCatches(context, filter: "test");
    expect(true, catches.isEmpty);

    catches = catchManager.filteredCatches(context, filter: "9 mile");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, filter: "Tennessee");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, filter: "River");
    expect(catches.length, 2);
  });

  testWidgets("Filtering by species", (WidgetTester tester) async {
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch(
      timestamp: DateTime(2020, 1, 1).millisecondsSinceEpoch,
      speciesId: "species_id_1",
    ));
    await catchManager.addOrUpdate(Catch(
      timestamp: DateTime(2020, 2, 2).millisecondsSinceEpoch,
      speciesId: "species_id_2",
    ));
    await catchManager.addOrUpdate(Catch(
      timestamp: DateTime(2020, 2, 2).millisecondsSinceEpoch,
      speciesId: "species_id_2",
    ));
    await catchManager.addOrUpdate(Catch(
      timestamp: DateTime(2020, 4, 4).millisecondsSinceEpoch,
      speciesId: "species_id_4",
    ));

    BuildContext context = await buildContext(tester);
    List<Catch> catches = catchManager.filteredCatches(context,
      speciesIds: {"species_id_2"},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context,
      speciesIds: {
        "species_id_2",
        "species_id_4",
      },
    );
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(context,
      speciesIds: {"species_id_3"},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by date range", (WidgetTester tester) async {
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch(
      timestamp: 5000,
      speciesId: "species_id_1",
    ));
    await catchManager.addOrUpdate(Catch(
      timestamp: 10000,
      speciesId: "species_id_2",
    ));
    await catchManager.addOrUpdate(Catch(
      timestamp: 20000,
      speciesId: "species_id_2",
    ));

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
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch(
      timestamp: 5000,
      speciesId: "species_id_1",
      fishingSpotId: "fishing_spot_1",
    ));
    await catchManager.addOrUpdate(Catch(
      timestamp: 10000,
      speciesId: "species_id_2",
      fishingSpotId: "fishing_spot_2",
    ));
    await catchManager.addOrUpdate(Catch(
      timestamp: 20000,
      speciesId: "species_id_2",
      fishingSpotId: "fishing_spot_1",
    ));
    await catchManager.addOrUpdate(Catch(
      timestamp: 40000,
      speciesId: "species_id_2",
      fishingSpotId: "fishing_spot_4",
    ));

    BuildContext context = await buildContext(tester);
    List<Catch> catches = catchManager.filteredCatches(context,
      fishingSpotIds: {"fishing_spot_1"},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context,
      fishingSpotIds: {
        "fishing_spot_1",
        "fishing_spot_4",
      },
    );
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(context,
      fishingSpotIds: {"fishing_spot_3"},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by bait", (WidgetTester tester) async {
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch(
      timestamp: 5000,
      speciesId: "species_id_1",
      baitId: "bait_1",
    ));
    await catchManager.addOrUpdate(Catch(
      timestamp: 10000,
      speciesId: "species_id_2",
      baitId: "bait_2",
    ));
    await catchManager.addOrUpdate(Catch(
      timestamp: 20000,
      speciesId: "species_id_2",
      baitId: "bait_1",
    ));
    await catchManager.addOrUpdate(Catch(
      timestamp: 40000,
      speciesId: "species_id_3",
      baitId: "bait_4",
    ));

    BuildContext context = await buildContext(tester);
    List<Catch> catches = catchManager.filteredCatches(context,
      baitIds: {"bait_1"},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context,
      baitIds: {
        "bait_1",
        "bait_4",
      },
    );
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(context,
      baitIds: {"bait_3"},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by catch", (WidgetTester tester) async {
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch(
      id: "0",
      timestamp: 5000,
      speciesId: "species_id_1",
      baitId: "bait_1",
    ));
    await catchManager.addOrUpdate(Catch(
      id: "1",
      timestamp: 10000,
      speciesId: "species_id_2",
      baitId: "bait_2",
    ));
    await catchManager.addOrUpdate(Catch(
      id: "2",
      timestamp: 20000,
      speciesId: "species_id_2",
      baitId: "bait_1",
    ));
    await catchManager.addOrUpdate(Catch(
      id: "3",
      timestamp: 40000,
      speciesId: "species_id_3",
      baitId: "bait_4",
    ));

    BuildContext context = await buildContext(tester);
    List<Catch> catches = catchManager.filteredCatches(context,
      catchIds: {"3", "1"},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(context,
      catchIds: {"8"},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by multiple things", (WidgetTester tester) async {
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch(
      id: "0",
      timestamp: 5000,
      speciesId: "species_id_1",
      baitId: "bait_1",
    ));
    await catchManager.addOrUpdate(Catch(
      id: "1",
      timestamp: 10000,
      speciesId: "species_id_2",
      baitId: "bait_2",
    ));
    await catchManager.addOrUpdate(Catch(
      id: "2",
      timestamp: 20000,
      speciesId: "species_id_2",
      baitId: "bait_1",
    ));

    BuildContext context = await buildContext(tester);
    List<Catch> catches = catchManager.filteredCatches(context,
      catchIds: {"0"},
      speciesIds: {"species_id_1"},
      baitIds: {"bait_1"},
    );
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(context,
      catchIds: {"0"},
      speciesIds: {"species_id_4"},
      baitIds: {"bait_1"},
    );
    expect(catches.isEmpty, true);
  });
}