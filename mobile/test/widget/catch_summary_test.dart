import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/method_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/water_clarity_manager.dart';
import 'package:mobile/widgets/catch_summary.dart';
import 'package:mobile/widgets/date_range_picker_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/tile.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';
import 'package:protobuf/protobuf.dart';
import 'package:quiver/strings.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late MockAnglerManager anglerManager;
  late MockBaitManager baitManager;
  late MockBodyOfWaterManager bodyOfWaterManager;
  late MockCatchManager catchManager;
  late MockFishingSpotManager fishingSpotManager;
  late MockMethodManager methodManager;
  late MockSpeciesManager speciesManager;
  late MockWaterClarityManager waterClarityManager;
  late MockGearManager gearManager;

  late List<Catch> catches;

  var anglerId0 = randomId();
  var anglerId1 = randomId();
  var anglerId2 = randomId();
  var anglerId3 = randomId();
  var anglerId4 = randomId();

  var speciesId0 = randomId();
  var speciesId1 = randomId();
  var speciesId2 = randomId();
  var speciesId3 = randomId();
  var speciesId4 = randomId();

  var fishingSpotId0 = randomId();
  var fishingSpotId1 = randomId();
  var fishingSpotId2 = randomId();
  var fishingSpotId3 = randomId();
  var fishingSpotId4 = randomId();

  var bodyOfWaterId0 = randomId();
  var bodyOfWaterId1 = randomId();
  var bodyOfWaterId2 = randomId();
  var bodyOfWaterId3 = randomId();
  var bodyOfWaterId4 = randomId();

  var methodId0 = randomId();
  var methodId1 = randomId();
  var methodId2 = randomId();
  var methodId3 = randomId();
  var methodId4 = randomId();

  var baitId0 = randomId();
  var baitId1 = randomId();
  var baitId2 = randomId();
  var baitId3 = randomId();
  var baitId4 = randomId();

  var baitVariantId0 = randomId();
  var baitVariantId1 = randomId();

  var baitAttachment0 = BaitAttachment(
    baitId: baitId0,
    variantId: baitVariantId0,
  );
  var baitAttachment1 = BaitAttachment(
    baitId: baitId1,
    variantId: baitVariantId1,
  );
  var baitAttachment2 = BaitAttachment(baitId: baitId2);
  var baitAttachment4 = BaitAttachment(baitId: baitId4);

  var clarityId0 = randomId();
  var clarityId1 = randomId();
  var clarityId2 = randomId();
  var clarityId3 = randomId();
  var clarityId4 = randomId();

  var gearId0 = randomId();
  var gearId1 = randomId();

  var catchId0 = randomId();
  var catchId1 = randomId();
  var catchId2 = randomId();
  var catchId3 = randomId();
  var catchId4 = randomId();
  var catchId5 = randomId();
  var catchId6 = randomId();
  var catchId7 = randomId();
  var catchId8 = randomId();
  var catchId9 = randomId();

  var anglerMap = <Id, Angler>{
    anglerId0: Angler()
      ..id = anglerId0
      ..name = "Cohen",
    anglerId1: Angler()
      ..id = anglerId1
      ..name = "Eli",
    anglerId2: Angler()
      ..id = anglerId2
      ..name = "Ethan",
    anglerId3: Angler()
      ..id = anglerId3
      ..name = "Tim",
    anglerId4: Angler()
      ..id = anglerId4
      ..name = "Someone",
  };

  var speciesMap = <Id, Species>{
    speciesId0: Species()
      ..id = speciesId0
      ..name = "Bluegill",
    speciesId1: Species()
      ..id = speciesId1
      ..name = "Pike",
    speciesId2: Species()
      ..id = speciesId2
      ..name = "Catfish",
    speciesId3: Species()
      ..id = speciesId3
      ..name = "Bass",
    speciesId4: Species()
      ..id = speciesId4
      ..name = "Steelhead",
  };

  var fishingSpotMap = <Id, FishingSpot>{
    fishingSpotId0: FishingSpot()
      ..id = fishingSpotId0
      ..name = "E"
      ..lat = 0.4
      ..lng = 0.0
      ..bodyOfWaterId = bodyOfWaterId0,
    fishingSpotId1: FishingSpot()
      ..id = fishingSpotId1
      ..name = "C"
      ..lat = 0.2
      ..lng = 0.2
      ..bodyOfWaterId = bodyOfWaterId1,
    fishingSpotId2: FishingSpot()
      ..id = fishingSpotId2
      ..name = "B"
      ..lat = 0.1
      ..lng = 0.3
      ..bodyOfWaterId = bodyOfWaterId2,
    fishingSpotId3: FishingSpot()
      ..id = fishingSpotId3
      ..name = "D"
      ..lat = 0.3
      ..lng = 0.1
      ..bodyOfWaterId = bodyOfWaterId3,
    fishingSpotId4: FishingSpot()
      ..id = fishingSpotId4
      ..name = "A"
      ..lat = 0.0
      ..lng = 0.4
      ..bodyOfWaterId = bodyOfWaterId4,
  };

  var bodyOfWaterMap = <Id, BodyOfWater>{
    bodyOfWaterId0: BodyOfWater()
      ..id = bodyOfWaterId0
      ..name = "Lake Huron",
    bodyOfWaterId1: BodyOfWater()
      ..id = bodyOfWaterId1
      ..name = "Tennessee River",
    bodyOfWaterId2: BodyOfWater()
      ..id = bodyOfWaterId2
      ..name = "Bow River",
    bodyOfWaterId3: BodyOfWater()
      ..id = bodyOfWaterId3
      ..name = "Nine Mile River",
    bodyOfWaterId4: BodyOfWater()
      ..id = bodyOfWaterId4
      ..name = "Maitland River",
  };

  var methodMap = <Id, Method>{
    methodId0: Method()
      ..id = methodId0
      ..name = "Casting",
    methodId1: Method()
      ..id = methodId1
      ..name = "Shore",
    methodId2: Method()
      ..id = methodId2
      ..name = "Kayak",
    methodId3: Method()
      ..id = methodId3
      ..name = "Drift",
    methodId4: Method()
      ..id = methodId4
      ..name = "Ice",
  };

  var baitMap = <Id, Bait>{
    baitId0: Bait()
      ..id = baitId0
      ..name = "Worm"
      ..variants.add(BaitVariant(
        id: baitVariantId0,
        baseId: baitId0,
        color: "Brown",
      )),
    baitId1: Bait()
      ..id = baitId1
      ..name = "Bugger"
      ..variants.add(BaitVariant(
        id: baitVariantId1,
        baseId: baitId1,
        color: "Olive",
      )),
    baitId2: Bait()
      ..id = baitId2
      ..name = "Minnow",
    baitId3: Bait()
      ..id = baitId3
      ..name = "Grasshopper",
    baitId4: Bait()
      ..id = baitId4
      ..name = "Grub",
  };

  var clarityMap = <Id, WaterClarity>{
    clarityId0: WaterClarity()
      ..id = clarityId0
      ..name = "Clear",
    clarityId1: WaterClarity()
      ..id = clarityId1
      ..name = "Tea Stained",
    clarityId2: WaterClarity()
      ..id = clarityId2
      ..name = "Chocolate Milk",
    clarityId3: WaterClarity()
      ..id = clarityId3
      ..name = "Crystal",
    clarityId4: WaterClarity()
      ..id = clarityId4
      ..name = "1 Foot",
  };

  var gearMap = <Id, Gear>{
    gearId0: Gear()
      ..id = gearId0
      ..name = "Bass Rod",
    gearId1: Gear()
      ..id = gearId1
      ..name = "Pike Rod",
  };

  CatchFilterOptions optionsWithEverything() {
    return CatchFilterOptions(
      currentTimestamp: Int64(appManager.timeManager.currentTimestamp),
      currentTimeZone: appManager.timeManager.currentTimeZone,
      dateRanges: [
        DateRange(
          period: DateRange_Period.allDates,
          timeZone: appManager.timeManager.currentTimeZone,
        )
      ],
      allBaits: baitMap.map((key, value) => MapEntry(key.uuid, value)),
      allAnglers: anglerMap.map((key, value) => MapEntry(key.uuid, value)),
      allGear: gearMap.map((key, value) => MapEntry(key.uuid, value)),
      allBodiesOfWater:
          bodyOfWaterMap.map((key, value) => MapEntry(key.uuid, value)),
      allMethods: methodMap.map((key, value) => MapEntry(key.uuid, value)),
      allFishingSpots:
          fishingSpotMap.map((key, value) => MapEntry(key.uuid, value)),
      allSpecies: speciesMap.map((key, value) => MapEntry(key.uuid, value)),
      allWaterClarities:
          clarityMap.map((key, value) => MapEntry(key.uuid, value)),
      includeBaits: true,
      includeAnglers: true,
      includeBodiesOfWater: true,
      includeMethods: true,
      includeFishingSpots: true,
      includeMoonPhases: true,
      includePeriods: true,
      includeSeasons: true,
      includeSpecies: true,
      includeTideTypes: true,
      includeWaterClarities: true,
    );
  }

  void resetCatches() {
    catches = [
      Catch()
        ..id = catchId0
        ..timestamp = Int64(10)
        ..speciesId = speciesId3
        ..fishingSpotId = fishingSpotId1
        ..baits.add(baitAttachment0)
        ..waterClarityId = clarityId2
        ..anglerId = anglerId0
        ..isFavorite = true
        ..tide = Tide(type: TideType.high)
        ..atmosphere = Atmosphere(
          moonPhase: MoonPhase.new_,
        )
        ..quantity = 5
        ..methodIds.add(methodId0)
        ..period = Period.morning
        ..season = Season.autumn,
      Catch()
        ..id = catchId1
        ..timestamp = Int64(5000)
        ..speciesId = speciesId4
        ..fishingSpotId = fishingSpotId3
        ..baits.add(baitAttachment4)
        ..anglerId = anglerId1
        ..gearIds.add(gearId0)
        ..tide = Tide(type: TideType.incoming),
      Catch()
        ..id = catchId2
        ..timestamp = Int64(100)
        ..speciesId = speciesId0
        ..fishingSpotId = fishingSpotId4
        ..baits.add(baitAttachment0)
        ..anglerId = anglerId1
        ..gearIds.addAll([gearId0, gearId1])
        ..isFavorite = true
        ..season = Season.winter,
      Catch()
        ..id = catchId3
        ..timestamp = Int64(900)
        ..speciesId = speciesId1
        ..fishingSpotId = fishingSpotId0
        ..waterClarityId = clarityId4
        ..baits.add(baitAttachment1)
        ..period = Period.morning
        ..season = Season.autumn,
      Catch()
        ..id = catchId4
        ..timestamp = Int64(78000)
        ..speciesId = speciesId4
        ..fishingSpotId = fishingSpotId1
        ..baits.add(baitAttachment0)
        ..waterClarityId = clarityId3
        ..period = Period.afternoon,
      Catch()
        ..id = catchId5
        ..timestamp = Int64(100000)
        ..speciesId = speciesId3
        ..fishingSpotId = fishingSpotId1
        ..baits.add(baitAttachment2)
        ..atmosphere = Atmosphere(
          moonPhase: MoonPhase.new_,
        ),
      Catch()
        ..id = catchId6
        ..timestamp = Int64(800)
        ..speciesId = speciesId1
        ..fishingSpotId = fishingSpotId2
        ..baits.add(baitAttachment1)
        ..atmosphere = Atmosphere(
          moonPhase: MoonPhase.first_quarter,
          skyConditions: [SkyCondition.clear],
        ),
      Catch()
        ..id = catchId7
        ..timestamp = Int64(70)
        ..speciesId = speciesId1
        ..fishingSpotId = fishingSpotId1
        ..baits.add(baitAttachment0)
        ..isFavorite = true,
      Catch()
        ..id = catchId8
        ..timestamp = Int64(15)
        ..speciesId = speciesId1
        ..fishingSpotId = fishingSpotId1
        ..baits.add(baitAttachment1)
        ..methodIds.addAll([methodId0, methodId1]),
      Catch()
        ..id = catchId9
        ..timestamp = Int64(6000)
        ..speciesId = speciesId4
        ..fishingSpotId = fishingSpotId1
        ..baits.add(baitAttachment0)
        ..methodIds.add(methodId0),
    ];
  }

  void stubCatchesByTimestamp([List<Catch>? catchesOverride]) {
    when(catchManager.catches(
      any,
      opt: anyNamed("opt"),
    )).thenReturn(
      (catchesOverride ?? catches)
        ..sort((lhs, rhs) => rhs.timestamp.compareTo(lhs.timestamp)),
    );
    when(catchManager.uuidMap()).thenReturn(
        {for (var cat in (catchesOverride ?? catches)) cat.id.uuid: cat});
  }

  Future<void> pumpCatchSummary(
    WidgetTester tester,
    CatchSummary Function(BuildContext) builder, {
    MediaQueryData mediaQueryData = const MediaQueryData(),
  }) async {
    await pumpContext(
      tester,
      (context) => SingleChildScrollView(child: builder(context)),
      appManager: appManager,
      mediaQueryData: mediaQueryData,
    );
    // Pump to redraw after summary future completes.
    await tester.pumpAndSettle();
  }

  Future<void> pumpAndShowCatchList(
    WidgetTester tester,
    CatchFilterOptions opt,
    String tappableText,
  ) async {
    // Use a real CatchManager instance so real filtering is done.
    var catchManager = CatchManager(appManager.app);
    when(appManager.app.catchManager).thenReturn(catchManager);

    for (var cat in catches) {
      await catchManager.addOrUpdate(cat);
    }

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(filterOptionsBuilder: (_) => opt),
      // Ensures tappableText is visible. For some reason, ensureVisible doesn't
      // work here.
      mediaQueryData: const MediaQueryData(
        size: Size(500, 5000),
      ),
    );

    await tester.ensureVisible(find.text(tappableText));
    await tapAndSettle(tester, find.text(tappableText));
    expect(find.byType(CatchListPage), findsOneWidget);
  }

  Future<void> testDeleteRealEntity<T extends GeneratedMessage>(
      WidgetTester tester,
      EntityManager<T> manager,
      Iterable<T> entities,
      Id entityToDelete) async {
    // Use a real entity manager so widget is updated properly on changes.
    for (var entity in entities) {
      await manager.addOrUpdate(entity);
    }

    // Load a catch report with all default values.
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );

    expect(await manager.delete(entityToDelete), isTrue);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
  }

  setUp(() {
    appManager = StubbedAppManager();
    resetCatches();

    anglerManager = appManager.anglerManager;
    when(anglerManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(anglerManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(anglerManager.list()).thenReturn(anglerMap.values.toList());
    when(anglerManager.entity(any)).thenAnswer(
        (invocation) => anglerMap[invocation.positionalArguments[0]]);
    when(anglerManager.entityExists(any)).thenAnswer(
        (invocation) => anglerMap[invocation.positionalArguments[0]] != null);
    when(anglerManager.uuidMap())
        .thenReturn(anglerMap.map((key, value) => MapEntry(key.uuid, value)));

    baitManager = appManager.baitManager;
    when(baitManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(baitManager.list()).thenReturn(baitMap.values.toList());
    when(baitManager.entity(any))
        .thenAnswer((invocation) => baitMap[invocation.positionalArguments[0]]);
    when(baitManager.attachmentComparator).thenReturn((lhs, rhs) => 0);
    when(baitManager.entityExists(any)).thenReturn(true);
    when(baitManager.attachmentsDisplayValues(any, any)).thenReturn([]);
    when(baitManager.attachmentDisplayValue(any, any)).thenReturn("Attachment");
    when(baitManager.variant(any, any)).thenReturn(null);
    when(baitManager.formatNameWithCategory(any)).thenReturn("Name");
    when(baitManager.uuidMap())
        .thenReturn(baitMap.map((key, value) => MapEntry(key.uuid, value)));
    when(baitManager.attachmentExists(any)).thenReturn(true);

    when(appManager.baitCategoryManager.listen(any))
        .thenAnswer((_) => MockStreamSubscription());

    bodyOfWaterManager = appManager.bodyOfWaterManager;
    when(bodyOfWaterManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(bodyOfWaterManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(bodyOfWaterManager.list()).thenReturn(bodyOfWaterMap.values.toList());
    when(bodyOfWaterManager.entity(any)).thenAnswer(
        (invocation) => bodyOfWaterMap[invocation.positionalArguments[0]]);
    when(bodyOfWaterManager.entityExists(any)).thenAnswer((invocation) =>
        bodyOfWaterMap[invocation.positionalArguments[0]] != null);
    when(bodyOfWaterManager.uuidMap()).thenReturn(
        bodyOfWaterMap.map((key, value) => MapEntry(key.uuid, value)));

    catchManager = appManager.catchManager;
    when(catchManager.list()).thenReturn(catches);
    when(catchManager.deleteMessage(any, any)).thenReturn("Delete");
    when(catchManager.totalQuantity(any)).thenReturn(catches.length);
    when(catchManager.uuidMap())
        .thenReturn({for (var cat in catches) cat.id.uuid: cat});

    when(appManager.timeManager.currentDateTime)
        .thenReturn(dateTimestamp(105000));
    when(appManager.timeManager.currentTimestamp)
        .thenReturn(dateTimestamp(105000).millisecondsSinceEpoch);

    fishingSpotManager = appManager.fishingSpotManager;
    when(fishingSpotManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(fishingSpotManager.displayName(
      any,
      any,
      useLatLngFallback: anyNamed("useLatLngFallback"),
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
      includeLatLngLabels: anyNamed("includeLatLngLabels"),
    )).thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(fishingSpotManager.list()).thenReturn(fishingSpotMap.values.toList());
    when(fishingSpotManager.entity(any)).thenAnswer(
        (invocation) => fishingSpotMap[invocation.positionalArguments[0]]);
    when(fishingSpotManager.entityExists(any)).thenAnswer((invocation) =>
        fishingSpotMap[invocation.positionalArguments[0]] != null);
    when(fishingSpotManager.displayNameComparator(any))
        .thenReturn((lhs, rhs) => compareIgnoreCase(lhs.name, rhs.name));
    when(fishingSpotManager.uuidMap()).thenReturn(
        fishingSpotMap.map((key, value) => MapEntry(key.uuid, value)));

    methodManager = appManager.methodManager;
    when(methodManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(methodManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(methodManager.list()).thenReturn(methodMap.values.toList());
    when(methodManager.entity(any)).thenAnswer(
        (invocation) => methodMap[invocation.positionalArguments[0]]);
    when(methodManager.entityExists(any)).thenAnswer(
        (invocation) => methodMap[invocation.positionalArguments[0]] != null);
    when(methodManager.uuidMap())
        .thenReturn(methodMap.map((key, value) => MapEntry(key.uuid, value)));

    speciesManager = appManager.speciesManager;
    when(speciesManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(speciesManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(speciesManager.list()).thenReturn(speciesMap.values.toList());
    when(speciesManager.listSortedByDisplayName(any,
            filter: anyNamed("filter")))
        .thenReturn(speciesMap.values.toList());
    when(speciesManager.entity(any)).thenAnswer(
        (invocation) => speciesMap[invocation.positionalArguments[0]]);
    when(speciesManager.entityExists(any)).thenAnswer(
        (invocation) => speciesMap[invocation.positionalArguments[0]] != null);
    when(speciesManager.displayNameComparator(any))
        .thenReturn((lhs, rhs) => compareIgnoreCase(lhs.name, rhs.name));
    when(speciesManager.uuidMap())
        .thenReturn(speciesMap.map((key, value) => MapEntry(key.uuid, value)));

    waterClarityManager = appManager.waterClarityManager;
    when(waterClarityManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(waterClarityManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(waterClarityManager.list()).thenReturn(clarityMap.values.toList());
    when(waterClarityManager.entity(any)).thenAnswer(
        (invocation) => clarityMap[invocation.positionalArguments[0]]);
    when(waterClarityManager.entityExists(any)).thenAnswer(
        (invocation) => clarityMap[invocation.positionalArguments[0]] != null);
    when(waterClarityManager.uuidMap())
        .thenReturn(clarityMap.map((key, value) => MapEntry(key.uuid, value)));

    gearManager = appManager.gearManager;
    when(gearManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(gearManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(gearManager.list()).thenReturn(gearMap.values.toList());
    when(gearManager.entity(any))
        .thenAnswer((invocation) => gearMap[invocation.positionalArguments[0]]);
    when(gearManager.entityExists(any)).thenAnswer(
        (invocation) => gearMap[invocation.positionalArguments[0]] != null);
    when(gearManager.uuidMap())
        .thenReturn(gearMap.map((key, value) => MapEntry(key.uuid, value)));

    when(appManager.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingMoonPhases)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingPeriods).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingSeasons).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingTides).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingGear).thenReturn(true);
    when(appManager.userPreferenceManager.mapType).thenReturn("satellite");
    when(appManager.userPreferenceManager.statsDateRange).thenReturn(null);
    when(appManager.userPreferenceManager.setStatsDateRange(any))
        .thenAnswer((_) => Future.value());

    when(appManager.propertiesManager.mapboxApiKey).thenReturn("KEY");

    when(appManager.ioWrapper.isAndroid).thenReturn(false);
    when(appManager.isolatesWrapper.computeIntList(any, any))
        .thenAnswer((invocation) {
      return Future.value(invocation.positionalArguments
          .first(invocation.positionalArguments[1]));
    });

    when(appManager.imageManager.save(any, compress: anyNamed("compress")))
        .thenAnswer((_) => Future.value([]));

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.localDatabaseManager.deleteEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    stubCatchesByTimestamp();
  });

  testWidgets("Loading is shown until report is generated", (tester) async {
    await pumpContext(
      tester,
      (context) => SingleChildScrollView(
        child: CatchSummary<Catch>(
          filterOptionsBuilder: (_) => CatchFilterOptions(),
        ),
      ),
      appManager: appManager,
    );
    expect(find.byType(Loading), findsOneWidget);
    expect(find.byType(DateRangePickerInput), findsNothing);
  });

  testWidgets("Date picker hidden when static", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
        isStatic: true,
      ),
    );
    expect(find.byType(DateRangePickerInput), findsNothing);
  });

  testWidgets("Date picker shown", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
        isStatic: false,
      ),
    );
    expect(find.byType(DateRangePickerInput), findsOneWidget);
  });

  testWidgets("Date range is loaded from preferences", (tester) async {
    when(appManager.userPreferenceManager.statsDateRange).thenReturn(DateRange(
      period: DateRange_Period.yesterday,
    ));

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
        isStatic: false,
      ),
    );

    expect(find.byType(DateRangePickerInput), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DateRangePickerInput),
        matching: find.text("Yesterday"),
      ),
      findsOneWidget,
    );
  });

  testWidgets("Entity picker hidden when widget.picker is null",
      (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
        isStatic: true,
        picker: null,
      ),
    );
    expect(find.byType(ListPickerInput), findsNothing);
  });

  testWidgets("Entity picker hidden when entity is null", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Species>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
        isStatic: true,
        picker: CatchSummaryPicker(
          pickerBuilder: (settings) => const Empty(),
          nameBuilder: (context, cat) => "Test",
          initialValue: null,
        ),
      ),
    );
    expect(find.byType(ListPickerInput), findsNothing);
  });

  testWidgets("Report refreshed when picked entity changes", (tester) async {
    var reportBuilderCount = 0;

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Species>(
        filterOptionsBuilder: (_) {
          reportBuilderCount++;
          return CatchFilterOptions();
        },
        isStatic: true,
        picker: CatchSummaryPicker(
          pickerBuilder: (settings) =>
              SpeciesListPage(pickerSettings: settings),
          nameBuilder: (_, species) => species.name,
          initialValue: speciesMap[speciesId0],
        ),
      ),
    );

    // Initial loading of the widget.
    expect(find.byType(ListPickerInput), findsOneWidget);
    expect(find.text("Bluegill"), findsOneWidget);
    expect(reportBuilderCount, 1);

    // Selecting a different entity.
    await tapAndSettle(tester, find.text("Bluegill"));
    await tapAndSettle(tester, find.text("Pike"));
    expect(find.text("Pike"), findsOneWidget);
    expect(reportBuilderCount, 2);

    // Selecting the same entity.
    await tapAndSettle(tester, find.text("Pike"));
    expect(find.text("Pike"), findsOneWidget);
    expect(reportBuilderCount, 2);
  });

  testWidgets("Right catches tile is hidden for past date ranges",
      (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(
          dateRanges: [DateRange(period: DateRange_Period.lastWeek)],
        ),
      ),
    );

    var tileRow = findFirst<TileRow>(tester);
    expect(tileRow.items.length, 1);
  });

  testWidgets("Catches tile with quantity = 1", (tester) async {
    when(catchManager.totalQuantity(any)).thenReturn(1);
    stubCatchesByTimestamp([Catch(id: randomId())]);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(
          dateRanges: [DateRange(period: DateRange_Period.lastWeek)],
        ),
      ),
    );
    expect(find.text("Catch"), findsOneWidget);

    // Verify catch list is opened if there are catches in the current report.
    await tapAndSettle(tester, find.text("Catch"));
    expect(find.byType(CatchListPage), findsOneWidget);
  });

  testWidgets("Catches tile with quantity != 1", (tester) async {
    when(catchManager.totalQuantity(any)).thenReturn(0);
    stubCatchesByTimestamp([]);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(
          dateRanges: [DateRange(period: DateRange_Period.lastWeek)],
        ),
      ),
    );
    expect(find.text("Catches"), findsOneWidget);

    // Verify catch list is not opened if there are no catches in the current
    // report.
    await tapAndSettle(tester, find.text("Catches"));
    expect(find.byType(CatchListPage), findsNothing);
  });

  testWidgets("Catches right tile shows comparison tile", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(
          dateRanges: [
            DateRange(period: DateRange_Period.lastWeek),
            DateRange(period: DateRange_Period.thisWeek),
          ],
        ),
      ),
    );

    var tileRow = findFirst<TileRow>(tester);
    expect(tileRow.items.length, 2);
    expect(find.text("Catches"), findsNWidgets(2));
  });

  testWidgets("Catches right tile shows time since last catch", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(
          dateRanges: [DateRange(period: DateRange_Period.thisWeek)],
        ),
      ),
    );

    var tileRow = findFirst<TileRow>(tester);
    expect(tileRow.items.length, 2);
    expect(find.text("Catches"), findsOneWidget);
    expect(find.text("Since Last Catch"), findsOneWidget);
  });

  testWidgets("Time since last catch shows CatchPage when tapped",
      (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );

    await tapAndSettle(tester, find.text("Since Last Catch"));
    expect(find.byType(CatchPage), findsOneWidget);
  });

  testWidgets("Time since last catch not tappable when there are no catches",
      (tester) async {
    stubCatchesByTimestamp([]);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );

    await tapAndSettle(tester, find.text("Since Last Catch"));
    expect(find.byType(CatchPage), findsNothing);
  });

  testWidgets("Catches per hour shows 24 rows", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Hour"), findsOneWidget);

    await tapAndSettle(tester, find.text("View all hours"));

    // 25 - 24 for each row, 1 for the back button.
    expect(find.byType(InkWell), findsNWidgets(25));
  });

  testWidgets("Catches per month shows 12 rows", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Month"), findsOneWidget);

    await ensureVisibleAndSettle(tester, find.text("View all months"));
    await tapAndSettle(tester, find.text("View all months"));

    // 13 - 12 for each row, 1 for the back button.
    expect(find.byType(InkWell), findsNWidgets(13));
  });

  testWidgets("Catches per entity row opens entity list", (tester) async {
    when(appManager.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
      // Ensures "Pike (4)" is tappable. For some reason, ensureVisible doesn't
      // work here.
      mediaQueryData: const MediaQueryData(
        size: Size(500, 5000),
      ),
    );
    expect(find.text("Per Species"), findsOneWidget);

    await tester.ensureVisible(find.text("Pike (4)"));
    await tapAndSettle(tester, find.text("Pike (4)"));
    expect(find.byType(CatchListPage), findsOneWidget);
  });

  testWidgets("Catch list shows correct species and sky conditions (#790)",
      (tester) async {
    await pumpAndShowCatchList(
      tester,
      CatchFilterOptions(
        speciesIds: [speciesId1],
        skyConditions: [SkyCondition.clear],
      ),
      "Pike (1)",
    );
    expect(find.byType(ManageableListItem), findsOneWidget);
  });

  testWidgets("Catch list shows correct anglers", (tester) async {
    await pumpAndShowCatchList(
      tester,
      CatchFilterOptions(anglerIds: [anglerId1]),
      "Eli (2)",
    );
    expect(find.byType(ManageableListItem), findsNWidgets(2));
  });

  testWidgets("Catch list shows correct baits", (tester) async {
    await pumpAndShowCatchList(
      tester,
      CatchFilterOptions(baits: [baitAttachment4]),
      "Attachment (1)",
    );
    expect(find.byType(ManageableListItem), findsOneWidget);
  });

  testWidgets("Catch list shows correct gear", (tester) async {
    await pumpAndShowCatchList(
      tester,
      CatchFilterOptions(gearIds: [gearId0]),
      "Bass Rod (2)",
    );
    expect(find.byType(ManageableListItem), findsNWidgets(2));
  });

  testWidgets("Catch list shows correct bodies of water", (tester) async {
    await pumpAndShowCatchList(
      tester,
      CatchFilterOptions(bodyOfWaterIds: [bodyOfWaterId0]),
      "Lake Huron (1)",
    );
    expect(find.byType(ManageableListItem), findsOneWidget);
  });

  testWidgets("Catch list shows correct fishing spots", (tester) async {
    await pumpAndShowCatchList(
      tester,
      CatchFilterOptions(fishingSpotIds: [fishingSpotId0]),
      "E (1)",
    );
    expect(find.byType(ManageableListItem), findsOneWidget);
  });

  testWidgets("Catch list shows correct methods", (tester) async {
    await pumpAndShowCatchList(
      tester,
      CatchFilterOptions(methodIds: [methodId0]),
      "Casting (7)",
    );
    expect(find.byType(ManageableListItem), findsNWidgets(3));
  });

  testWidgets("Catch list shows correct moon phases", (tester) async {
    await pumpAndShowCatchList(
      tester,
      CatchFilterOptions(moonPhases: [MoonPhase.first_quarter]),
      "1st Quarter (1)",
    );
    expect(find.byType(ManageableListItem), findsNWidgets(1));
  });

  testWidgets("Catch list shows correct periods", (tester) async {
    await pumpAndShowCatchList(
      tester,
      CatchFilterOptions(periods: [Period.morning]),
      "Morning (6)",
    );
    expect(find.byType(ManageableListItem), findsNWidgets(2));
  });

  testWidgets("Catch list shows correct seasons", (tester) async {
    await pumpAndShowCatchList(
      tester,
      CatchFilterOptions(seasons: [Season.autumn]),
      "Autumn (6)",
    );
    expect(find.byType(ManageableListItem), findsNWidgets(2));
  });

  testWidgets("Catch list shows correct tide types", (tester) async {
    await pumpAndShowCatchList(
      tester,
      CatchFilterOptions(tideTypes: [TideType.high]),
      "High (5)",
    );
    expect(find.byType(ManageableListItem), findsNWidgets(1));
  });

  testWidgets("Catch list shows correct water clarities", (tester) async {
    await pumpAndShowCatchList(
      tester,
      CatchFilterOptions(waterClarityIds: [clarityId4]),
      "1 Foot (1)",
    );
    expect(find.byType(ManageableListItem), findsNWidgets(1));
  });

  testWidgets("Catch list shows correct hours", (tester) async {
    await pumpAndShowCatchList(
      tester,
      CatchFilterOptions(hour: 19),
      "7:00 PM to 8:00 PM (14)",
    );
    expect(
      find.byType(ManageableListItem, skipOffstage: false),
      findsNWidgets(10),
    );
  });

  testWidgets("Catch list shows correct months", (tester) async {
    await pumpAndShowCatchList(
      tester,
      CatchFilterOptions(month: 12),
      "December (14)",
    );
    expect(
      find.byType(ManageableListItem, skipOffstage: false),
      findsNWidgets(10),
    );
  });

  testWidgets("Catches per species shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Species"), findsOneWidget);
  });

  testWidgets("Catches per species hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingSpecies).thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Species"), findsNothing);
  });

  testWidgets("Catches per fishing spot shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Fishing Spot"), findsOneWidget);
  });

  testWidgets("Catches per fishing spot hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Fishing Spot"), findsNothing);
  });

  testWidgets("Catches per bait shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingBaits).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Bait"), findsOneWidget);
  });

  testWidgets("Catches per bait shows variants", (tester) async {
    when(appManager.customEntityManager.customValuesDisplayValue(any, any))
        .thenReturn("");

    var baitManager = BaitManager(appManager.app);
    for (var bait in baitMap.values) {
      await baitManager.addOrUpdate(bait);
    }
    when(appManager.app.baitManager).thenReturn(baitManager);

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => optionsWithEverything()
          ..baits.addAll([baitAttachment0, baitAttachment4]),
      ),
    );

    expect(find.text("Worm (Brown) (9)"), findsOneWidget);
    expect(find.text("Grub (1)"), findsOneWidget);
  });

  testWidgets("Catches per bait hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingBaits).thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Bait"), findsNothing);
  });

  testWidgets("Catches per moon phase shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingMoonPhases)
        .thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Moon Phase"), findsOneWidget);
  });

  testWidgets("Catches per moon phase hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingMoonPhases)
        .thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Moon Phase"), findsNothing);
  });

  testWidgets("Catches per tide type shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingTides).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Tide"), findsOneWidget);
  });

  testWidgets("Catches per tide type hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingTides).thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Tide"), findsNothing);
  });

  testWidgets("Catches per angler shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Angler"), findsOneWidget);
  });

  testWidgets("Catches per angler hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingAnglers).thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Angler"), findsNothing);
  });

  testWidgets("Catches per body of water shown", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Body of Water"), findsOneWidget);
  });

  testWidgets("Catches per body of water hidden", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<BodyOfWater>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Body of Water"), findsNothing);
  });

  testWidgets("Catches per fishing method shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingMethods).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Fishing Method"), findsOneWidget);
  });

  testWidgets("Catches per fishing method hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingMethods).thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Fishing Method"), findsNothing);
  });

  testWidgets("Catches per gear shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingGear).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Gear"), findsOneWidget);
  });

  testWidgets("Catches per gear hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingGear).thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Gear"), findsNothing);
  });

  testWidgets("Catches per period shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingPeriods).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Time of Day"), findsOneWidget);
  });

  testWidgets("Catches per period hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingPeriods).thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Time of Day"), findsNothing);
  });

  testWidgets("Catches per season shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingSeasons).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Season"), findsOneWidget);
  });

  testWidgets("Catches per season hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingSeasons).thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Season"), findsNothing);
  });

  testWidgets("Catches per water clarity shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Water Clarity"), findsOneWidget);
  });

  testWidgets("Catches per water clarity hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Water Clarity"), findsNothing);
  });

  testWidgets("Compute report multiple date ranges", (tester) async {
    var report = CatchReport.fromBuffer(computeCatchReport(
      CatchFilterOptions(
        currentTimestamp: Int64(appManager.timeManager.currentTimestamp),
        currentTimeZone: appManager.timeManager.currentTimeZone,
        dateRanges: [
          DateRange(period: DateRange_Period.lastWeek),
          DateRange(period: DateRange_Period.thisWeek),
        ],
      ).writeToBuffer().toList(),
    ));

    expect(report.models.length, 2);
    expect(
      report.models[0].dateRange.period,
      DateRange_Period.lastWeek,
    );
    expect(
      report.models[1].dateRange.period,
      DateRange_Period.thisWeek,
    );
  });

  testWidgets("Compute report properties null if no catches", (tester) async {
    stubCatchesByTimestamp([]);

    var report = CatchReport.fromBuffer(computeCatchReport(CatchFilterOptions(
      currentTimestamp: Int64(appManager.timeManager.currentTimestamp),
      currentTimeZone: appManager.timeManager.currentTimeZone,
    ).writeToBuffer().toList()));

    expect(report.hasLastCatch(), isFalse);
    expect(report.hasMsSinceLastCatch(), isFalse);
  });

  testWidgets("Compute report properties null if comparing", (tester) async {
    var report = CatchReport.fromBuffer(
      computeCatchReport(
        CatchFilterOptions(
          currentTimestamp: Int64(appManager.timeManager.currentTimestamp),
          currentTimeZone: appManager.timeManager.currentTimeZone,
          dateRanges: [
            DateRange(period: DateRange_Period.lastWeek),
            DateRange(period: DateRange_Period.thisWeek),
          ],
        ).writeToBuffer().toList(),
      ),
    );

    expect(report.hasLastCatch(), isFalse);
    expect(report.hasMsSinceLastCatch(), isFalse);
  });

  testWidgets("Compute report filters includes date range", (tester) async {
    var opt = CatchFilterOptions(
      currentTimestamp: Int64(appManager.timeManager.currentTimestamp),
      currentTimeZone: appManager.timeManager.currentTimeZone,
      dateRanges: [
        DateRange(period: DateRange_Period.lastWeek),
      ],
    );
    var report = CatchReport.fromBuffer(
        computeCatchReport(opt.writeToBuffer().toList()));

    var filters = opt.displayFilters(
      await buildContext(tester, appManager: appManager),
      report,
    );
    expect(filters.contains("Last week"), isTrue);
  });

  testWidgets("Compute report filters includes species", (tester) async {
    var opt = CatchFilterOptions(
      currentTimestamp: Int64(appManager.timeManager.currentTimestamp),
      currentTimeZone: appManager.timeManager.currentTimeZone,
      speciesIds: {speciesId0, speciesId1},
    );
    var report = CatchReport.fromBuffer(
        computeCatchReport(opt.writeToBuffer().toList()));
    var context = await buildContext(tester, appManager: appManager);

    var filters = opt.displayFilters(context, report, includeSpecies: true);
    expect(filters.contains("Bluegill"), isTrue);
    expect(filters.contains("Pike"), isTrue);

    filters = opt.displayFilters(context, report, includeSpecies: false);
    expect(filters.contains("Bluegill"), isFalse);
    expect(filters.contains("Pike"), isFalse);
  });

  testWidgets("Compute report filters includes catch and release",
      (tester) async {
    var opt = CatchFilterOptions(
      currentTimestamp: Int64(appManager.timeManager.currentTimestamp),
      currentTimeZone: appManager.timeManager.currentTimeZone,
      isCatchAndReleaseOnly: true,
    );
    var report = CatchReport.fromBuffer(
        computeCatchReport(opt.writeToBuffer().toList()));
    var filters = opt.displayFilters(
      await buildContext(tester, appManager: appManager),
      report,
    );
    expect(filters.contains("Catch and release only"), isTrue);
  });

  testWidgets("Compute report filters includes favorites", (tester) async {
    var opt = CatchFilterOptions(
      currentTimestamp: Int64(appManager.timeManager.currentTimestamp),
      currentTimeZone: appManager.timeManager.currentTimeZone,
      isFavoritesOnly: true,
    );
    var report = CatchReport.fromBuffer(
        computeCatchReport(opt.writeToBuffer().toList()));
    var filters = opt.displayFilters(
      await buildContext(tester, appManager: appManager),
      report,
    );
    expect(filters.contains("Favorites only"), isTrue);
  });

  testWidgets("Compute report filters skip null number filters",
      (tester) async {
    var opt = CatchFilterOptions(
      currentTimestamp: Int64(appManager.timeManager.currentTimestamp),
      currentTimeZone: appManager.timeManager.currentTimeZone,
      dateRanges: [
        DateRange(period: DateRange_Period.lastWeek),
        DateRange(period: DateRange_Period.thisWeek),
      ],
    );
    var report = CatchReport.fromBuffer(
        computeCatchReport(opt.writeToBuffer().toList()));
    var filters = opt.displayFilters(
      await buildContext(tester, appManager: appManager),
      report,
    );
    expect(filters.isEmpty, isTrue);
  });

  testWidgets("Compute report filters includes number filters", (tester) async {
    var opt = CatchFilterOptions(
      currentTimestamp: Int64(appManager.timeManager.currentTimestamp),
      currentTimeZone: appManager.timeManager.currentTimeZone,
      dateRanges: [
        DateRange(period: DateRange_Period.lastWeek),
        DateRange(period: DateRange_Period.thisWeek),
      ],
      lengthFilter: NumberFilter(
        boundary: NumberBoundary.equal_to,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.centimeters,
            value: 25,
          ),
        ),
      ),
    );
    var report = CatchReport.fromBuffer(
        computeCatchReport(opt.writeToBuffer().toList()));
    var filters = opt.displayFilters(
      await buildContext(tester, appManager: appManager),
      report,
    );
    expect(filters.length, 1);
    expect(filters.first, "Length: = 25 cm");
  });

  testWidgets("Compute report filters skip null entities", (tester) async {
    when(speciesManager.entity(speciesId0)).thenReturn(null);
    var opt = CatchFilterOptions(
      currentTimestamp: Int64(appManager.timeManager.currentTimestamp),
      currentTimeZone: appManager.timeManager.currentTimeZone,
      speciesIds: {speciesId0, speciesId1},
    );
    var report = CatchReport.fromBuffer(
        computeCatchReport(opt.writeToBuffer().toList()));
    var context = await buildContext(tester, appManager: appManager);

    var filters = opt.displayFilters(context, report, includeSpecies: true);
    expect(filters.contains("Bluegill"), isFalse);
    expect(filters.contains("Pike"), isTrue);
  });

  testWidgets("Compute fill zeros includes all values", (tester) async {
    var report = CatchReport.fromBuffer(
        computeCatchReport(optionsWithEverything().writeToBuffer().toList()));

    expect(report.models.first.perBait.length, baitMap.length);
    expect(report.models.first.perAngler.length, anglerMap.length);
    expect(report.models.first.perBodyOfWater.length, bodyOfWaterMap.length);
    expect(report.models.first.perMethod.length, methodMap.length);
    expect(report.models.first.perFishingSpot.length, fishingSpotMap.length);
    expect(report.models.first.perMoonPhase.length,
        MoonPhases.selectableValues().length);
    expect(report.models.first.perPeriod.length,
        Periods.selectableValues().length);
    expect(report.models.first.perSeason.length,
        Seasons.selectableValues().length);
    expect(report.models.first.perSpecies.length, speciesMap.length);
    expect(report.models.first.perTideType.length,
        TideTypes.selectableValues().length);
    expect(report.models.first.perWaterClarity.length, clarityMap.length);
  });

  testWidgets("Compute fill zeros includes only filtered values",
      (tester) async {
    var opt = optionsWithEverything()
      ..baits.addAll([baitAttachment0, baitAttachment1])
      ..anglerIds.addAll([anglerId3])
      ..bodyOfWaterIds.addAll([bodyOfWaterId0, bodyOfWaterId4])
      ..methodIds.addAll([methodId0, methodId2, methodId4])
      ..fishingSpotIds.addAll([fishingSpotId2])
      ..moonPhases.addAll([MoonPhase.first_quarter, MoonPhase.full])
      ..periods.addAll([Period.afternoon])
      ..seasons.addAll([Season.autumn])
      ..speciesIds.addAll([speciesId3, speciesId1])
      ..tideTypes.addAll([TideType.high])
      ..waterClarityIds.addAll([clarityId4]);

    var report = CatchReport.fromBuffer(
        computeCatchReport(opt.writeToBuffer().toList()));

    expect(report.models.first.perBait.length, 2);
    expect(report.models.first.perAngler.length, 1);
    expect(report.models.first.perBodyOfWater.length, 2);
    expect(report.models.first.perMethod.length, 3);
    expect(report.models.first.perFishingSpot.length, 1);
    expect(report.models.first.perMoonPhase.length, 2);
    expect(report.models.first.perPeriod.length, 1);
    expect(report.models.first.perSeason.length, 1);
    expect(report.models.first.perSpecies.length, 2);
    expect(report.models.first.perTideType.length, 1);
    expect(report.models.first.perWaterClarity.length, 1);
  });

  testWidgets("Model filled with zeros", (tester) async {
    stubCatchesByTimestamp([]);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    // There are 14 charts, each with 3 items (gear has 2), and all values
    // should equal 0.
    expect(find.substring("(0)"), findsNWidgets(41));
  });

  testWidgets("Model filled with zeros skips entities that aren't tracked",
      (tester) async {
    when(appManager.userPreferenceManager.isTrackingSeasons).thenReturn(false);
    when(appManager.userPreferenceManager.isTrackingTides).thenReturn(false);
    stubCatchesByTimestamp([]);

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );

    // There are 14 charts total, minus seasons and tides, each with 3 items
    // (gear has 2), and all values should equal 0.
    expect(find.substring("(0)"), findsNWidgets(35));
  });

  testWidgets("Model increment entities skips entities that aren't tracked",
      (tester) async {
    when(appManager.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(false);

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );

    expect(find.text("Per Fishing Spot"), findsNothing);
  });

  testWidgets("Model increment entities no baits", (tester) async {
    for (var cat in catches) {
      cat.baits.clear();
    }
    when(baitManager.attachmentDisplayValue(any, any)).thenReturn("Dummy");

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );

    // Since all catches have been cleared of baits, bait values should all be
    // 0.
    expect(find.text("Dummy (0)"), findsNWidgets(3));
  });

  testWidgets("Model increment entities no methods", (tester) async {
    for (var cat in catches) {
      cat.methodIds.clear();
    }
    when(methodManager.displayName(any, any)).thenReturn("Dummy");

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );

    // Since all catches have been cleared of methods, method values should all
    // be 0.
    expect(find.text("Dummy (0)"), findsNWidgets(3));
  });

  testWidgets("Model increment entities no gear", (tester) async {
    for (var cat in catches) {
      cat.gearIds.clear();
    }
    when(gearManager.displayName(any, any)).thenReturn("Dummy");

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );

    // Since all catches have been cleared of gear, gear values should all
    // be 0.
    expect(find.text("Dummy (0)"), findsNWidgets(2));
  });

  testWidgets("Model increment entities no atmosphere", (tester) async {
    for (var cat in catches) {
      cat.clearAtmosphere();
    }

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("New (0)"), findsOneWidget);
    expect(find.text("Waxing Crescent (0)"), findsOneWidget);
    expect(find.text("1st Quarter (0)"), findsOneWidget);
  });

  testWidgets("Model increment entities no moon phase", (tester) async {
    for (var cat in catches) {
      cat.clearAtmosphere();
    }
    catches.first.atmosphere = Atmosphere(sunriseTimestamp: Int64(5000));

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("New (0)"), findsOneWidget);
    expect(find.text("Waxing Crescent (0)"), findsOneWidget);
    expect(find.text("1st Quarter (0)"), findsOneWidget);
  });

  testWidgets("Model increment entities no period", (tester) async {
    for (var cat in catches) {
      cat.clearPeriod();
    }

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );

    // Since all catches have been cleared of periods, period values should all
    // be 0.
    expect(find.text("Dawn (0)"), findsOneWidget);
    expect(find.text("Morning (0)"), findsOneWidget);
    expect(find.text("Midday (0)"), findsOneWidget);
  });

  testWidgets("Model increment entities no season", (tester) async {
    for (var cat in catches) {
      cat.clearSeason();
    }

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );

    // Since all catches have been cleared of seasons, season values should all
    // be 0.
    expect(find.text("Winter (0)"), findsOneWidget);
    expect(find.text("Spring (0)"), findsOneWidget);
    expect(find.text("Summer (0)"), findsOneWidget);
  });

  testWidgets("Model increment entities no tide", (tester) async {
    for (var cat in catches) {
      cat.clearTide();
    }

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );

    // Since all catches have been cleared of tide, tide type values should all
    // be 0.
    expect(find.text("Low (0)"), findsOneWidget);
    expect(find.text("Outgoing (0)"), findsOneWidget);
    expect(find.text("High (0)"), findsOneWidget);
  });

  testWidgets("Model increment entities no tide type", (tester) async {
    for (var cat in catches) {
      cat.clearTide();
    }
    catches.first.tide = Tide();

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );

    // Since all catches have been cleared of tide, tide type values should all
    // be 0.
    expect(find.text("Low (0)"), findsOneWidget);
    expect(find.text("Outgoing (0)"), findsOneWidget);
    expect(find.text("High (0)"), findsOneWidget);
  });

  testWidgets("Model increment entities all fields set", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );

    // Species
    await tester.ensureVisible(find.text("View all species"));
    await tapAndSettle(tester, find.text("View all species"));
    expect(find.text("Bluegill (1)"), findsOneWidget);
    expect(find.text("Pike (4)"), findsOneWidget);
    expect(find.text("Catfish (0)"), findsOneWidget);
    expect(find.text("Bass (6)"), findsOneWidget);
    expect(find.text("Steelhead (3)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Fishing Spots
    await tester.ensureVisible(find.text("View all fishing spots"));
    await tapAndSettle(tester, find.text("View all fishing spots"));
    expect(find.text("E (1)"), findsOneWidget);
    expect(find.text("C (10)"), findsOneWidget);
    expect(find.text("B (1)"), findsOneWidget);
    expect(find.text("D (1)"), findsOneWidget);
    expect(find.text("A (1)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Baits
    await tester.ensureVisible(find.text("View all baits"));
    await tapAndSettle(tester, find.text("View all baits"));
    expect(find.text("Attachment (1)"), findsNWidgets(2));
    expect(find.text("Attachment (9)"), findsOneWidget);
    expect(find.text("Attachment (3)"), findsOneWidget);
    expect(find.text("Attachment (0)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Moon phases
    await tester.ensureVisible(find.text("View all moon phases"));
    await tapAndSettle(tester, find.text("View all moon phases"));
    expect(find.text("New (6)"), findsOneWidget);
    expect(find.text("Waxing Crescent (0)"), findsOneWidget);
    expect(find.text("1st Quarter (1)"), findsOneWidget);
    expect(find.text("Waxing Gibbous (0)"), findsOneWidget);
    expect(find.text("Full (0)"), findsOneWidget);
    expect(find.text("Waning Gibbous (0)"), findsOneWidget);
    expect(find.text("Last Quarter (0)"), findsOneWidget);
    expect(find.text("Waning Crescent (0)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Tides
    await tester.ensureVisible(find.text("View all tide types"));
    await tapAndSettle(tester, find.text("View all tide types"));
    expect(find.text("Low (0)"), findsOneWidget);
    expect(find.text("Outgoing (0)"), findsOneWidget);
    expect(find.text("High (5)"), findsOneWidget);
    expect(find.text("Slack (0)"), findsOneWidget);
    expect(find.text("Incoming (1)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Anglers
    await tester.ensureVisible(find.text("View all anglers"));
    await tapAndSettle(tester, find.text("View all anglers"));
    expect(find.text("Cohen (5)"), findsOneWidget);
    expect(find.text("Eli (2)"), findsOneWidget);
    expect(find.text("Ethan (0)"), findsOneWidget);
    expect(find.text("Tim (0)"), findsOneWidget);
    expect(find.text("Someone (0)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Bodies of water
    await tester.ensureVisible(find.text("View all bodies of water"));
    await tapAndSettle(tester, find.text("View all bodies of water"));
    expect(find.text("Lake Huron (1)"), findsOneWidget);
    expect(find.text("Tennessee River (10)"), findsOneWidget);
    expect(find.text("Bow River (1)"), findsOneWidget);
    expect(find.text("Nine Mile River (1)"), findsOneWidget);
    expect(find.text("Maitland River (1)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Fishing methods
    await tester.ensureVisible(find.text("View all fishing methods"));
    await tapAndSettle(tester, find.text("View all fishing methods"));
    expect(find.text("Casting (7)"), findsOneWidget);
    expect(find.text("Shore (1)"), findsOneWidget);
    expect(find.text("Kayak (0)"), findsOneWidget);
    expect(find.text("Drift (0)"), findsOneWidget);
    expect(find.text("Ice (0)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Periods
    await tester.ensureVisible(find.text("View all times of day"));
    await tapAndSettle(tester, find.text("View all times of day"));
    expect(find.text("Dawn (0)"), findsOneWidget);
    expect(find.text("Morning (6)"), findsOneWidget);
    expect(find.text("Midday (0)"), findsOneWidget);
    expect(find.text("Afternoon (1)"), findsOneWidget);
    expect(find.text("Dusk (0)"), findsOneWidget);
    expect(find.text("Night (0)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Seasons
    await tester.ensureVisible(find.text("View all seasons"));
    await tapAndSettle(tester, find.text("View all seasons"));
    expect(find.text("Winter (1)"), findsOneWidget);
    expect(find.text("Spring (0)"), findsOneWidget);
    expect(find.text("Summer (0)"), findsOneWidget);
    expect(find.text("Autumn (6)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Water clarities
    await tester.ensureVisible(find.text("View all water clarities"));
    await tapAndSettle(tester, find.text("View all water clarities"));
    expect(find.text("Clear (0)"), findsOneWidget);
    expect(find.text("Tea Stained (0)"), findsOneWidget);
    expect(find.text("Chocolate Milk (5)"), findsOneWidget);
    expect(find.text("Crystal (1)"), findsOneWidget);
    expect(find.text("1 Foot (1)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));
  });

  testWidgets("Model anglers excluded when T is Angler", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Angler>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Angler"), findsNothing);
  });

  testWidgets("Model baits excluded when T is BaitAttachment", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<BaitAttachment>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Bait"), findsNothing);
  });

  testWidgets("Model bodies of water excluded when T is BodyOfWater",
      (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<BodyOfWater>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Body Of Water"), findsNothing);
  });

  testWidgets("Model methods excluded when T is Method", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Method>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Fishing Method"), findsNothing);
  });

  testWidgets("Model gear excluded when T is Gear", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Gear>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Gear"), findsNothing);
  });

  testWidgets("Model fishing spots excluded when T is FishingSpot",
      (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<FishingSpot>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Fishing Spot"), findsNothing);
  });

  testWidgets("Model moon phases excluded when T is MoonPhase", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<MoonPhase>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Moon Phase"), findsNothing);
  });

  testWidgets("Model seasons excluded when T is Season", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Season>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Season"), findsNothing);
  });

  testWidgets("Model species excluded when T is Species", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Species>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Species"), findsNothing);
  });

  testWidgets("Model tide types excluded when T is TideType", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<TideType>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Tide"), findsNothing);
  });

  testWidgets("Model water clarities excluded when T is WaterClarity",
      (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<WaterClarity>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );
    expect(find.text("Per Water Clarity"), findsNothing);
  });

  testWidgets("Default values are set for report input", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<WaterClarity>(
        filterOptionsBuilder: (_) => CatchFilterOptions(),
      ),
    );

    var result =
        verify(appManager.isolatesWrapper.computeIntList(any, captureAny));
    result.called(1);

    var opt = CatchFilterOptions.fromBuffer(result.captured.first);
    expect(opt.dateRanges.length, 1);
    expect(opt.hasCurrentTimestamp(), isTrue);
    expect(opt.hasCurrentTimeZone(), isTrue);
  });

  testWidgets("All entity lists are overridden", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<WaterClarity>(
        filterOptionsBuilder: (_) => CatchFilterOptions(
          allAnglers: {anglerId0.uuid: anglerMap.values.first},
          allBaits: {baitId0.uuid: baitMap.values.first},
          allBodiesOfWater: {bodyOfWaterId0.uuid: bodyOfWaterMap.values.first},
          allCatches: {catchId0.uuid: catches.first},
          allFishingSpots: {fishingSpotId0.uuid: fishingSpotMap.values.first},
          allMethods: {methodId0.uuid: methodMap.values.first},
          allSpecies: {speciesId0.uuid: speciesMap.values.first},
          allWaterClarities: {clarityId0.uuid: clarityMap.values.first},
        ),
      ),
    );

    var result =
        verify(appManager.isolatesWrapper.computeIntList(any, captureAny));
    result.called(1);

    var opt = CatchFilterOptions.fromBuffer(result.captured.first);
    expect(opt.allAnglers.length, anglerMap.values.length);
    expect(opt.allBaits.length, baitMap.values.length);
    expect(opt.allBodiesOfWater.length, bodyOfWaterMap.values.length);
    expect(opt.allCatches.length, catches.length);
    expect(opt.allFishingSpots.length, fishingSpotMap.values.length);
    expect(opt.allMethods.length, methodMap.values.length);
    expect(opt.allSpecies.length, speciesMap.values.length);
    expect(opt.allWaterClarities.length, clarityMap.values.length);
  });

  testWidgets("Deleting a species doesn't throw NPE", (tester) async {
    when(catchManager.existsWith(speciesId: anyNamed("speciesId")))
        .thenReturn(false);

    var speciesManager = SpeciesManager(appManager.app);
    when(appManager.app.speciesManager).thenReturn(speciesManager);
    await testDeleteRealEntity(
        tester, speciesManager, speciesMap.values, speciesId0);

    // At this point, if the test finishes without throwing an NPE, it is
    // working as expected.
  });

  testWidgets("Deleting a fishing spot doesn't throw NPE", (tester) async {
    when(appManager.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn("Body Of Water");

    var fishingSpotManager = FishingSpotManager(appManager.app);
    when(appManager.app.fishingSpotManager).thenReturn(fishingSpotManager);
    await testDeleteRealEntity(
        tester, fishingSpotManager, fishingSpotMap.values, fishingSpotId0);

    // At this point, if the test finishes without throwing an NPE, it is
    // working as expected.
  });

  testWidgets("Deleting a bait doesn't throw NPE", (tester) async {
    when(appManager.customEntityManager.customValuesDisplayValue(any, any))
        .thenReturn("Custom Value");

    var baitManager = BaitManager(appManager.app);
    when(appManager.app.baitManager).thenReturn(baitManager);
    await testDeleteRealEntity(tester, baitManager, baitMap.values, baitId0);

    // At this point, if the test finishes without throwing an NPE, it is
    // working as expected.
  });

  testWidgets("Deleting an angler doesn't throw NPE", (tester) async {
    var anglerManager = AnglerManager(appManager.app);
    when(appManager.app.anglerManager).thenReturn(anglerManager);
    await testDeleteRealEntity(
        tester, anglerManager, anglerMap.values, anglerId0);

    // At this point, if the test finishes without throwing an NPE, it is
    // working as expected.
  });

  testWidgets("Deleting a body of water doesn't throw NPE", (tester) async {
    var bodyOfWaterManager = BodyOfWaterManager(appManager.app);
    when(appManager.app.bodyOfWaterManager).thenReturn(bodyOfWaterManager);
    await testDeleteRealEntity(
        tester, bodyOfWaterManager, bodyOfWaterMap.values, bodyOfWaterId0);

    // At this point, if the test finishes without throwing an NPE, it is
    // working as expected.
  });

  testWidgets("Deleting a method doesn't throw NPE", (tester) async {
    var methodManager = MethodManager(appManager.app);
    when(appManager.app.methodManager).thenReturn(methodManager);
    await testDeleteRealEntity(
        tester, methodManager, methodMap.values, methodId0);

    // At this point, if the test finishes without throwing an NPE, it is
    // working as expected.
  });

  testWidgets("Deleting gear doesn't throw NPE", (tester) async {
    var gearManager = GearManager(appManager.app);
    when(appManager.app.gearManager).thenReturn(gearManager);
    await testDeleteRealEntity(tester, gearManager, gearMap.values, gearId0);

    // At this point, if the test finishes without throwing an NPE, it is
    // working as expected.
  });

  testWidgets("Deleting a water clarity doesn't throw NPE", (tester) async {
    var waterClarityManager = WaterClarityManager(appManager.app);
    when(appManager.app.waterClarityManager).thenReturn(waterClarityManager);
    await testDeleteRealEntity(
        tester, waterClarityManager, clarityMap.values, clarityId0);

    // At this point, if the test finishes without throwing an NPE, it is
    // working as expected.
  });
}
