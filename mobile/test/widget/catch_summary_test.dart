import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/catch_summary.dart';
import 'package:mockito/mockito.dart';
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
  var baitAttachment3 = BaitAttachment(baitId: baitId3);
  var baitAttachment4 = BaitAttachment(baitId: baitId4);

  var clarityId0 = randomId();
  var clarityId1 = randomId();
  var clarityId2 = randomId();
  var clarityId3 = randomId();
  var clarityId4 = randomId();

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

  var anglersMap = <Id, Angler>{
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

  var _catches = <Catch>[
    Catch()
      ..id = catchId0
      ..timestamp = Int64(10)
      ..speciesId = speciesId3
      ..fishingSpotId = fishingSpotId1
      ..baits.add(baitAttachment0)
      ..waterClarityId = clarityId2
      ..isFavorite = true,
    Catch()
      ..id = catchId1
      ..timestamp = Int64(5000)
      ..speciesId = speciesId4
      ..fishingSpotId = fishingSpotId3
      ..baits.add(baitAttachment4),
    Catch()
      ..id = catchId2
      ..timestamp = Int64(100)
      ..speciesId = speciesId0
      ..fishingSpotId = fishingSpotId4
      ..baits.add(baitAttachment0)
      ..isFavorite = true,
    Catch()
      ..id = catchId3
      ..timestamp = Int64(900)
      ..speciesId = speciesId1
      ..fishingSpotId = fishingSpotId0
      ..waterClarityId = clarityId4
      ..baits.add(baitAttachment1),
    Catch()
      ..id = catchId4
      ..timestamp = Int64(78000)
      ..speciesId = speciesId4
      ..fishingSpotId = fishingSpotId1
      ..baits.add(baitAttachment0)
      ..waterClarityId = clarityId3,
    Catch()
      ..id = catchId5
      ..timestamp = Int64(100000)
      ..speciesId = speciesId3
      ..fishingSpotId = fishingSpotId1
      ..baits.add(baitAttachment2),
    Catch()
      ..id = catchId6
      ..timestamp = Int64(800)
      ..speciesId = speciesId1
      ..fishingSpotId = fishingSpotId2
      ..baits.add(baitAttachment1),
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
      ..baits.add(baitAttachment1),
    Catch()
      ..id = catchId9
      ..timestamp = Int64(6000)
      ..speciesId = speciesId4
      ..fishingSpotId = fishingSpotId1
      ..baits.add(baitAttachment0),
  ];

  setUp(() {
    appManager = StubbedAppManager();

    anglerManager = appManager.anglerManager;
    when(anglerManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(anglerManager.list()).thenReturn(anglersMap.values.toList());
    when(anglerManager.entity(any)).thenAnswer(
        (invocation) => anglersMap[invocation.positionalArguments[0]]);

    baitManager = appManager.baitManager;
    when(baitManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(baitManager.list()).thenReturn(baitMap.values.toList());
    when(baitManager.entity(any))
        .thenAnswer((invocation) => baitMap[invocation.positionalArguments[0]]);
    when(baitManager.attachmentComparator).thenReturn((lhs, rhs) => 0);
    when(baitManager.entityExists(any)).thenReturn(true);

    bodyOfWaterManager = appManager.bodyOfWaterManager;
    when(bodyOfWaterManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(bodyOfWaterManager.list()).thenReturn(bodyOfWaterMap.values.toList());
    when(bodyOfWaterManager.entity(any)).thenAnswer(
        (invocation) => bodyOfWaterMap[invocation.positionalArguments[0]]);

    catchManager = appManager.catchManager;
    when(catchManager.list()).thenReturn(_catches);

    when(appManager.timeManager.currentDateTime)
        .thenReturn(DateTime.fromMillisecondsSinceEpoch(105000));
    when(appManager.timeManager.msSinceEpoch).thenReturn(
        DateTime.fromMillisecondsSinceEpoch(105000).millisecondsSinceEpoch);

    fishingSpotManager = appManager.fishingSpotManager;
    when(fishingSpotManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(fishingSpotManager.list()).thenReturn(fishingSpotMap.values.toList());
    when(fishingSpotManager.entity(any)).thenAnswer(
        (invocation) => fishingSpotMap[invocation.positionalArguments[0]]);
    when(fishingSpotManager.nameComparator)
        .thenReturn((lhs, rhs) => compareIgnoreCase(lhs.name, rhs.name));

    methodManager = appManager.methodManager;
    when(methodManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(methodManager.list()).thenReturn(methodMap.values.toList());
    when(methodManager.entity(any)).thenAnswer(
        (invocation) => methodMap[invocation.positionalArguments[0]]);

    speciesManager = appManager.speciesManager;
    when(speciesManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(speciesManager.list()).thenReturn(speciesMap.values.toList());
    when(speciesManager.listSortedByName(filter: anyNamed("filter")))
        .thenReturn(speciesMap.values.toList());
    when(speciesManager.entity(any)).thenAnswer(
        (invocation) => speciesMap[invocation.positionalArguments[0]]);
    when(speciesManager.nameComparator)
        .thenReturn((lhs, rhs) => compareIgnoreCase(lhs.name, rhs.name));

    waterClarityManager = appManager.waterClarityManager;
    when(waterClarityManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(waterClarityManager.list()).thenReturn(clarityMap.values.toList());
    when(waterClarityManager.entity(any)).thenAnswer(
        (invocation) => clarityMap[invocation.positionalArguments[0]]);
  });

  void _stubCatchesByTimestamp(BuildContext context, [List<Catch>? catches]) {
    when(catchManager.catches(
      context,
      dateRange: anyNamed("dateRange"),
      isFavoritesOnly: anyNamed("isFavoritesOnly"),
      anglerIds: anyNamed("anglerIds"),
      baits: anyNamed("baits"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      bodyOfWaterIds: anyNamed("bodyOfWaterIds"),
      methodIds: anyNamed("methodIds"),
      speciesIds: anyNamed("speciesIds"),
      waterClarityIds: anyNamed("waterClarityIds"),
      periods: anyNamed("periods"),
      seasons: anyNamed("seasons"),
      windDirections: anyNamed("windDirections"),
      skyConditions: anyNamed("skyConditions"),
      moonPhases: anyNamed("moonPhases"),
      tideTypes: anyNamed("tideTypes"),
      waterDepthFilter: anyNamed("waterDepthFilter"),
      waterTemperatureFilter: anyNamed("waterTemperatureFilter"),
      lengthFilter: anyNamed("lengthFilter"),
      weightFilter: anyNamed("weightFilter"),
      quantityFilter: anyNamed("quantityFilter"),
      airTemperatureFilter: anyNamed("airTemperatureFilter"),
      airPressureFilter: anyNamed("airPressureFilter"),
      airHumidityFilter: anyNamed("airHumidityFilter"),
      airVisibilityFilter: anyNamed("airVisibilityFilter"),
      windSpeedFilter: anyNamed("windSpeedFilter"),
    )).thenReturn(
      (catches ?? _catches)
        ..sort((lhs, rhs) => rhs.timestamp.compareTo(lhs.timestamp)),
    );
  }
}
