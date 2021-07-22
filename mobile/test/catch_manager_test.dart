import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
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
  late MockWaterClarityManager waterClarityManager;

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

    waterClarityManager = appManager.waterClarityManager;
    when(waterClarityManager.matchesFilter(any, any)).thenReturn(false);

    when(appManager.methodManager.idsMatchFilter(any, any)).thenReturn(false);

    catchManager = CatchManager(appManager.app);
  });

  testWidgets("Filtering by nothing returns all catches", (tester) async {
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);

    expect(catchManager.filteredCatches(context).length, 3);
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
    when(baitManager.idsMatchFilter(any, any)).thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baitIds.add(randomId()));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baitIds.add(randomId()));

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

  testWidgets("Filtering by search query; water clarity", (tester) async {
    when(appManager.waterClarityManager.matchesFilter(any, any))
        .thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..waterClarityId = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..waterClarityId = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "Clarity").length, 2);
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

  testWidgets("Filtering by search query; period", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..period = Period.dawn);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..period = Period.afternoon);
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "NOON").length, 1);
    expect(catchManager.filteredCatches(context, filter: "dawn").length, 1);
    expect(
        catchManager.filteredCatches(context, filter: "dusk").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; season", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..season = Season.autumn);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..season = Season.spring);
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "SPri").length, 1);
    expect(catchManager.filteredCatches(context, filter: "autumn").length, 1);
    expect(
        catchManager.filteredCatches(context, filter: "fall").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; wind direction", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(windDirection: Direction.east));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "eas").length, 1);
    expect(catchManager.filteredCatches(context, filter: "east").length, 1);
    expect(
        catchManager.filteredCatches(context, filter: "west").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; sky conditions", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere =
          Atmosphere(skyConditions: [SkyCondition.rain, SkyCondition.cloudy]));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(skyConditions: [SkyCondition.snow]));
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "snow").length, 1);
    expect(catchManager.filteredCatches(context, filter: "rain").length, 1);
    expect(
        catchManager.filteredCatches(context, filter: "fog").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; moon phase", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(moonPhase: MoonPhase.first_quarter));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(moonPhase: MoonPhase.last_quarter));
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "quart").length, 2);
    expect(catchManager.filteredCatches(context, filter: "last").length, 1);
    expect(
        catchManager.filteredCatches(context, filter: "full").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; tide type", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..tide = Tide(type: TideType.high));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..tide = Tide(type: TideType.outgoing));
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "out").length, 1);
    expect(catchManager.filteredCatches(context, filter: "tide").length, 2);
    expect(
        catchManager.filteredCatches(context, filter: "full").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; favorite", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..isFavorite = true);
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "favorite").length, 1);
    expect(catchManager.filteredCatches(context, filter: "orite").length, 1);
    expect(
        catchManager.filteredCatches(context, filter: "dusk").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; catch and release", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..wasCatchAndRelease = true);
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "release").length, 1);
    expect(catchManager.filteredCatches(context, filter: "kept").length, 1);
    expect(
        catchManager.filteredCatches(context, filter: "dusk").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; water depth", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..waterDepth = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 50,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "50").length, 1);
    expect(catchManager.filteredCatches(context, filter: "metre").length, 1);
    expect(
        catchManager.filteredCatches(context, filter: "feet").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; water temperature", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..waterTemperature = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.fahrenheit,
          value: 10,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "fahren").length, 1);
    expect(catchManager.filteredCatches(context, filter: "10").length, 1);
    expect(catchManager.filteredCatches(context, filter: "degrees").length, 1);
    expect(catchManager.filteredCatches(context, filter: "celsius").isEmpty,
        isTrue);
  });

  testWidgets("Filtering by search query; length", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..length = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.centimeters,
          value: 50,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "cent").length, 1);
    expect(catchManager.filteredCatches(context, filter: "cm").length, 1);
    expect(
        catchManager.filteredCatches(context, filter: "inch").isEmpty, isTrue);
    expect(
        catchManager.filteredCatches(context, filter: "error").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; weight", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..weight = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 50,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "pounds").length, 1);
    expect(catchManager.filteredCatches(context, filter: "oz").length, 1);
    expect(catchManager.filteredCatches(context, filter: "50").length, 1);
    expect(catchManager.filteredCatches(context, filter: "25").isEmpty, isTrue);
    expect(
        catchManager.filteredCatches(context, filter: "kilo").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; quantity", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..quantity = 10);
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "10").length, 1);
    expect(
        catchManager.filteredCatches(context, filter: "err").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; air temperature", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        temperature: Measurement(
          unit: Unit.fahrenheit,
          value: 80,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "fahre").length, 1);
    expect(catchManager.filteredCatches(context, filter: "f").length, 1);
    expect(catchManager.filteredCatches(context, filter: "80").length, 1);
    expect(catchManager.filteredCatches(context, filter: "30").isEmpty, isTrue);
    expect(catchManager.filteredCatches(context, filter: "celsius").isEmpty,
        isTrue);
  });

  testWidgets("Filtering by search query; air pressure", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        pressure: Measurement(
          unit: Unit.millibars,
          value: 1000,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "mill").length, 1);
    expect(catchManager.filteredCatches(context, filter: "mb").length, 1);
    expect(catchManager.filteredCatches(context, filter: "1000").length, 1);
    expect(catchManager.filteredCatches(context, filter: "30").isEmpty, isTrue);
    expect(
        catchManager.filteredCatches(context, filter: "pound").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; air humidity", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        humidity: Measurement(
          unit: Unit.percent,
          value: 50,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "humid").length, 1);
    expect(catchManager.filteredCatches(context, filter: "%").length, 1);
    expect(catchManager.filteredCatches(context, filter: "50").length, 1);
    expect(catchManager.filteredCatches(context, filter: "30").isEmpty, isTrue);
    expect(
        catchManager.filteredCatches(context, filter: "pound").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; air visibility", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        visibility: Measurement(
          unit: Unit.kilometers,
          value: 10.5,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "kilo").length, 1);
    expect(catchManager.filteredCatches(context, filter: "km").length, 1);
    expect(catchManager.filteredCatches(context, filter: "10.5").length, 1);
    expect(catchManager.filteredCatches(context, filter: "30").isEmpty, isTrue);
    expect(
        catchManager.filteredCatches(context, filter: "pound").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; wind speed", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        windSpeed: Measurement(
          unit: Unit.kilometers_per_hour,
          value: 9,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.filteredCatches(context, filter: "kilo").length, 1);
    expect(catchManager.filteredCatches(context, filter: "km").length, 1);
    expect(catchManager.filteredCatches(context, filter: "9").length, 1);
    expect(catchManager.filteredCatches(context, filter: "30").isEmpty, isTrue);
    expect(
        catchManager.filteredCatches(context, filter: "pound").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; notes", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..notes = "Some notes for the catch.");
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(
        catchManager.filteredCatches(context, filter: "some notes").length, 1);
    expect(catchManager.filteredCatches(context, filter: "the").length, 1);
    expect(
        catchManager.filteredCatches(context, filter: "bait").isEmpty, isTrue);
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

  testWidgets("Filtering by water clarity", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    var clarityId0 = randomId();
    var clarityId1 = randomId();
    var clarityId2 = randomId();

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..waterClarityId = clarityId0);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..waterClarityId = clarityId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..waterClarityId = clarityId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..waterClarityId = clarityId2);

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      waterClarityIds: {clarityId1},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(
      context,
      waterClarityIds: {clarityId1, clarityId2},
    );
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(
      context,
      waterClarityIds: {randomId()},
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
        period: DateRange_Period.custom,
        startTimestamp: Int64(0),
        endTimestamp: Int64(15000),
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 3);

    catches = catchManager.filteredCatches(
      context,
      dateRange: DateRange(
        period: DateRange_Period.custom,
        startTimestamp: Int64(20001),
        endTimestamp: Int64(30000),
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
      ..baitIds.add(baitId0));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baitIds.add(baitId1));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baitIds.add(baitId0));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baitIds.add(baitId3));

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

  testWidgets("Filtering by period", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..period = Period.dawn);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..period = Period.afternoon);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..period = Period.dawn);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..period = Period.dusk);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 4, 4).millisecondsSinceEpoch));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      periods: {Period.dusk},
    );
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(
      context,
      periods: {Period.dusk, Period.afternoon},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 5);

    catches = catchManager.filteredCatches(
      context,
      periods: {Period.morning},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by season", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..season = Season.winter);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..season = Season.spring);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..season = Season.summer);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 4, 4).millisecondsSinceEpoch));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      seasons: {Season.winter},
    );
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(
      context,
      seasons: {Season.spring, Season.summer},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(
      context,
      seasons: {Season.autumn},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by wind direction", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(windDirection: Direction.east));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(windDirection: Direction.west));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(windDirection: Direction.north));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 4, 4).millisecondsSinceEpoch));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      windDirections: {Direction.east},
    );
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(
      context,
      windDirections: {Direction.east, Direction.north},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(
      context,
      windDirections: {Direction.south},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by sky condition", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(skyConditions: [SkyCondition.rain]));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..atmosphere =
          Atmosphere(skyConditions: [SkyCondition.snow, SkyCondition.clear]));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(skyConditions: [SkyCondition.fog]));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 4, 4).millisecondsSinceEpoch));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      skyConditions: {SkyCondition.clear},
    );
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(
      context,
      skyConditions: {SkyCondition.clear, SkyCondition.fog},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(
      context,
      skyConditions: {SkyCondition.storm},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by moon phase", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(moonPhase: MoonPhase.full));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(moonPhase: MoonPhase.waning_crescent));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(moonPhase: MoonPhase.new_));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 4, 4).millisecondsSinceEpoch));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      moonPhases: {MoonPhase.full},
    );
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(
      context,
      moonPhases: {MoonPhase.full, MoonPhase.new_},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(
      context,
      moonPhases: {MoonPhase.waxing_gibbous},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by tide type", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..tide = Tide(type: TideType.high));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..tide = Tide(type: TideType.outgoing));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..tide = Tide(type: TideType.slack));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 4, 4).millisecondsSinceEpoch));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      tideTypes: {TideType.slack},
    );
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(
      context,
      tideTypes: {TideType.slack, TideType.outgoing},
    );
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    catches = catchManager.filteredCatches(
      context,
      tideTypes: {TideType.incoming},
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by favorite", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..isFavorite = true);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..isFavorite = true);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..isFavorite = true);

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      isFavoritesOnly: true,
    );
    expect(catches.length, 3);

    expect(catchManager.filteredCatches(context).length, 4);
  });

  testWidgets("Filtering by catch and release", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..wasCatchAndRelease = true);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..wasCatchAndRelease = true);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..wasCatchAndRelease = true);

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.filteredCatches(
      context,
      isCatchAndReleaseOnly: true,
    );
    expect(catches.length, 3);

    expect(catchManager.filteredCatches(context).length, 4);
  });

  testWidgets("Filtering by water depth", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..waterDepth = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 50,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..waterDepth = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 15,
        ),
      ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.filteredCatches(
      context,
      waterDepthFilter: NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.meters,
            value: 10,
          ),
        ),
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.filteredCatches(
      context,
      waterDepthFilter: NumberFilter(
        boundary: NumberBoundary.less_than_or_equal_to,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.meters,
            value: 50,
          ),
        ),
      ),
    );
    expect(catches.length, 2);
  });

  testWidgets("Filtering by water temperature", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..waterTemperature = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.celsius,
          value: 20,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..waterTemperature = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.celsius,
          value: 15,
        ),
      ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.filteredCatches(
      context,
      waterTemperatureFilter: NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.celsius,
            value: 10,
          ),
        ),
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.filteredCatches(
      context,
      waterTemperatureFilter: NumberFilter(
        boundary: NumberBoundary.less_than_or_equal_to,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.celsius,
            value: 50,
          ),
        ),
      ),
    );
    expect(catches.length, 2);
  });

  testWidgets("Filtering by length", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..length = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.centimeters,
          value: 50,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..length = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.centimeters,
          value: 15,
        ),
      ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.filteredCatches(
      context,
      lengthFilter: NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.centimeters,
            value: 10,
          ),
        ),
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.filteredCatches(
      context,
      lengthFilter: NumberFilter(
        boundary: NumberBoundary.less_than_or_equal_to,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.centimeters,
            value: 50,
          ),
        ),
      ),
    );
    expect(catches.length, 2);
  });

  testWidgets("Filtering by weight", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..weight = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.kilograms,
          value: 50,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..weight = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.kilograms,
          value: 15,
        ),
      ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.filteredCatches(
      context,
      weightFilter: NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilograms,
            value: 10,
          ),
        ),
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.filteredCatches(
      context,
      weightFilter: NumberFilter(
        boundary: NumberBoundary.less_than_or_equal_to,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilograms,
            value: 50,
          ),
        ),
      ),
    );
    expect(catches.length, 2);
  });

  testWidgets("Filtering by quantity", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..quantity = 10);
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..quantity = 50);

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.filteredCatches(
      context,
      quantityFilter: NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        ),
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.filteredCatches(
      context,
      quantityFilter: NumberFilter(
        boundary: NumberBoundary.less_than_or_equal_to,
        from: MultiMeasurement(
          mainValue: Measurement(
            value: 50,
          ),
        ),
      ),
    );
    expect(catches.length, 2);
  });

  testWidgets("Filtering by air temperature", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        temperature: Measurement(
          unit: Unit.fahrenheit,
          value: 80,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        temperature: Measurement(
          unit: Unit.fahrenheit,
          value: 60,
        ),
      ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.filteredCatches(
      context,
      airTemperatureFilter: NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.fahrenheit,
            value: 40,
          ),
        ),
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.filteredCatches(
      context,
      airTemperatureFilter: NumberFilter(
        boundary: NumberBoundary.less_than_or_equal_to,
        from: MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.fahrenheit,
            value: 80,
          ),
        ),
      ),
    );
    expect(catches.length, 2);
  });

  testWidgets("Filtering by air pressure", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        pressure: Measurement(
          unit: Unit.millibars,
          value: 1000,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        pressure: Measurement(
          unit: Unit.millibars,
          value: 1300,
        ),
      ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.filteredCatches(
      context,
      airPressureFilter: NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.millibars,
            value: 800,
          ),
        ),
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.filteredCatches(
      context,
      airPressureFilter: NumberFilter(
        boundary: NumberBoundary.greater_than,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.millibars,
            value: 900,
          ),
        ),
      ),
    );
    expect(catches.length, 2);
  });

  testWidgets("Filtering by air humidity", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        humidity: Measurement(
          unit: Unit.percent,
          value: 80,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        humidity: Measurement(
          unit: Unit.percent,
          value: 30,
        ),
      ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.filteredCatches(
      context,
      airHumidityFilter: NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          mainValue: Measurement(
            unit: Unit.percent,
            value: 30,
          ),
        ),
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.filteredCatches(
      context,
      airHumidityFilter: NumberFilter(
        boundary: NumberBoundary.greater_than_or_equal_to,
        from: MultiMeasurement(
          mainValue: Measurement(
            unit: Unit.percent,
            value: 30,
          ),
        ),
      ),
    );
    expect(catches.length, 2);
  });

  testWidgets("Filtering by air visibility", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        visibility: Measurement(
          unit: Unit.miles,
          value: 10.5,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        visibility: Measurement(
          unit: Unit.miles,
          value: 8,
        ),
      ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.filteredCatches(
      context,
      airVisibilityFilter: NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.imperial_decimal,
          mainValue: Measurement(
            unit: Unit.miles,
            value: 5.5,
          ),
        ),
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.filteredCatches(
      context,
      airVisibilityFilter: NumberFilter(
        boundary: NumberBoundary.greater_than,
        from: MultiMeasurement(
          system: MeasurementSystem.imperial_decimal,
          mainValue: Measurement(
            unit: Unit.miles,
            value: 5.5,
          ),
        ),
      ),
    );
    expect(catches.length, 2);
  });

  testWidgets("Filtering by wind speed", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        windSpeed: Measurement(
          unit: Unit.kilometers_per_hour,
          value: 10.5,
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        windSpeed: Measurement(
          unit: Unit.kilometers_per_hour,
          value: 5,
        ),
      ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.filteredCatches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.filteredCatches(
      context,
      windSpeedFilter: NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilometers_per_hour,
            value: 4,
          ),
        ),
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.filteredCatches(
      context,
      windSpeedFilter: NumberFilter(
        boundary: NumberBoundary.greater_than_or_equal_to,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilometers_per_hour,
            value: 5,
          ),
        ),
      ),
    );
    expect(catches.length, 2);
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
      ..baitIds.add(baitId0)
      ..fishingSpotId = fishingSpotId0);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(10000)
      ..speciesId = speciesId1
      ..baitIds.add(baitId1)
      ..fishingSpotId = fishingSpotId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(20000)
      ..speciesId = speciesId1
      ..baitIds.add(baitId0)
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
