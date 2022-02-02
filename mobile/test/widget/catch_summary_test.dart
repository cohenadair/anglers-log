import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/catch_summary.dart';
import 'package:mobile/widgets/date_range_picker_input.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/tile.dart';
import 'package:mobile/widgets/widget.dart';
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
        ..tide = Tide(type: TideType.high),
      Catch()
        ..id = catchId1
        ..timestamp = Int64(5000)
        ..speciesId = speciesId4
        ..fishingSpotId = fishingSpotId3
        ..baits.add(baitAttachment4)
        ..anglerId = anglerId1
        ..tide = Tide(type: TideType.incoming),
      Catch()
        ..id = catchId2
        ..timestamp = Int64(100)
        ..speciesId = speciesId0
        ..fishingSpotId = fishingSpotId4
        ..baits.add(baitAttachment0)
        ..anglerId = anglerId1
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
      sortOrder: anyNamed("sortOrder"),
      filter: anyNamed("filter"),
      dateRange: anyNamed("dateRange"),
      isCatchAndReleaseOnly: anyNamed("isCatchAndReleaseOnly"),
      isFavoritesOnly: anyNamed("isFavoritesOnly"),
      anglerIds: anyNamed("anglerIds"),
      baits: anyNamed("baits"),
      catchIds: anyNamed("catchIds"),
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
      (catchesOverride ?? catches)
        ..sort((lhs, rhs) => rhs.timestamp.compareTo(lhs.timestamp)),
    );
  }

  Future<void> pumpCatchSummary(
    WidgetTester tester,
    CatchSummary Function(BuildContext) builder,
  ) async {
    await pumpContext(
      tester,
      (context) => SingleChildScrollView(child: builder(context)),
      appManager: appManager,
    );
  }

  setUp(() {
    appManager = StubbedAppManager();
    resetCatches();

    anglerManager = appManager.anglerManager;
    when(anglerManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(anglerManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);
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
    when(baitManager.attachmentsDisplayValues(any, any)).thenReturn([]);
    when(baitManager.attachmentDisplayValue(any, any)).thenReturn("Attachment");
    when(baitManager.variant(any, any)).thenReturn(null);
    when(baitManager.formatNameWithCategory(any)).thenReturn("Name");

    bodyOfWaterManager = appManager.bodyOfWaterManager;
    when(bodyOfWaterManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(bodyOfWaterManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(bodyOfWaterManager.list()).thenReturn(bodyOfWaterMap.values.toList());
    when(bodyOfWaterManager.entity(any)).thenAnswer(
        (invocation) => bodyOfWaterMap[invocation.positionalArguments[0]]);

    catchManager = appManager.catchManager;
    when(catchManager.list()).thenReturn(catches);
    when(catchManager.deleteMessage(any, any)).thenReturn("Delete");

    when(appManager.timeManager.currentDateTime)
        .thenReturn(DateTime.fromMillisecondsSinceEpoch(105000));
    when(appManager.timeManager.msSinceEpoch).thenReturn(
        DateTime.fromMillisecondsSinceEpoch(105000).millisecondsSinceEpoch);

    fishingSpotManager = appManager.fishingSpotManager;
    when(fishingSpotManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(fishingSpotManager.displayName(
      any,
      any,
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
      includeLatLngLabels: anyNamed("includeLatLngLabels"),
    )).thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(fishingSpotManager.list()).thenReturn(fishingSpotMap.values.toList());
    when(fishingSpotManager.entity(any)).thenAnswer(
        (invocation) => fishingSpotMap[invocation.positionalArguments[0]]);
    when(fishingSpotManager.nameComparator)
        .thenReturn((lhs, rhs) => compareIgnoreCase(lhs.name, rhs.name));

    methodManager = appManager.methodManager;
    when(methodManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(methodManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(methodManager.list()).thenReturn(methodMap.values.toList());
    when(methodManager.entity(any)).thenAnswer(
        (invocation) => methodMap[invocation.positionalArguments[0]]);

    speciesManager = appManager.speciesManager;
    when(speciesManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(speciesManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);
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
    when(waterClarityManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(waterClarityManager.list()).thenReturn(clarityMap.values.toList());
    when(waterClarityManager.entity(any)).thenAnswer(
        (invocation) => clarityMap[invocation.positionalArguments[0]]);

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
    when(appManager.userPreferenceManager.mapType).thenReturn("satellite");

    when(appManager.propertiesManager.mapboxApiKey).thenReturn("KEY");

    stubCatchesByTimestamp();
  });

  testWidgets("Date picker hidden when static", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
        isStatic: true,
      ),
    );
    expect(find.byType(DateRangePickerInput), findsNothing);
  });

  testWidgets("Date picker shown", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
        isStatic: false,
      ),
    );
    expect(find.byType(DateRangePickerInput), findsOneWidget);
  });

  testWidgets("Entity picker hidden when widget.picker is null",
      (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) {
          reportBuilderCount++;
          return CatchSummaryReport(context: context);
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
        reportBuilder: (_, __) => CatchSummaryReport(
          context: context,
          ranges: [DateRange(period: DateRange_Period.lastWeek)],
        ),
      ),
    );

    var tileRow = findFirst<TileRow>(tester);
    expect(tileRow.items.length, 1);
  });

  testWidgets("Catches tile with quantity = 1", (tester) async {
    stubCatchesByTimestamp([Catch(id: randomId())]);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(
          context: context,
          ranges: [DateRange(period: DateRange_Period.lastWeek)],
        ),
      ),
    );
    expect(find.text("Catch"), findsOneWidget);

    // Verify catch list is opened if there are catches in the current report.
    await tapAndSettle(tester, find.text("Catch"));
    expect(find.byType(CatchListPage), findsOneWidget);
  });

  testWidgets("Catches tile with quantity != 1", (tester) async {
    stubCatchesByTimestamp([]);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(
          context: context,
          ranges: [DateRange(period: DateRange_Period.lastWeek)],
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
        reportBuilder: (_, __) => CatchSummaryReport(
          context: context,
          ranges: [
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
        reportBuilder: (_, __) => CatchSummaryReport(
          context: context,
          ranges: [DateRange(period: DateRange_Period.thisWeek)],
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );

    await tapAndSettle(tester, find.text("Since Last Catch"));
    expect(find.byType(CatchPage), findsNothing);
  });

  testWidgets("Catches per species shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Species"), findsOneWidget);
  });

  testWidgets("Catches per species hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingSpecies).thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Fishing Spot"), findsNothing);
  });

  testWidgets("Catches per bait shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingBaits).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Bait"), findsOneWidget);
  });

  testWidgets("Catches per bait hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingBaits).thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Moon Phase"), findsNothing);
  });

  testWidgets("Catches per tide type shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingTides).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Tide"), findsOneWidget);
  });

  testWidgets("Catches per tide type hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingTides).thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Tide"), findsNothing);
  });

  testWidgets("Catches per angler shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Angler"), findsOneWidget);
  });

  testWidgets("Catches per angler hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingAnglers).thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Angler"), findsNothing);
  });

  testWidgets("Catches per body of water shown", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Body Of Water"), findsOneWidget);
  });

  testWidgets("Catches per body of water hidden", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<BodyOfWater>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Body Of Water"), findsNothing);
  });

  testWidgets("Catches per fishing method shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingMethods).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Fishing Method"), findsOneWidget);
  });

  testWidgets("Catches per fishing method hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingMethods).thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Fishing Method"), findsNothing);
  });

  testWidgets("Catches per period shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingPeriods).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Time Of Day"), findsOneWidget);
  });

  testWidgets("Catches per period hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingPeriods).thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Time Of Day"), findsNothing);
  });

  testWidgets("Catches per season shown", (tester) async {
    when(appManager.userPreferenceManager.isTrackingSeasons).thenReturn(true);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Season"), findsOneWidget);
  });

  testWidgets("Catches per season hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingSeasons).thenReturn(false);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Water Clarity"), findsNothing);
  });

  testWidgets("CatchSummaryReport multiple date ranges", (tester) async {
    var report = CatchSummaryReport(
      context: await buildContext(tester, appManager: appManager),
      ranges: [
        DateRange(period: DateRange_Period.lastWeek),
        DateRange(period: DateRange_Period.thisWeek),
      ],
    );
    expect(report.dateRanges.length, 2);
    expect(report.dateRanges[0], DateRange(period: DateRange_Period.lastWeek));
    expect(report.dateRanges[1], DateRange(period: DateRange_Period.thisWeek));
  });

  testWidgets("CatchSummaryReport summary properties null if no catches",
      (tester) async {
    stubCatchesByTimestamp([]);
    var report = CatchSummaryReport(
      context: await buildContext(tester, appManager: appManager),
    );
    expect(report.lastCatch, isNull);
    expect(report.hasLastCatch, isFalse);
    expect(report.msSinceLastCatch, 0);
  });

  testWidgets("CatchSummaryReport summary properties null if comparing",
      (tester) async {
    var report = CatchSummaryReport(
      context: await buildContext(tester, appManager: appManager),
      ranges: [
        DateRange(period: DateRange_Period.lastWeek),
        DateRange(period: DateRange_Period.thisWeek),
      ],
    );
    expect(report.lastCatch, isNull);
    expect(report.hasLastCatch, isFalse);
    expect(report.msSinceLastCatch, 0);
  });

  testWidgets("CatchSummaryReport summary filters includes date range",
      (tester) async {
    var report = CatchSummaryReport(
      context: await buildContext(tester, appManager: appManager),
      ranges: [
        DateRange(period: DateRange_Period.lastWeek),
      ],
    );
    var filters = report.filters();
    expect(filters.contains("Last week"), isTrue);
  });

  testWidgets("CatchSummaryReport filters includes species", (tester) async {
    var report = CatchSummaryReport(
      context: await buildContext(tester, appManager: appManager),
      speciesIds: {speciesId0, speciesId1},
    );

    var filters = report.filters(includeSpecies: true);
    expect(filters.contains("Bluegill"), isTrue);
    expect(filters.contains("Pike"), isTrue);

    filters = report.filters(includeSpecies: false);
    expect(filters.contains("Bluegill"), isFalse);
    expect(filters.contains("Pike"), isFalse);
  });

  testWidgets("CatchSummaryReport filters includes catch and release",
      (tester) async {
    var report = CatchSummaryReport(
      context: await buildContext(tester, appManager: appManager),
      isCatchAndReleaseOnly: true,
    );
    var filters = report.filters();
    expect(filters.contains("Catch and release only"), isTrue);
  });

  testWidgets("CatchSummaryReport filters includes favorites", (tester) async {
    var report = CatchSummaryReport(
      context: await buildContext(tester, appManager: appManager),
      isFavoritesOnly: true,
    );
    var filters = report.filters();
    expect(filters.contains("Favorites only"), isTrue);
  });

  testWidgets("CatchSummaryReport filters skip null number filters",
      (tester) async {
    var report = CatchSummaryReport(
      context: await buildContext(tester, appManager: appManager),
      ranges: [
        DateRange(period: DateRange_Period.lastWeek),
        DateRange(period: DateRange_Period.thisWeek),
      ],
    );
    var filters = report.filters(includeSpecies: false);
    expect(filters.isEmpty, isTrue);
  });

  testWidgets("CatchSummaryReport filters includes number filters",
      (tester) async {
    var report = CatchSummaryReport(
      context: await buildContext(tester, appManager: appManager),
      ranges: [
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
    var filters = report.filters(includeSpecies: false);
    expect(filters.length, 1);
    expect(filters.first, "Length: = 25 cm");
  });

  testWidgets("CatchSummaryReport filters skip null entities", (tester) async {
    when(speciesManager.entity(speciesId0)).thenReturn(null);
    var report = CatchSummaryReport(
      context: await buildContext(tester, appManager: appManager),
      speciesIds: {speciesId0, speciesId1},
    );
    var filters = report.filters();
    expect(filters.contains("Bluegill"), isFalse);
    expect(filters.contains("Pike"), isTrue);
  });

  testWidgets("Model filled with zeros", (tester) async {
    stubCatchesByTimestamp([]);
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    // There are 11 charts, each with 3 items, and all values should equal 0.
    expect(find.substring("(0)"), findsNWidgets(33));
  });

  testWidgets("Model filled with zeros skips entities that aren't tracked",
      (tester) async {
    when(appManager.userPreferenceManager.isTrackingSeasons).thenReturn(false);
    when(appManager.userPreferenceManager.isTrackingTides).thenReturn(false);
    stubCatchesByTimestamp([]);

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );

    // There are 11 charts total, minus seasons and tides, each with 3 items,
    // and all values should equal 0.
    expect(find.substring("(0)"), findsNWidgets(27));
  });

  testWidgets("Model increment entities skips entities that aren't tracked",
      (tester) async {
    when(appManager.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(false);
    var report = CatchSummaryReport(
      context: await buildContext(
        tester,
        appManager: appManager,
      ),
    );
    expect(report.hasPerFishingSpot, isFalse);
  });

  testWidgets("Model increment entities no baits", (tester) async {
    for (var cat in catches) {
      cat.baits.clear();
    }
    when(baitManager.attachmentDisplayValue(any, any)).thenReturn("Dummy");

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );

    // Since all catches have been cleared of methods, method values should all
    // be 0.
    expect(find.text("Dummy (0)"), findsNWidgets(3));
  });

  testWidgets("Model increment entities no atmosphere", (tester) async {
    for (var cat in catches) {
      cat.clearAtmosphere();
    }

    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Catch>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
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
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );

    // Species
    await tester.ensureVisible(find.text("View all species"));
    await tapAndSettle(tester, find.text("View all species"));
    expect(find.text("Bluegill (1)"), findsOneWidget);
    expect(find.text("Pike (4)"), findsOneWidget);
    expect(find.text("Catfish (0)"), findsOneWidget);
    expect(find.text("Bass (2)"), findsOneWidget);
    expect(find.text("Steelhead (3)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Fishing Spots
    await tester.ensureVisible(find.text("View all fishing spots"));
    await tapAndSettle(tester, find.text("View all fishing spots"));
    expect(find.text("E (1)"), findsOneWidget);
    expect(find.text("C (6)"), findsOneWidget);
    expect(find.text("B (1)"), findsOneWidget);
    expect(find.text("D (1)"), findsOneWidget);
    expect(find.text("A (1)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Baits
    await tester.ensureVisible(find.text("View all baits"));
    await tapAndSettle(tester, find.text("View all baits"));
    expect(find.text("Attachment (1)"), findsNWidgets(2));
    expect(find.text("Attachment (5)"), findsOneWidget);
    expect(find.text("Attachment (3)"), findsOneWidget);
    expect(find.text("Attachment (0)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Moon phases
    await tester.ensureVisible(find.text("View all moon phases"));
    await tapAndSettle(tester, find.text("View all moon phases"));
    expect(find.text("New (1)"), findsOneWidget);
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
    expect(find.text("High (1)"), findsOneWidget);
    expect(find.text("Slack (0)"), findsOneWidget);
    expect(find.text("Incoming (1)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Anglers
    await tester.ensureVisible(find.text("View all anglers"));
    await tapAndSettle(tester, find.text("View all anglers"));
    expect(find.text("Cohen (1)"), findsOneWidget);
    expect(find.text("Eli (2)"), findsOneWidget);
    expect(find.text("Ethan (0)"), findsOneWidget);
    expect(find.text("Tim (0)"), findsOneWidget);
    expect(find.text("Someone (0)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Bodies of water
    await tester.ensureVisible(find.text("View all bodies of water"));
    await tapAndSettle(tester, find.text("View all bodies of water"));
    expect(find.text("Lake Huron (1)"), findsOneWidget);
    expect(find.text("Tennessee River (6)"), findsOneWidget);
    expect(find.text("Bow River (1)"), findsOneWidget);
    expect(find.text("Nine Mile River (1)"), findsOneWidget);
    expect(find.text("Maitland River (1)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Fishing methods
    await tester.ensureVisible(find.text("View all fishing methods"));
    await tapAndSettle(tester, find.text("View all fishing methods"));
    expect(find.text("Casting (2)"), findsOneWidget);
    expect(find.text("Shore (1)"), findsOneWidget);
    expect(find.text("Kayak (0)"), findsOneWidget);
    expect(find.text("Drift (0)"), findsOneWidget);
    expect(find.text("Ice (0)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Periods
    await tester.ensureVisible(find.text("View all times of day"));
    await tapAndSettle(tester, find.text("View all times of day"));
    expect(find.text("Dawn (0)"), findsOneWidget);
    expect(find.text("Morning (1)"), findsOneWidget);
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
    expect(find.text("Autumn (1)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Water clarities
    await tester.ensureVisible(find.text("View all water clarities"));
    await tapAndSettle(tester, find.text("View all water clarities"));
    expect(find.text("Clear (0)"), findsOneWidget);
    expect(find.text("Tea Stained (0)"), findsOneWidget);
    expect(find.text("Chocolate Milk (1)"), findsOneWidget);
    expect(find.text("Crystal (1)"), findsOneWidget);
    expect(find.text("1 Foot (1)"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));
  });

  testWidgets("Model anglers excluded when T is Angler", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Angler>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Angler"), findsNothing);
  });

  testWidgets("Model baits excluded when T is BaitAttachment", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<BaitAttachment>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Bait"), findsNothing);
  });

  testWidgets("Model bodies of water excluded when T is BodyOfWater",
      (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<BodyOfWater>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Body Of Water"), findsNothing);
  });

  testWidgets("Model methods excluded when T is Method", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Method>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Fishing Method"), findsNothing);
  });

  testWidgets("Model fishing spots excluded when T is FishingSpot",
      (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<FishingSpot>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Fishing Spot"), findsNothing);
  });

  testWidgets("Model moon phases excluded when T is MoonPhase", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<MoonPhase>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Moon Phase"), findsNothing);
  });

  testWidgets("Model seasons excluded when T is Season", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Season>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Season"), findsNothing);
  });

  testWidgets("Model species excluded when T is Species", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<Species>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Species"), findsNothing);
  });

  testWidgets("Model tide types excluded when T is TideType", (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<TideType>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Tide"), findsNothing);
  });

  testWidgets("Model water clarities excluded when T is WaterClarity",
      (tester) async {
    await pumpCatchSummary(
      tester,
      (context) => CatchSummary<WaterClarity>(
        reportBuilder: (_, __) => CatchSummaryReport(context: context),
      ),
    );
    expect(find.text("Per Water Clarity"), findsNothing);
  });
}
