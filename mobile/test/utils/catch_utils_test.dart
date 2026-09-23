import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  void stubAllCatchFieldDependencies(StubbedManagers managers) {
    when(
      managers.userPreferenceManager.waterDepthSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.waterTemperatureSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.catchLengthSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.catchWeightSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());
  }

  Future<String?> subtitle2(WidgetTester tester, Catch cat, Id fieldId) async {
    return CatchListItemModel(
      await buildContext(tester),
      cat,
      fieldId,
    ).subtitle2;
  }

  testWidgets("allCatchFieldsSorted", (tester) async {
    var managers = await StubbedManagers.create();
    stubAllCatchFieldDependencies(managers);

    var fields = allCatchFieldsSorted(await buildContext(tester));
    expect(fields[0].id, catchFieldIdAngler);
    expect(fields[1].id, catchFieldIdAtmosphere);
    expect(fields[2].id, catchFieldIdBait);
    expect(fields[3].id, catchFieldIdCatchAndRelease);
    expect(fields[4].id, catchFieldIdTimestamp);
    expect(fields[5].id, catchFieldIdFavorite);
    expect(fields[6].id, catchFieldIdMethods);
    expect(fields[7].id, catchFieldIdFishingSpot);
    expect(fields[8].id, catchFieldIdGear);
    expect(fields[9].id, catchFieldIdLength);
    expect(fields[10].id, catchFieldIdNotes);
    expect(fields[11].id, catchFieldIdImages);
    expect(fields[12].id, catchFieldIdQuantity);
    expect(fields[13].id, catchFieldIdSeason);
    expect(fields[14].id, catchFieldIdSpecies);
    expect(fields[15].id, catchFieldIdTide);
    expect(fields[16].id, catchFieldIdTimeZone);
    expect(fields[17].id, catchFieldIdPeriod);
    expect(fields[18].id, catchFieldIdWaterClarity);
    expect(fields[19].id, catchFieldIdWaterDepth);
    expect(fields[20].id, catchFieldIdWaterTemperature);
    expect(fields[21].id, catchFieldIdWeight);
  });

  testWidgets("catchFilterMatchesPeriod", (tester) async {
    var context = await buildContext(tester);

    // Without period.
    var cat = Catch();
    expect(catchFilterMatchesPeriod(context, "", cat), isFalse);

    // With period.
    cat = Catch(period: Period.afternoon);
    expect(catchFilterMatchesPeriod(context, "AFternOOn", cat), isTrue);
    expect(catchFilterMatchesPeriod(context, " afternoon", cat), isTrue);
    expect(catchFilterMatchesPeriod(context, "noon", cat), isTrue);
  });

  testWidgets("catchFilterMatchesSeason", (tester) async {
    var context = await buildContext(tester);

    // Without season.
    var cat = Catch();
    expect(catchFilterMatchesSeason(context, "", cat), isFalse);

    // With season.
    cat = Catch(season: Season.autumn);
    expect(catchFilterMatchesSeason(context, "AUTumn", cat), isTrue);
    expect(catchFilterMatchesSeason(context, " autumn", cat), isTrue);
    expect(catchFilterMatchesSeason(context, "aut", cat), isTrue);
  });

  testWidgets("catchFilterMatchesFavorite", (tester) async {
    var context = await buildContext(tester);

    // Without favorite.
    var cat = Catch();
    expect(catchFilterMatchesFavorite(context, "", cat), isFalse);

    // With favorite false.
    cat = Catch(isFavorite: false);
    expect(catchFilterMatchesFavorite(context, "favorite", cat), isFalse);

    // With favorite true.
    cat = Catch(isFavorite: true);
    expect(catchFilterMatchesFavorite(context, "favORite", cat), isTrue);
    expect(catchFilterMatchesFavorite(context, " favourite", cat), isTrue);
    expect(catchFilterMatchesFavorite(context, "fav", cat), isTrue);
  });

  testWidgets("catchFilterMatchesCatchAndRelease", (tester) async {
    var context = await buildContext(tester);

    // Without catch and release.
    var cat = Catch();
    expect(catchFilterMatchesCatchAndRelease(context, "", cat), isFalse);

    // With catch and release false.
    cat = Catch(wasCatchAndRelease: false);
    expect(catchFilterMatchesCatchAndRelease(context, "keep", cat), isFalse);

    // With catch and release true.
    cat = Catch(wasCatchAndRelease: true);
    expect(catchFilterMatchesCatchAndRelease(context, "ReleaSED", cat), isTrue);
    expect(catchFilterMatchesCatchAndRelease(context, " release", cat), isTrue);
    expect(catchFilterMatchesCatchAndRelease(context, "kept", cat), isTrue);
  });

  testWidgets("catchFilterMatchesTimestamp", (tester) async {
    var context = await buildContext(tester);

    // Without timestamp.
    var cat = Catch();
    expect(catchFilterMatchesTimestamp(context, "", cat), isFalse);

    // With timestamp.
    cat = Catch(timestamp: Int64(dateTime(2021, 1, 15).millisecondsSinceEpoch));
    expect(catchFilterMatchesTimestamp(context, "JanuAry", cat), isTrue);
    expect(catchFilterMatchesTimestamp(context, " january", cat), isTrue);
    expect(catchFilterMatchesTimestamp(context, "15", cat), isTrue);
  });

  testWidgets("catchFilterMatchesWaterDepth", (tester) async {
    var context = await buildContext(tester);

    // Without water depth.
    var cat = Catch();
    expect(catchFilterMatchesWaterDepth(context, "", cat), isFalse);

    // With metric water depth.
    cat = Catch(
      waterDepth: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(unit: Unit.meters, value: 30),
      ),
    );
    expect(catchFilterMatchesWaterDepth(context, "Depth", cat), isTrue);
    expect(catchFilterMatchesWaterDepth(context, " meters", cat), isTrue);
    expect(catchFilterMatchesWaterDepth(context, "m", cat), isTrue);
    expect(catchFilterMatchesWaterDepth(context, "30", cat), isTrue);
    expect(catchFilterMatchesWaterDepth(context, "feet", cat), isFalse);

    // With imperial water depth.
    cat = Catch(
      waterDepth: MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(unit: Unit.feet, value: 30),
      ),
    );
    expect(catchFilterMatchesWaterDepth(context, "Depth", cat), isTrue);
    expect(catchFilterMatchesWaterDepth(context, " feet", cat), isTrue);
    expect(catchFilterMatchesWaterDepth(context, "ft", cat), isTrue);
    expect(catchFilterMatchesWaterDepth(context, "30", cat), isTrue);
    expect(catchFilterMatchesWaterDepth(context, "meters", cat), isFalse);
  });

  testWidgets("catchFilterMatchesWaterTemperature", (tester) async {
    var context = await buildContext(tester);

    // Without water temperature.
    var cat = Catch();
    expect(catchFilterMatchesWaterTemperature(context, "", cat), isFalse);

    // With metric water temperature.
    cat = Catch(
      waterTemperature: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(unit: Unit.celsius, value: 30),
      ),
    );
    expect(catchFilterMatchesWaterTemperature(context, "temP", cat), isTrue);
    expect(catchFilterMatchesWaterTemperature(context, " temp", cat), isTrue);
    expect(catchFilterMatchesWaterTemperature(context, "C", cat), isTrue);
    expect(catchFilterMatchesWaterTemperature(context, "30", cat), isTrue);
    expect(catchFilterMatchesWaterTemperature(context, "F", cat), isFalse);

    // With imperial water temperature.
    cat = Catch(
      waterTemperature: MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(unit: Unit.fahrenheit, value: 30),
      ),
    );
    expect(catchFilterMatchesWaterTemperature(context, "temP", cat), isTrue);
    expect(catchFilterMatchesWaterTemperature(context, " temp", cat), isTrue);
    expect(catchFilterMatchesWaterTemperature(context, "F", cat), isTrue);
    expect(catchFilterMatchesWaterTemperature(context, "30", cat), isTrue);
    expect(catchFilterMatchesWaterTemperature(context, "C", cat), isFalse);
  });

  testWidgets("catchFilterMatchesLength", (tester) async {
    var context = await buildContext(tester);

    // Without length.
    var cat = Catch();
    expect(catchFilterMatchesLength(context, "", cat), isFalse);

    // With metric length.
    cat = Catch(
      length: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(unit: Unit.centimeters, value: 30),
      ),
    );
    expect(catchFilterMatchesLength(context, "cm", cat), isTrue);
    expect(catchFilterMatchesLength(context, " CENTI", cat), isTrue);
    expect(catchFilterMatchesLength(context, "30", cat), isTrue);
    expect(catchFilterMatchesLength(context, "in", cat), isFalse);

    // With imperial length.
    cat = Catch(
      length: MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(unit: Unit.inches, value: 30),
      ),
    );
    expect(catchFilterMatchesLength(context, "in", cat), isTrue);
    expect(catchFilterMatchesLength(context, " INCH", cat), isTrue);
    expect(catchFilterMatchesLength(context, "30", cat), isTrue);
    expect(catchFilterMatchesLength(context, "cm", cat), isFalse);
  });

  testWidgets("catchFilterMatchesWeight", (tester) async {
    var context = await buildContext(tester);

    // Without weight.
    var cat = Catch();
    expect(catchFilterMatchesWeight(context, "", cat), isFalse);

    // With metric weight.
    cat = Catch(
      weight: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(unit: Unit.kilograms, value: 30),
      ),
    );
    expect(catchFilterMatchesWeight(context, "kg", cat), isTrue);
    expect(catchFilterMatchesWeight(context, " KIlo", cat), isTrue);
    expect(catchFilterMatchesWeight(context, "30", cat), isTrue);
    expect(catchFilterMatchesWeight(context, "lbs", cat), isFalse);

    // With imperial weight.
    cat = Catch(
      weight: MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(unit: Unit.pounds, value: 30),
        fractionValue: Measurement(unit: Unit.ounces, value: 6),
      ),
    );
    expect(catchFilterMatchesWeight(context, "lbs", cat), isTrue);
    expect(catchFilterMatchesWeight(context, " POUNd", cat), isTrue);
    expect(catchFilterMatchesWeight(context, "30", cat), isTrue);
    expect(catchFilterMatchesWeight(context, "6", cat), isTrue);
    expect(catchFilterMatchesWeight(context, "kg", cat), isFalse);
  });

  testWidgets("catchFilterMatchesQuantity", (tester) async {
    var context = await buildContext(tester);

    // Without quantity.
    var cat = Catch();
    expect(catchFilterMatchesQuantity(context, "", cat), isFalse);

    // With quantity.
    cat = Catch(quantity: 10);
    expect(catchFilterMatchesQuantity(context, "10", cat), isTrue);
    expect(catchFilterMatchesQuantity(context, " 10", cat), isTrue);
    expect(catchFilterMatchesQuantity(context, "0", cat), isTrue);
    expect(catchFilterMatchesQuantity(context, "11", cat), isFalse);
  });

  testWidgets("catchFilterMatchesNotes", (tester) async {
    var context = await buildContext(tester);

    // Without notes.
    var cat = Catch();
    expect(catchFilterMatchesNotes(context, "", cat), isFalse);

    // With notes.
    cat = Catch(notes: "Some test notes.");
    expect(catchFilterMatchesNotes(context, "some", cat), isTrue);
    expect(catchFilterMatchesNotes(context, "notes. ", cat), isTrue);
    expect(catchFilterMatchesNotes(context, "test", cat), isTrue);
    expect(catchFilterMatchesNotes(context, "error", cat), isFalse);
  });

  testWidgets("catchFilterMatchesAtmosphere", (tester) async {
    var context = await buildContext(tester);
    var cat = Catch(
      atmosphere: Atmosphere(skyConditions: [SkyCondition.clear]),
    );
    expect(catchFilterMatchesAtmosphere(context, "", cat), isFalse);
    expect(catchFilterMatchesAtmosphere(context, "Clear", cat), isTrue);
  });

  testWidgets("catchFilterMatchesTide", (tester) async {
    var context = await buildContext(tester);

    // Without tide.
    var cat = Catch();
    expect(catchFilterMatchesTide(context, "", cat), isFalse);

    // With tide.
    cat = Catch(
      tide: Tide(
        type: TideType.high,
        // Thursday, July 22, 2021 11:56:43 AM GMT
        firstLowHeight: Tide_Height(timestamp: Int64(1626955003000)),
        // Thursday, July 22, 2021 5:56:43 PM GMT
        firstHighHeight: Tide_Height(timestamp: Int64(1626976603000)),
      ),
    );

    expect(catchFilterMatchesTide(context, "high", cat), isTrue);
    expect(catchFilterMatchesTide(context, "7:56", cat), isTrue);
    expect(catchFilterMatchesTide(context, "PM", cat), isTrue);
    expect(catchFilterMatchesTide(context, "tide", cat), isTrue);
    expect(catchFilterMatchesTide(context, "22", cat), isFalse);
    expect(catchFilterMatchesTide(context, "out", cat), isFalse);
  });

  testWidgets("formatNumberOfCatches singular", (tester) async {
    var context = await buildContext(tester);
    expect(formatNumberOfCatches(context, 1), "1 Catch");
  });

  testWidgets("formatNumberOfCatches plural", (tester) async {
    var context = await buildContext(tester);
    expect(formatNumberOfCatches(context, 5), "5 Catches");
  });

  testWidgets("Fishing spot as second subtitle", (tester) async {
    var managers = await StubbedManagers.create();
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(
      managers.fishingSpotManager.entity(any),
    ).thenReturn(FishingSpot(name: "Spot 1"));
    when(
      managers.fishingSpotManager.displayName(
        any,
        any,
        useLatLngFallback: anyNamed("useLatLngFallback"),
        includeBodyOfWater: anyNamed("includeBodyOfWater"),
      ),
    ).thenReturn("Fishing Spot Display Name");

    expect(
      CatchListItemModel(
        await buildContext(tester),
        Catch(fishingSpotId: randomId()),
      ).subtitle2,
      "Fishing Spot Display Name",
    );
  });

  testWidgets("Bait as second subtitle", (tester) async {
    var managers = await StubbedManagers.create();
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.fishingSpotManager.entity(any)).thenReturn(null);
    when(
      managers.baitManager.attachmentDisplayValue(any, any),
    ).thenReturn("Bait");

    expect(
      CatchListItemModel(
        await buildContext(tester),
        Catch(baits: [BaitAttachment(baitId: randomId())]),
      ).subtitle2,
      "Bait",
    );
  });

  testWidgets("No second subtitle", (tester) async {
    var managers = await StubbedManagers.create();
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.fishingSpotManager.entity(any)).thenReturn(null);
    when(managers.baitManager.attachmentDisplayValue(any, any)).thenReturn("");

    expect(
      CatchListItemModel(
        await buildContext(tester),
        Catch(baits: [BaitAttachment(baitId: randomId())]),
      ).subtitle2,
      isNull,
    );
  });

  testWidgets("Null image name", (tester) async {
    var managers = await StubbedManagers.create();
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.fishingSpotManager.entity(any)).thenReturn(null);
    when(managers.baitManager.formatNameWithCategory(any)).thenReturn(null);

    expect(
      CatchListItemModel(
        await buildContext(tester),
        Catch(imageNames: []),
      ).imageName,
      isNull,
    );
  });

  testWidgets("Non-null image name", (tester) async {
    var managers = await StubbedManagers.create();
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.fishingSpotManager.entity(any)).thenReturn(null);
    when(managers.baitManager.formatNameWithCategory(any)).thenReturn(null);

    expect(
      CatchListItemModel(
        await buildContext(tester),
        Catch(imageNames: ["1.png"]),
      ).imageName,
      "1.png",
    );
  });

  testWidgets("Valid species", (tester) async {
    var managers = await StubbedManagers.create();
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.fishingSpotManager.entity(any)).thenReturn(null);
    when(managers.baitManager.formatNameWithCategory(any)).thenReturn(null);
    when(
      managers.speciesManager.entity(any),
    ).thenReturn(Species(name: "Trout"));

    expect(
      CatchListItemModel(
        await buildContext(tester),
        Catch(speciesId: randomId()),
      ).title,
      "Trout",
    );
  });

  testWidgets("Unknown species", (tester) async {
    var managers = await StubbedManagers.create();
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.fishingSpotManager.entity(any)).thenReturn(null);
    when(managers.baitManager.formatNameWithCategory(any)).thenReturn(null);
    when(managers.speciesManager.entity(any)).thenReturn(null);

    expect(
      CatchListItemModel(
        await buildContext(tester),
        Catch(speciesId: randomId()),
      ).title,
      "Unknown Species",
    );
  });

  testWidgets("Time zone subtitle", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(
        tester,
        Catch(timeZone: "America/New_York"),
        catchFieldIdTimeZone,
      ),
      "America/New York",
    );
  });

  testWidgets("Time zone subtitle not set", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(tester, Catch(), catchFieldIdTimeZone),
      "Time Zone: -",
    );
  });

  testWidgets("catchFieldDisplayValue time zone with unknown name", (
    tester,
  ) async {
    await StubbedManagers.create();
    expect(
      catchFieldDisplayValue(
        await buildContext(tester),
        Catch(timeZone: "Mars/Olympus_Mons"),
        catchFieldIdTimeZone,
      ),
      "Mars/Olympus Mons",
    );
  });

  testWidgets("Period subtitle", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(
        tester,
        Catch(period: Period.evening),
        catchFieldIdPeriod,
      ),
      "Evening",
    );
  });

  testWidgets("Period subtitle not set", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(tester, Catch(), catchFieldIdPeriod),
      "Time of Day: -",
    );
  });

  testWidgets("Season subtitle", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(tester, Catch(season: Season.winter), catchFieldIdSeason),
      "Winter",
    );
  });

  testWidgets("Season subtitle not set", (tester) async {
    await StubbedManagers.create();
    expect(await subtitle2(tester, Catch(), catchFieldIdSeason), "Season: -");
  });

  testWidgets("Bait subtitle", (tester) async {
    var managers = await StubbedManagers.create();
    when(
      managers.baitManager.attachmentsDisplayValues(any, any),
    ).thenReturn(["Stone Fly", "Bugger"]);

    expect(
      await subtitle2(tester, Catch(), catchFieldIdBait),
      "Stone Fly, Bugger",
    );
  });

  testWidgets("Bait subtitle not set", (tester) async {
    var managers = await StubbedManagers.create();
    when(
      managers.baitManager.attachmentsDisplayValues(any, any),
    ).thenReturn([]);
    expect(await subtitle2(tester, Catch(), catchFieldIdBait), "Bait: -");
  });

  testWidgets("Gear subtitle", (tester) async {
    var managers = await StubbedManagers.create();
    when(
      managers.gearManager.displayNamesFromIds(any, any),
    ).thenReturn(["Gear A", "Gear B"]);

    expect(
      await subtitle2(tester, Catch(), catchFieldIdGear),
      "Gear A, Gear B",
    );
  });

  testWidgets("Gear subtitle not set", (tester) async {
    var managers = await StubbedManagers.create();
    when(managers.gearManager.displayNamesFromIds(any, any)).thenReturn([]);
    expect(await subtitle2(tester, Catch(), catchFieldIdGear), "Gear: -");
  });

  testWidgets("Fishing spot subtitle falls back on bait", (tester) async {
    var managers = await StubbedManagers.create();
    when(managers.fishingSpotManager.entity(any)).thenReturn(null);
    when(
      managers.baitManager.attachmentDisplayValue(any, any),
    ).thenReturn("Stone Fly");

    expect(
      await subtitle2(
        tester,
        Catch(baits: [BaitAttachment(baitId: randomId())]),
        catchFieldIdFishingSpot,
      ),
      "Stone Fly",
    );
  });

  testWidgets("Angler subtitle", (tester) async {
    var managers = await StubbedManagers.create();
    when(
      managers.anglerManager.displayNameFromId(any, any),
    ).thenReturn("Cohen");

    expect(await subtitle2(tester, Catch(), catchFieldIdAngler), "Cohen");
  });

  testWidgets("Angler subtitle not set", (tester) async {
    var managers = await StubbedManagers.create();
    when(managers.anglerManager.displayNameFromId(any, any)).thenReturn(null);

    expect(await subtitle2(tester, Catch(), catchFieldIdAngler), "Angler: -");
  });

  testWidgets("Catch and release subtitle", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(
        tester,
        Catch(wasCatchAndRelease: true),
        catchFieldIdCatchAndRelease,
      ),
      "Catch and Release: Yes",
    );
  });

  testWidgets("Catch and release subtitle not set", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(tester, Catch(), catchFieldIdCatchAndRelease),
      "Catch and Release: -",
    );
  });

  testWidgets("Methods subtitle", (tester) async {
    var managers = await StubbedManagers.create();
    when(
      managers.methodManager.displayNamesFromIds(any, any),
    ).thenReturn(["Shore", "Cast"]);

    expect(
      await subtitle2(tester, Catch(), catchFieldIdMethods),
      "Shore, Cast",
    );
  });

  testWidgets("Methods subtitle not set", (tester) async {
    var managers = await StubbedManagers.create();
    when(managers.methodManager.displayNamesFromIds(any, any)).thenReturn([]);
    expect(
      await subtitle2(tester, Catch(), catchFieldIdMethods),
      "Fishing Methods: -",
    );
  });

  testWidgets("Atmosphere subtitle with temperature and sky conditions", (
    tester,
  ) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(
        tester,
        Catch(
          atmosphere: Atmosphere(
            temperature: MultiMeasurement(
              system: MeasurementSystem.metric,
              mainValue: Measurement(unit: Unit.celsius, value: 15),
            ),
            skyConditions: [SkyCondition.clear],
          ),
        ),
        catchFieldIdAtmosphere,
      ),
      "15\u00B0C, Clear",
    );
  });

  testWidgets("Atmosphere subtitle with temperature only", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(
        tester,
        Catch(
          atmosphere: Atmosphere(
            temperature: MultiMeasurement(
              system: MeasurementSystem.metric,
              mainValue: Measurement(unit: Unit.celsius, value: 15),
            ),
          ),
        ),
        catchFieldIdAtmosphere,
      ),
      "15\u00B0C",
    );
  });

  testWidgets("Atmosphere subtitle with sky conditions only", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(
        tester,
        Catch(atmosphere: Atmosphere(skyConditions: [SkyCondition.clear])),
        catchFieldIdAtmosphere,
      ),
      "Clear",
    );
  });

  testWidgets("Atmosphere subtitle without temperature or sky conditions", (
    tester,
  ) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(
        tester,
        Catch(
          atmosphere: Atmosphere(
            windSpeed: MultiMeasurement(
              system: MeasurementSystem.metric,
              mainValue: Measurement(unit: Unit.kilometers_per_hour, value: 5),
            ),
          ),
        ),
        catchFieldIdAtmosphere,
      ),
      "Atmosphere and Weather: -",
    );
  });

  testWidgets("Atmosphere subtitle not set", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(tester, Catch(), catchFieldIdAtmosphere),
      "Atmosphere and Weather: -",
    );
  });

  testWidgets("Tide subtitle", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(
        tester,
        Catch(tide: Tide(type: TideType.high)),
        catchFieldIdTide,
      ),
      "High",
    );
  });

  testWidgets("Tide subtitle not set", (tester) async {
    await StubbedManagers.create();
    expect(await subtitle2(tester, Catch(), catchFieldIdTide), "Tide: -");
  });

  testWidgets("Water clarity subtitle", (tester) async {
    var managers = await StubbedManagers.create();
    when(
      managers.waterClarityManager.displayNameFromId(any, any),
    ).thenReturn("Clear");

    expect(
      await subtitle2(tester, Catch(), catchFieldIdWaterClarity),
      "Clarity: Clear",
    );
  });

  testWidgets("Water clarity subtitle not set", (tester) async {
    var managers = await StubbedManagers.create();
    when(
      managers.waterClarityManager.displayNameFromId(any, any),
    ).thenReturn(null);
    expect(
      await subtitle2(tester, Catch(), catchFieldIdWaterClarity),
      "Clarity: -",
    );
  });

  testWidgets("Water depth subtitle", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(
        tester,
        Catch(
          waterDepth: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(unit: Unit.meters, value: 5),
          ),
        ),
        catchFieldIdWaterDepth,
      ),
      "Depth: 5 m",
    );
  });

  testWidgets("Water depth subtitle not set", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(tester, Catch(), catchFieldIdWaterDepth),
      "Depth: -",
    );
  });

  testWidgets("Water temperature subtitle", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(
        tester,
        Catch(
          waterTemperature: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(unit: Unit.celsius, value: 12),
          ),
        ),
        catchFieldIdWaterTemperature,
      ),
      "Water Temperature: 12\u00B0C",
    );
  });

  testWidgets("Water temperature subtitle not set", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(tester, Catch(), catchFieldIdWaterTemperature),
      "Water Temperature: -",
    );
  });

  testWidgets("Length subtitle", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(
        tester,
        Catch(
          length: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(unit: Unit.centimeters, value: 10),
          ),
        ),
        catchFieldIdLength,
      ),
      "10 cm",
    );
  });

  testWidgets("Length subtitle not set", (tester) async {
    await StubbedManagers.create();
    expect(await subtitle2(tester, Catch(), catchFieldIdLength), "Length: -");
  });

  testWidgets("Weight subtitle", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(
        tester,
        Catch(
          weight: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(unit: Unit.kilograms, value: 3),
          ),
        ),
        catchFieldIdWeight,
      ),
      "3 kg",
    );
  });

  testWidgets("Weight subtitle not set", (tester) async {
    await StubbedManagers.create();
    expect(await subtitle2(tester, Catch(), catchFieldIdWeight), "Weight: -");
  });

  testWidgets("Quantity subtitle", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(tester, Catch(quantity: 4), catchFieldIdQuantity),
      "Quantity: 4",
    );
  });

  testWidgets("Quantity subtitle not set", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(tester, Catch(), catchFieldIdQuantity),
      "Quantity: -",
    );
  });

  testWidgets("Notes subtitle", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(tester, Catch(notes: "Good fight"), catchFieldIdNotes),
      "Good fight",
    );
  });

  testWidgets("Notes subtitle not set", (tester) async {
    await StubbedManagers.create();
    expect(await subtitle2(tester, Catch(), catchFieldIdNotes), "Notes: -");
  });

  testWidgets("Unsupported subtitle field shows no subtitle", (tester) async {
    await StubbedManagers.create();
    expect(
      await subtitle2(tester, Catch(isFavorite: true), catchFieldIdFavorite),
      isNull,
    );
  });

  testWidgets("catchListItemSubtitleFields excludes fields already shown", (
    tester,
  ) async {
    var managers = await StubbedManagers.create();
    stubAllCatchFieldDependencies(managers);

    var ids = catchListItemSubtitleFields(
      await buildContext(tester),
    ).map((e) => e.id);
    expect(ids, isNot(contains(catchFieldIdTimestamp)));
    expect(ids, isNot(contains(catchFieldIdSpecies)));
    expect(ids, isNot(contains(catchFieldIdImages)));
    expect(ids, isNot(contains(catchFieldIdFavorite)));
  });

  testWidgets("catchListItemSubtitleFields are sorted alphabetically", (
    tester,
  ) async {
    var managers = await StubbedManagers.create();
    stubAllCatchFieldDependencies(managers);

    var context = await buildContext(tester);
    var names = catchListItemSubtitleFields(
      context,
    ).map((e) => e.name!(context)).toList();
    expect(names, List.of(names)..sort());
    expect(names.first, "Angler");
    expect(names.last, "Weight");
  });

  testWidgets("catchFieldDisplayValue species", (tester) async {
    var managers = await StubbedManagers.create();
    when(
      managers.speciesManager.displayNameFromId(any, any),
    ).thenReturn("Steelhead");
    expect(
      catchFieldDisplayValue(
        await buildContext(tester),
        Catch(),
        catchFieldIdSpecies,
      ),
      "Steelhead",
    );
  });

  testWidgets("catchFieldDisplayValue favorite", (tester) async {
    await StubbedManagers.create();
    expect(
      catchFieldDisplayValue(
        await buildContext(tester),
        Catch(isFavorite: true),
        catchFieldIdFavorite,
      ),
      "Yes",
    );
  });

  testWidgets("catchFieldDisplayValue favorite not set", (tester) async {
    await StubbedManagers.create();
    expect(
      catchFieldDisplayValue(
        await buildContext(tester),
        Catch(),
        catchFieldIdFavorite,
      ),
      isNull,
    );
  });

  testWidgets("catchFieldDisplayValue unsupported field", (tester) async {
    await StubbedManagers.create();
    expect(
      catchFieldDisplayValue(
        await buildContext(tester),
        Catch(imageNames: ["image.jpg"]),
        catchFieldIdImages,
      ),
      isNull,
    );
  });

  test("catchQuantity", () {
    expect(catchQuantity(Catch()), 1);
    expect(catchQuantity(Catch(quantity: 5)), 5);
  });
}
