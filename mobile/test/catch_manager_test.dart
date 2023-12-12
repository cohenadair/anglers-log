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

    when(appManager.anglerManager.matchesFilter(any, any, any))
        .thenReturn(false);

    baitCategoryManager = appManager.baitCategoryManager;
    when(baitCategoryManager.listen(any))
        .thenAnswer((_) => MockStreamSubscription());

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
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    fishingSpotManager = FishingSpotManager(appManager.app);
    when(appManager.app.fishingSpotManager).thenReturn(fishingSpotManager);

    baitManager = BaitManager(appManager.app);
    when(appManager.app.baitManager).thenReturn(baitManager);

    speciesManager = appManager.speciesManager;
    when(speciesManager.matchesFilter(any, any, any)).thenReturn(false);

    waterClarityManager = appManager.waterClarityManager;
    when(waterClarityManager.matchesFilter(any, any, any)).thenReturn(false);

    when(appManager.methodManager.idsMatchFilter(any, any, any))
        .thenReturn(false);
    when(appManager.gearManager.idsMatchFilter(any, any, any))
        .thenReturn(false);

    when(appManager.userPreferenceManager.airTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airPressureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airVisibilitySystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.metric);

    catchManager = CatchManager(appManager.app);
  });

  test("initialize updates catch time zones", () async {
    var catchId1 = randomId();
    var catchId2 = randomId();
    var catchId3 = randomId();
    when(appManager.localDatabaseManager.fetchAll(any)).thenAnswer((_) {
      return Future.value([
        {
          "id": catchId1.uint8List,
          "bytes": Catch(
            id: catchId1,
            timestamp: Int64(10),
          ).writeToBuffer(),
        },
        {
          "id": catchId2.uint8List,
          "bytes": Catch(
            id: catchId2,
            timestamp: Int64(15),
            timeZone: defaultTimeZone,
          ).writeToBuffer(),
        },
        {
          "id": catchId3.uint8List,
          "bytes": Catch(
            id: catchId3,
            timestamp: Int64(20),
          ).writeToBuffer(),
        },
      ]);
    });
    when(appManager.timeManager.currentTimeZone).thenReturn("America/Chicago");

    await catchManager.initialize();

    var catches = catchManager.list();
    expect(catches.length, 3);
    expect(catches[0].timeZone, "America/Chicago");
    expect(catches[1].timeZone, "America/New_York");
    expect(catches[2].timeZone, "America/Chicago");

    verifyNever(
        appManager.imageManager.save(any, compress: anyNamed("compress")));
    verify(appManager.localDatabaseManager.insertOrReplace(any, any, any))
        .called(2);
  });

  test("initialize updates catch atmospheres", () async {
    var catchId1 = randomId();
    var catchId2 = randomId();
    var catchId3 = randomId();
    when(appManager.localDatabaseManager.fetchAll(any)).thenAnswer((_) {
      return Future.value([
        {
          "id": catchId1.uint8List,
          "bytes": Catch(
            id: catchId1,
            timestamp: Int64(10),
            timeZone: defaultTimeZone,
            atmosphere: Atmosphere(
              temperatureDeprecated: Measurement(
                unit: Unit.celsius,
                value: 15,
              ),
            ),
          ).writeToBuffer(),
        },
        {
          "id": catchId2.uint8List,
          "bytes": Catch(
            id: catchId2,
            timestamp: Int64(15),
            timeZone: defaultTimeZone,
          ).writeToBuffer(),
        },
        {
          "id": catchId3.uint8List,
          "bytes": Catch(
            id: catchId3,
            timestamp: Int64(20),
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

    await catchManager.initialize();

    var catches = catchManager.list();
    expect(catches.length, 3);
    expect(catches[0].atmosphere.hasTemperatureDeprecated(), isFalse);
    expect(catches[0].atmosphere.hasTemperature(), isTrue);
    expect(catches[1].hasAtmosphere(), isFalse);
    expect(catches[2].atmosphere.hasWindSpeedDeprecated(), isFalse);
    expect(catches[2].atmosphere.hasWindSpeed(), isTrue);

    verifyNever(
        appManager.imageManager.save(any, compress: anyNamed("compress")));
    verify(appManager.localDatabaseManager.insertOrReplace(any, any, any))
        .called(2);
  });

  test("addOrUpdate, setImages=false", () async {
    await catchManager.addOrUpdate(
      Catch()..id = randomId(),
      setImages: false,
    );
    verifyNever(
        appManager.imageManager.save(any, compress: anyNamed("compress")));
    verify(appManager.localDatabaseManager.insertOrReplace(any, any, any))
        .called(1);
  });

  test("addOrUpdate, setImages=true", () async {
    await catchManager.addOrUpdate(
      Catch()..id = randomId(),
      setImages: true,
    );
    verify(appManager.imageManager.save(any, compress: anyNamed("compress")))
        .called(1);
    verify(appManager.localDatabaseManager.insertOrReplace(any, any, any))
        .called(1);
  });

  testWidgets("matchesFilter catch doesn't exist", (tester) async {
    expect(
      catchManager.matchesFilter(
          randomId(), await buildContext(tester), "Test"),
      isFalse,
    );
    verifyNever(speciesManager.matchesFilter(any, any, any));
  });

  testWidgets("Filtering by nothing returns all catches", (tester) async {
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);

    expect(catchManager.catches(context).length, 3);
  });

  testWidgets("Filtering by search query; non-ID reference properties",
      (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..timeZone = "America/New_York");
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..timeZone = "America/New_York");

    var context = await buildContext(tester, appManager: appManager);

    var catches = catchManager.catches(context, filter: "");
    expect(catches.length, 2);

    catches = catchManager.catches(context, filter: "janua");
    expect(catches.length, 1);

    catches = catchManager.catches(context, filter: "april");
    expect(catches.length, 1);

    catches = catchManager.catches(context, filter: "4");
    expect(catches.length, 1);
  });

  testWidgets("Filtering with null context returns false", (tester) async {
    var cat = Catch(id: randomId());
    await catchManager.addOrUpdate(cat);
    expect(
      catchManager.matchesFilter(cat.id, await buildContext(tester), "Test"),
      isFalse,
    );
  });

  testWidgets("Filtering by search query; bait", (tester) async {
    var baitManager = MockBaitManager();
    when(appManager.app.baitManager).thenReturn(baitManager);
    when(baitManager.attachmentsMatchesFilter(any, any, any)).thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baits.add(BaitAttachment(baitId: randomId())));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baits.add(BaitAttachment(baitId: randomId())));

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "Bait").length, 2);
  });

  testWidgets("Filtering by search query; gear", (tester) async {
    when(appManager.gearManager.idsMatchFilter(any, any, any)).thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..gearIds.add(randomId()));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..gearIds.add(randomId()));

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "Gear").length, 2);
  });

  testWidgets("Filtering by search query; fishing spot", (tester) async {
    var fishingSpotManager = MockFishingSpotManager();
    when(appManager.app.fishingSpotManager).thenReturn(fishingSpotManager);
    when(fishingSpotManager.matchesFilter(any, any, any)).thenReturn(true);
    when(fishingSpotManager.entity(any)).thenReturn(null);
    when(fishingSpotManager.entityExists(any)).thenReturn(false);
    when(fishingSpotManager.uuidMap()).thenReturn({});

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..fishingSpotId = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..fishingSpotId = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "Spot").length, 2);
  });

  testWidgets("Filtering by search query; species", (tester) async {
    var speciesManager = MockSpeciesManager();
    when(appManager.app.speciesManager).thenReturn(speciesManager);
    when(speciesManager.matchesFilter(any, any, any)).thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..speciesId = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..speciesId = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "Species").length, 2);
  });

  testWidgets("Filtering by search query; angler", (tester) async {
    when(appManager.anglerManager.matchesFilter(any, any, any))
        .thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..anglerId = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..anglerId = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "Angler").length, 2);
  });

  testWidgets("Filtering by search query; water clarity", (tester) async {
    when(appManager.waterClarityManager.matchesFilter(any, any, any))
        .thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..waterClarityId = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..waterClarityId = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "Clarity").length, 2);
  });

  testWidgets("Filtering by search query; method", (tester) async {
    when(appManager.methodManager.idsMatchFilter(any, any, any))
        .thenReturn(true);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..methodIds.add(randomId()));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..methodIds.add(randomId()));

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "Method").length, 2);
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
    expect(catchManager.catches(context, filter: "NOON").length, 1);
    expect(catchManager.catches(context, filter: "dawn").length, 1);
    expect(catchManager.catches(context, filter: "dusk").isEmpty, isTrue);
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
    expect(catchManager.catches(context, filter: "SPri").length, 1);
    expect(catchManager.catches(context, filter: "autumn").length, 1);
    expect(catchManager.catches(context, filter: "fall").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; wind direction", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(windDirection: Direction.east));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "eas").length, 1);
    expect(catchManager.catches(context, filter: "east").length, 1);
    expect(catchManager.catches(context, filter: "west").isEmpty, isTrue);
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
    expect(catchManager.catches(context, filter: "snow").length, 1);
    expect(catchManager.catches(context, filter: "rain").length, 1);
    expect(catchManager.catches(context, filter: "fog").isEmpty, isTrue);
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
    expect(catchManager.catches(context, filter: "quart").length, 2);
    expect(catchManager.catches(context, filter: "last").length, 1);
    expect(catchManager.catches(context, filter: "full").isEmpty, isTrue);
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
    expect(catchManager.catches(context, filter: "out").length, 1);
    expect(catchManager.catches(context, filter: "tide").length, 2);
    expect(catchManager.catches(context, filter: "full").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; favorite", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..isFavorite = true);
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "favorite").length, 1);
    expect(catchManager.catches(context, filter: "orite").length, 1);
    expect(catchManager.catches(context, filter: "dusk").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; catch and release", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..wasCatchAndRelease = true);
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "release").length, 1);
    expect(catchManager.catches(context, filter: "kept").length, 1);
    expect(catchManager.catches(context, filter: "dusk").isEmpty, isTrue);
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
    expect(catchManager.catches(context, filter: "50").length, 1);
    expect(catchManager.catches(context, filter: "metre").length, 1);
    expect(catchManager.catches(context, filter: "feet").isEmpty, isTrue);
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
    expect(catchManager.catches(context, filter: "fahren").length, 1);
    expect(catchManager.catches(context, filter: "10").length, 1);
    expect(catchManager.catches(context, filter: "degrees").length, 1);
    expect(catchManager.catches(context, filter: "celsius").isEmpty, isTrue);
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
    expect(catchManager.catches(context, filter: "cent").length, 1);
    expect(catchManager.catches(context, filter: "cm").length, 1);
    expect(catchManager.catches(context, filter: "inch").isEmpty, isTrue);
    expect(catchManager.catches(context, filter: "error").isEmpty, isTrue);
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
    expect(catchManager.catches(context, filter: "pounds").length, 1);
    expect(catchManager.catches(context, filter: "oz").length, 1);
    expect(catchManager.catches(context, filter: "50").length, 1);
    expect(catchManager.catches(context, filter: "25").isEmpty, isTrue);
    expect(catchManager.catches(context, filter: "kilo").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; quantity", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..quantity = 10);
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "10").length, 1);
    expect(catchManager.catches(context, filter: "err").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; air temperature", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        temperature: MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.fahrenheit,
            value: 80,
          ),
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "fahre").length, 1);
    expect(catchManager.catches(context, filter: "f").length, 1);
    expect(catchManager.catches(context, filter: "80").length, 1);
    expect(catchManager.catches(context, filter: "30").isEmpty, isTrue);
    expect(catchManager.catches(context, filter: "celsius").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; air pressure", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        pressure: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.millibars,
            value: 1000,
          ),
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "mill").length, 1);
    expect(catchManager.catches(context, filter: "mb").length, 1);
    expect(catchManager.catches(context, filter: "1000").length, 1);
    expect(catchManager.catches(context, filter: "30").isEmpty, isTrue);
    expect(catchManager.catches(context, filter: "pound").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; air humidity", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        humidity: MultiMeasurement(
          mainValue: Measurement(
            unit: Unit.percent,
            value: 50,
          ),
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "humid").length, 1);
    expect(catchManager.catches(context, filter: "%").length, 1);
    expect(catchManager.catches(context, filter: "50").length, 1);
    expect(catchManager.catches(context, filter: "30").isEmpty, isTrue);
    expect(catchManager.catches(context, filter: "pound").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; air visibility", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        visibility: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilometers,
            value: 10.5,
          ),
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "kilo").length, 1);
    expect(catchManager.catches(context, filter: "km").length, 1);
    expect(catchManager.catches(context, filter: "10.5").length, 1);
    expect(catchManager.catches(context, filter: "30").isEmpty, isTrue);
    expect(catchManager.catches(context, filter: "pound").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; wind speed", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        windSpeed: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilometers_per_hour,
            value: 9,
          ),
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "kilo").length, 1);
    expect(catchManager.catches(context, filter: "km").length, 1);
    expect(catchManager.catches(context, filter: "9").length, 1);
    expect(catchManager.catches(context, filter: "30").isEmpty, isTrue);
    expect(catchManager.catches(context, filter: "pound").isEmpty, isTrue);
  });

  testWidgets("Filtering by search query; notes", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..notes = "Some notes for the catch.");
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());

    var context = await buildContext(tester, appManager: appManager);
    expect(catchManager.catches(context, filter: "some notes").length, 1);
    expect(catchManager.catches(context, filter: "the").length, 1);
    expect(catchManager.catches(context, filter: "bait").isEmpty, isTrue);
  });

  testWidgets("Filtering by angler", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    var anglerId0 = randomId();
    var anglerId1 = randomId();
    var anglerId2 = randomId();

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..anglerId = anglerId0);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..anglerId = anglerId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..anglerId = anglerId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..anglerId = anglerId2);

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        anglerIds: {anglerId1},
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        anglerIds: {anglerId1, anglerId2},
      ),
    );
    expect(catches.length, 3);

    catches = catchManager.catches(context);
    expect(catches.length, 4);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        anglerIds: {randomId()},
      ),
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
      ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..waterClarityId = clarityId0);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..waterClarityId = clarityId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..waterClarityId = clarityId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..waterClarityId = clarityId2);

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        waterClarityIds: {clarityId1},
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        waterClarityIds: {clarityId1, clarityId2},
      ),
    );
    expect(catches.length, 3);

    catches = catchManager.catches(context);
    expect(catches.length, 4);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        waterClarityIds: {randomId()},
      ),
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
      ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..speciesId = speciesId0);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..speciesId = speciesId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..speciesId = speciesId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..speciesId = speciesId2);

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        // dateRanges: [DateRange(period: DateRange_Period.allDates)],
        speciesIds: {speciesId1},
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        speciesIds: {speciesId1, speciesId2},
      ),
    );
    expect(catches.length, 3);

    catches = catchManager.catches(context);
    expect(catches.length, 4);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        speciesIds: {randomId()},
      ),
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
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        dateRanges: [
          DateRange(
            period: DateRange_Period.custom,
            startTimestamp: Int64(0),
            endTimestamp: Int64(15000),
          ),
        ],
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(context);
    expect(catches.length, 3);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        dateRanges: [
          DateRange(
            period: DateRange_Period.custom,
            startTimestamp: Int64(20001),
            endTimestamp: Int64(30000),
          ),
        ],
      ),
    );
    expect(catches.isEmpty, true);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        currentTimestamp: Int64(40000),
        dateRanges: [
          DateRange(period: DateRange_Period.allDates),
        ],
      ),
    );
    expect(catches.length, 3);
  });

  testWidgets("Filtering adds time zone to date ranges", (tester) async {
    var filterOptions = CatchFilterOptions(
      dateRanges: [
        DateRange(
          period: DateRange_Period.custom,
          startTimestamp: Int64(0),
          endTimestamp: Int64(15000),
        ),
        DateRange(
          period: DateRange_Period.custom,
          startTimestamp: Int64(0),
          endTimestamp: Int64(15000),
          timeZone: "America/Chicago",
        ),
      ],
    );
    catchManager.catches(
      await buildContext(tester, appManager: appManager),
      opt: filterOptions,
    );

    // Verify filter options was updated correctly.
    expect(filterOptions.dateRanges[0].timeZone, defaultTimeZone);
    expect(filterOptions.dateRanges[1].timeZone, "America/Chicago");
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
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        fishingSpotIds: {fishingSpotId0},
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        fishingSpotIds: {fishingSpotId0, fishingSpotId3},
      ),
    );
    expect(catches.length, 3);

    catches = catchManager.catches(context);
    expect(catches.length, 4);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        fishingSpotIds: {fishingSpotId2},
      ),
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by body of water", (tester) async {
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

    var bodyOfWaterId0 = randomId();
    var bodyOfWaterId1 = randomId();
    var bodyOfWaterId2 = randomId();

    var fishingSpotManager = MockFishingSpotManager();
    when(appManager.app.fishingSpotManager).thenReturn(fishingSpotManager);

    when(fishingSpotManager.uuidMap()).thenReturn({
      fishingSpotId0.uuid: FishingSpot(
        id: fishingSpotId0,
        bodyOfWaterId: bodyOfWaterId0,
      ),
      fishingSpotId1.uuid: FishingSpot(
        id: fishingSpotId1,
        bodyOfWaterId: bodyOfWaterId1,
      ),
      fishingSpotId2.uuid: FishingSpot(
        id: fishingSpotId2,
        bodyOfWaterId: bodyOfWaterId2,
      ),
    });

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        bodyOfWaterIds: {bodyOfWaterId0},
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        bodyOfWaterIds: {bodyOfWaterId0, bodyOfWaterId1},
      ),
    );
    expect(catches.length, 3);

    catches = catchManager.catches(context);
    expect(catches.length, 4);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        bodyOfWaterIds: {randomId()},
      ),
    );
    expect(catches.isEmpty, isTrue);
  });

  testWidgets("Filtering by bait", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    var baitId0 = randomId();
    var baitId1 = randomId();
    var baitId2 = randomId();
    var baitId3 = randomId();

    var baitAttachment0 = BaitAttachment(baitId: baitId0);
    var baitAttachment1 = BaitAttachment(baitId: baitId1);
    var baitAttachment2 = BaitAttachment(baitId: baitId2);
    var baitAttachment3 = BaitAttachment(baitId: baitId3);

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baits.add(baitAttachment0));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baits.add(baitAttachment1));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baits.add(baitAttachment0));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..baits.add(baitAttachment3));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        baits: {baitAttachment0},
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        baits: {baitAttachment0, baitAttachment3},
      ),
    );
    expect(catches.length, 3);

    catches = catchManager.catches(context);
    expect(catches.length, 4);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        baits: {baitAttachment2},
      ),
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by gear", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    var gearId0 = randomId();
    var gearId1 = randomId();
    var gearId2 = randomId();

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..gearIds.add(gearId0));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..gearIds.add(gearId1));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..gearIds.add(gearId1));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..gearIds.add(gearId2));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        gearIds: {gearId1},
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        gearIds: {gearId1, gearId2},
      ),
    );
    expect(catches.length, 3);

    catches = catchManager.catches(context);
    expect(catches.length, 4);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        methodIds: {randomId()},
      ),
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by parent bait includes variants", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    var baitId = randomId();
    var variantId = randomId();

    var baitAttachment0 = BaitAttachment(baitId: baitId, variantId: variantId);
    var baitAttachment1 = BaitAttachment(baitId: baitId);

    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      baits: [baitAttachment0],
    ));
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      baits: [baitAttachment1],
    ));

    var context = await buildContext(tester, appManager: appManager);

    // Verify catch is returned when the bait attachment has a variant.
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        baits: {baitAttachment0},
      ),
    );
    expect(catches.length, 1);

    // Verify catches are returned when the bait doesn't have a variant.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        baits: {baitAttachment1},
      ),
    );
    expect(catches.length, 2);

    // Verify catches are returned when no bait is passed in.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        dateRanges: [DateRange(period: DateRange_Period.allDates)],
      ),
    );
    expect(catches.length, 2);
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
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        catchIds: {catchId2, catchId0},
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(context);
    expect(catches.length, 4);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        catchIds: {randomId()},
      ),
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
      ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..methodIds.add(methodId0));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..methodIds.add(methodId1));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..methodIds.add(methodId1));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..methodIds.add(methodId2));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        methodIds: {methodId1},
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        methodIds: {methodId1, methodId2},
      ),
    );
    expect(catches.length, 3);

    catches = catchManager.catches(context);
    expect(catches.length, 4);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        methodIds: {randomId()},
      ),
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by period", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..period = Period.dawn);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..period = Period.afternoon);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..period = Period.dawn);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..period = Period.dusk);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 4, 4).millisecondsSinceEpoch));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        periods: {Period.dusk},
      ),
    );
    expect(catches.length, 1);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        periods: {Period.dusk, Period.afternoon},
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(context);
    expect(catches.length, 5);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        periods: {Period.morning},
      ),
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by season", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..season = Season.winter);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..season = Season.spring);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..season = Season.summer);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 4, 4).millisecondsSinceEpoch));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        seasons: {Season.winter},
      ),
    );
    expect(catches.length, 1);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        seasons: {Season.spring, Season.summer},
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(context);
    expect(catches.length, 4);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        seasons: {Season.autumn},
      ),
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by wind direction", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(windDirection: Direction.east));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(windDirection: Direction.west));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(windDirection: Direction.north));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 4, 4).millisecondsSinceEpoch));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        windDirections: {Direction.east},
      ),
    );
    expect(catches.length, 1);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        windDirections: {Direction.east, Direction.north},
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(context);
    expect(catches.length, 4);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        windDirections: {Direction.south},
      ),
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by sky condition", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(skyConditions: [SkyCondition.rain]));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..atmosphere =
          Atmosphere(skyConditions: [SkyCondition.snow, SkyCondition.clear]));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(skyConditions: [SkyCondition.fog]));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 4, 4).millisecondsSinceEpoch));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        skyConditions: {SkyCondition.clear},
      ),
    );
    expect(catches.length, 1);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        skyConditions: {SkyCondition.clear, SkyCondition.fog},
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(context);
    expect(catches.length, 4);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        skyConditions: {SkyCondition.storm},
      ),
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by moon phase", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(moonPhase: MoonPhase.full));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(moonPhase: MoonPhase.waning_crescent));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(moonPhase: MoonPhase.new_));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 4, 4).millisecondsSinceEpoch));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        moonPhases: {MoonPhase.full},
      ),
    );
    expect(catches.length, 1);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        moonPhases: {MoonPhase.full, MoonPhase.new_},
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(context);
    expect(catches.length, 4);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        moonPhases: {MoonPhase.waxing_gibbous},
      ),
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by tide type", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..tide = Tide(type: TideType.high));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..tide = Tide(type: TideType.outgoing));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..tide = Tide(type: TideType.slack));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 4, 4).millisecondsSinceEpoch));

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        tideTypes: {TideType.slack},
      ),
    );
    expect(catches.length, 1);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        tideTypes: {TideType.slack, TideType.outgoing},
      ),
    );
    expect(catches.length, 2);

    catches = catchManager.catches(context);
    expect(catches.length, 4);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        tideTypes: {TideType.incoming},
      ),
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Filtering by favorite", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..isFavorite = true);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..isFavorite = true);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..isFavorite = true);

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        isFavoritesOnly: true,
      ),
    );
    expect(catches.length, 3);

    expect(catchManager.catches(context).length, 4);
  });

  testWidgets("Filtering by catch and release", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..wasCatchAndRelease = true);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch));
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 2, 2).millisecondsSinceEpoch)
      ..wasCatchAndRelease = true);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 4, 4).millisecondsSinceEpoch)
      ..wasCatchAndRelease = true);

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        isCatchAndReleaseOnly: true,
      ),
    );
    expect(catches.length, 3);

    expect(catchManager.catches(context).length, 4);
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
    var catches = catchManager.catches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
    var catches = catchManager.catches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
    var catches = catchManager.catches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
    var catches = catchManager.catches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
    var catches = catchManager.catches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        quantityFilter: NumberFilter(
          boundary: NumberBoundary.less_than,
          from: MultiMeasurement(
            mainValue: Measurement(
              value: 10,
            ),
          ),
        ),
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        quantityFilter: NumberFilter(
          boundary: NumberBoundary.less_than_or_equal_to,
          from: MultiMeasurement(
            mainValue: Measurement(
              value: 50,
            ),
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
        temperature: MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.fahrenheit,
            value: 80,
          ),
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        temperature: MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.fahrenheit,
            value: 60,
          ),
        ),
      ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.catches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
      ),
    );
    expect(catches.length, 2);
  });

  testWidgets("Filtering by air pressure", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        pressure: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.millibars,
            value: 1000,
          ),
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        pressure: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.millibars,
            value: 1300,
          ),
        ),
      ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.catches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
      ),
    );
    expect(catches.length, 2);
  });

  testWidgets("Filtering by air humidity", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        humidity: MultiMeasurement(
          mainValue: Measurement(
            unit: Unit.percent,
            value: 80,
          ),
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        humidity: MultiMeasurement(
          mainValue: Measurement(
            unit: Unit.percent,
            value: 30,
          ),
        ),
      ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.catches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        airHumidityFilter: NumberFilter(
          boundary: NumberBoundary.less_than,
          from: MultiMeasurement(
            mainValue: Measurement(
              unit: Unit.percent,
              value: 30,
            ),
          ),
        ),
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        airHumidityFilter: NumberFilter(
          boundary: NumberBoundary.greater_than_or_equal_to,
          from: MultiMeasurement(
            mainValue: Measurement(
              unit: Unit.percent,
              value: 30,
            ),
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
        visibility: MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.miles,
            value: 10.5,
          ),
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        visibility: MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.miles,
            value: 8,
          ),
        ),
      ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.catches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
      ),
    );
    expect(catches.length, 2);
  });

  testWidgets("Filtering by wind speed", (tester) async {
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        windSpeed: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilometers_per_hour,
            value: 10.5,
          ),
        ),
      ));
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()..id = randomId());
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..atmosphere = Atmosphere(
        windSpeed: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilometers_per_hour,
            value: 5,
          ),
        ),
      ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.catches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
      ),
    );
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
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
      ),
    );
    expect(catches.length, 2);
  });

  testWidgets("Filtering by hour", (tester) async {
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      timestamp: Int64(dateTime(0, 0, 0, 5).millisecondsSinceEpoch),
    ));
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      timestamp: Int64(dateTime(0, 0, 0, 10).millisecondsSinceEpoch),
    ));
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      timestamp: Int64(dateTime(0, 0, 0, 8).millisecondsSinceEpoch),
    ));
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      timestamp: Int64(dateTime(0, 0, 0, 5).millisecondsSinceEpoch),
    ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.catches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.catches(context, opt: CatchFilterOptions(hour: 15));
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.catches(context, opt: CatchFilterOptions(hour: 5));
    expect(catches.length, 2);
  });

  testWidgets("Filtering by month", (tester) async {
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      timestamp: Int64(dateTime(2020, 3, 1, 5).millisecondsSinceEpoch),
    ));
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      timestamp: Int64(dateTime(2020, 5, 1, 10).millisecondsSinceEpoch),
    ));
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      timestamp: Int64(dateTime(2020, 3, 1, 8).millisecondsSinceEpoch),
    ));
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      timestamp: Int64(dateTime(2020, 8, 1, 5).millisecondsSinceEpoch),
    ));

    var context = await buildContext(tester, appManager: appManager);

    // No filter.
    var catches = catchManager.catches(context);
    expect(catches.length, 4);

    // No catches.
    catches = catchManager.catches(context, opt: CatchFilterOptions(month: 12));
    expect(catches.length, 0);

    // Some catches.
    catches = catchManager.catches(context, opt: CatchFilterOptions(month: 3));
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

    var baitAttachment0 = BaitAttachment(baitId: baitId0);
    var baitAttachment1 = BaitAttachment(baitId: baitId1);

    var fishingSpotId0 = randomId();
    var fishingSpotId1 = randomId();

    await catchManager.addOrUpdate(Catch()
      ..id = catchId0
      ..timestamp = Int64(5000)
      ..speciesId = speciesId0
      ..baits.add(baitAttachment0)
      ..fishingSpotId = fishingSpotId0);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(10000)
      ..speciesId = speciesId1
      ..baits.add(baitAttachment1)
      ..fishingSpotId = fishingSpotId1);
    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(20000)
      ..speciesId = speciesId1
      ..baits.add(baitAttachment0)
      ..fishingSpotId = fishingSpotId1);

    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        catchIds: {catchId0},
        speciesIds: {speciesId0},
        baits: {baitAttachment0},
        fishingSpotIds: {fishingSpotId0},
      ),
    );
    expect(catches.length, 1);

    catches = catchManager.catches(context);
    expect(catches.length, 3);

    catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        catchIds: {catchId0},
        speciesIds: {randomId()},
        baits: {baitAttachment0},
      ),
    );
    expect(catches.isEmpty, true);
  });

  testWidgets("Catches sorted newest to oldest", (tester) async {
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      timestamp: Int64(10000),
    ));

    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      timestamp: Int64(15000),
    ));

    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      timestamp: Int64(12500),
    ));

    var context = await buildContext(tester);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        order: CatchFilterOptions_Order.newest_to_oldest,
      ),
    );
    expect(catches.length, 3);
    expect(catches[0].timestamp, Int64(15000));
    expect(catches[1].timestamp, Int64(12500));
    expect(catches[2].timestamp, Int64(10000));

    // Defaults to newest_to_oldest.
    catches = catchManager.catches(context);
    expect(catches.length, 3);
    expect(catches[0].timestamp, Int64(15000));
    expect(catches[1].timestamp, Int64(12500));
    expect(catches[2].timestamp, Int64(10000));
  });

  testWidgets("Catches sorted longest to shortest", (tester) async {
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      length: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.centimeters,
          value: 45,
        ),
      ),
    ));

    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      length: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.centimeters,
          value: 75,
        ),
      ),
    ));

    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      length: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.centimeters,
          value: 60,
        ),
      ),
    ));

    var context = await buildContext(tester);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        order: CatchFilterOptions_Order.longest_to_shortest,
      ),
    );
    expect(catches.length, 3);
    expect(catches[0].length.mainValue.value, 75);
    expect(catches[1].length.mainValue.value, 60);
    expect(catches[2].length.mainValue.value, 45);
  });

  testWidgets("Catches sorted heaviest to lightest", (tester) async {
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      weight: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.kilograms,
          value: 45,
        ),
      ),
    ));

    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      weight: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.kilograms,
          value: 75,
        ),
      ),
    ));

    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      weight: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.kilograms,
          value: 60,
        ),
      ),
    ));

    var context = await buildContext(tester);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        order: CatchFilterOptions_Order.heaviest_to_lightest,
      ),
    );
    expect(catches.length, 3);
    expect(catches[0].weight.mainValue.value, 75);
    expect(catches[1].weight.mainValue.value, 60);
    expect(catches[2].weight.mainValue.value, 45);
  });

  testWidgets("Catches creates default filter options", (tester) async {
    // The fact that an assertion error is not thrown means a valid default
    // CatchFilterOptions was created.
    var catches = catchManager
        .catches(await buildContext(tester, appManager: appManager));
    expect(catches, isNotNull);
  });

  testWidgets("Catches doesn't override input fishing spots", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.fishingSpotManager.uuidMap()).thenReturn({});

    var fishingSpotId0 = randomId();
    var bodyOfWaterId0 = randomId();

    await catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..fishingSpotId = fishingSpotId0);

    // With strictly allFishingSpots input below, the number of catches in the
    // result should be 1
    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        bodyOfWaterIds: {bodyOfWaterId0},
        allFishingSpots: {
          fishingSpotId0.uuid: FishingSpot(
            id: fishingSpotId0,
            bodyOfWaterId: bodyOfWaterId0,
            name: "Test",
          ),
        },
      ),
    );
    expect(catches.length, 1);
  });

  testWidgets("Catches doesn't override input catches", (tester) async {
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    var catchId0 = randomId();
    var catchId1 = randomId();
    var catchId2 = randomId();

    await catchManager.addOrUpdate(Catch(id: catchId0));
    await catchManager.addOrUpdate(Catch(id: catchId1));
    await catchManager.addOrUpdate(Catch(id: catchId2));

    // With strictly allCatches input below, the number of catches in the
    // result should be 2.
    var context = await buildContext(tester, appManager: appManager);
    var catches = catchManager.catches(
      context,
      opt: CatchFilterOptions(
        allCatches: {
          catchId1.uuid: Catch(id: catchId1),
          catchId2.uuid: Catch(id: catchId2),
        },
      ),
    );
    expect(catches.length, 2);
  });

  test("catchesForGpsTrail with null bounds", () {
    expect(catchManager.catchesForGpsTrail(GpsTrail()), isEmpty);
  });

  test("catchesForGpsTrail with fishing spots that don't exist", () async {
    var mockFishingSpotManager = MockFishingSpotManager();
    when(mockFishingSpotManager.entity(any)).thenReturn(null);
    when(appManager.app.fishingSpotManager).thenReturn(mockFishingSpotManager);

    await catchManager
        .addOrUpdate(Catch(id: randomId(), fishingSpotId: randomId()));
    await catchManager
        .addOrUpdate(Catch(id: randomId(), fishingSpotId: randomId()));
    await catchManager
        .addOrUpdate(Catch(id: randomId(), fishingSpotId: randomId()));

    var gpsTrail = GpsTrail(
      points: [
        GpsTrailPoint(lat: 1, lng: 2, heading: 1),
        GpsTrailPoint(lat: 1, lng: 2, heading: 1),
      ],
    );

    expect(catchManager.catchesForGpsTrail(gpsTrail), isEmpty);
    verify(mockFishingSpotManager.entity(any)).called(3);
  });

  test("catchesForGpsTrail with catches outside of time range", () async {
    var mockFishingSpotManager = MockFishingSpotManager();
    when(mockFishingSpotManager.entity(any)).thenReturn(FishingSpot(
      lat: 1.5,
      lng: 1.5,
    ));

    when(appManager.app.fishingSpotManager).thenReturn(mockFishingSpotManager);

    // All catches are within the correct map bounds, but only 1 is within the
    // time range.
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      fishingSpotId: randomId(),
      timestamp: Int64(12),
    ));
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      fishingSpotId: randomId(),
      timestamp: Int64(3),
    ));
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      fishingSpotId: randomId(),
      timestamp: Int64(8),
    ));

    var gpsTrail = GpsTrail(
      startTimestamp: Int64(5),
      endTimestamp: Int64(10),
      points: [
        GpsTrailPoint(lat: 1, lng: 1, heading: 1),
        GpsTrailPoint(lat: 2, lng: 2, heading: 1),
      ],
    );

    expect(catchManager.catchesForGpsTrail(gpsTrail).length, 1);
  });

  test("catchesForGpsTrail with catches outside of bounds", () async {
    var fishingSpotId0 = randomId();

    var mockFishingSpotManager = MockFishingSpotManager();
    when(mockFishingSpotManager.entity(any)).thenAnswer((invocation) {
      var id = invocation.positionalArguments.first as Id;
      if (id == fishingSpotId0) {
        return FishingSpot(
          lat: 1.5,
          lng: 1.5,
        );
      } else {
        return FishingSpot(
          lat: 4.5,
          lng: 4.5,
        );
      }
    });

    when(appManager.app.fishingSpotManager).thenReturn(mockFishingSpotManager);

    // All catches are within the correct time range, but only 1 is within the
    // map bounds.
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      fishingSpotId: randomId(),
      timestamp: Int64(7),
    ));
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      fishingSpotId: randomId(),
      timestamp: Int64(6),
    ));
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      fishingSpotId: fishingSpotId0,
      timestamp: Int64(8),
    ));

    var gpsTrail = GpsTrail(
      startTimestamp: Int64(5),
      endTimestamp: Int64(10),
      points: [
        GpsTrailPoint(lat: 1, lng: 1, heading: 1),
        GpsTrailPoint(lat: 2, lng: 2, heading: 1),
      ],
    );

    expect(catchManager.catchesForGpsTrail(gpsTrail).length, 1);
  });

  test("catchesForGpsTrail for in progress trail", () async {
    var mockFishingSpotManager = MockFishingSpotManager();
    when(mockFishingSpotManager.entity(any)).thenReturn(FishingSpot(
      lat: 1.5,
      lng: 1.5,
    ));

    when(appManager.app.fishingSpotManager).thenReturn(mockFishingSpotManager);
    when(appManager.timeManager.currentTimestamp).thenReturn(15);

    // All catches are within the correct map bounds, but only 2 are within the
    // time range.
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      fishingSpotId: randomId(),
      timestamp: Int64(12),
    ));
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      fishingSpotId: randomId(),
      timestamp: Int64(3),
    ));
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      fishingSpotId: randomId(),
      timestamp: Int64(8),
    ));

    var gpsTrail = GpsTrail(
      startTimestamp: Int64(5),
      points: [
        GpsTrailPoint(lat: 1, lng: 1, heading: 1),
        GpsTrailPoint(lat: 2, lng: 2, heading: 1),
      ],
    );

    expect(catchManager.catchesForGpsTrail(gpsTrail).length, 2);
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

  testWidgets("deleteMessage no trip", (tester) async {
    when(speciesManager.entity(any)).thenReturn(Species(id: randomId()));
    when(speciesManager.displayName(any, any)).thenReturn("Rainbow Trout");

    when(appManager.tripManager.isCatchIdInTrip(any)).thenReturn(false);

    var context = await buildContext(tester, appManager: appManager);
    var cat = Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 9, 25).millisecondsSinceEpoch);

    expect(
      catchManager.deleteMessage(context, cat),
      "Are you sure you want to delete catch Rainbow Trout (Sep 25, 2020 at 12:00 AM)? This cannot be undone.",
    );
  });

  testWidgets("deleteMessage with trip", (tester) async {
    when(speciesManager.entity(any)).thenReturn(Species(id: randomId()));
    when(speciesManager.displayName(any, any)).thenReturn("Rainbow Trout");

    when(appManager.tripManager.isCatchIdInTrip(any)).thenReturn(true);

    var context = await buildContext(tester, appManager: appManager);
    var cat = Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 9, 25).millisecondsSinceEpoch);

    expect(
      catchManager.deleteMessage(context, cat),
      "Rainbow Trout (Sep 25, 2020 at 12:00 AM) is associated with a trip; Are you sure you want to delete it? This cannot be undone.",
    );
  });

  testWidgets("displayName without species", (tester) async {
    when(speciesManager.entity(any)).thenReturn(null);
    var context = await buildContext(tester, appManager: appManager);

    var displayName = catchManager.displayName(
      context,
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 10, 26, 15, 30).millisecondsSinceEpoch),
      ),
    );

    expect(displayName, "Oct 26, 2020 at 3:30 PM");
  });

  testWidgets("displayName with species", (tester) async {
    when(speciesManager.entity(any)).thenReturn(Species(id: randomId()));
    when(speciesManager.displayName(any, any)).thenReturn("Rainbow Trout");
    var context = await buildContext(tester, appManager: appManager);

    var displayName = catchManager.displayName(
      context,
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 10, 26, 15, 30).millisecondsSinceEpoch),
      ),
    );

    expect(displayName, "Rainbow Trout (Oct 26, 2020 at 3:30 PM)");
  });

  test("totalQuantity returns correct result", () async {
    var id0 = randomId();
    var id1 = randomId();
    var id2 = randomId();
    var id3 = randomId();
    var id4 = randomId();
    await catchManager.addOrUpdate(Catch(
      id: id0,
      quantity: 5,
    ));
    await catchManager.addOrUpdate(Catch(
      id: id1,
    ));
    await catchManager.addOrUpdate(Catch(
      id: id2,
      quantity: 15,
    ));
    await catchManager.addOrUpdate(Catch(
      id: id3,
      quantity: 10,
    ));
    await catchManager.addOrUpdate(Catch(
      id: id4,
    ));

    expect(catchManager.totalQuantity([id0, id1, id2, id3, id4]), 32);
    expect(catchManager.totalQuantity([id1, id4]), 2);
    expect(catchManager.totalQuantity([id0, id2]), 20);
  });
}
