import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  testWidgets("allCatchFieldsSorted", (tester) async {
    var appManager = StubbedAppManager();

    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());

    var fields = allCatchFieldsSorted(
        await buildContext(tester, appManager: appManager));
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
      mainValue: Measurement(
        unit: Unit.meters,
        value: 30,
      ),
    ));
    expect(catchFilterMatchesWaterDepth(context, "Depth", cat), isTrue);
    expect(catchFilterMatchesWaterDepth(context, " meters", cat), isTrue);
    expect(catchFilterMatchesWaterDepth(context, "m", cat), isTrue);
    expect(catchFilterMatchesWaterDepth(context, "30", cat), isTrue);
    expect(catchFilterMatchesWaterDepth(context, "feet", cat), isFalse);

    // With imperial water depth.
    cat = Catch(
        waterDepth: MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.feet,
        value: 30,
      ),
    ));
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
      mainValue: Measurement(
        unit: Unit.celsius,
        value: 30,
      ),
    ));
    expect(catchFilterMatchesWaterTemperature(context, "temP", cat), isTrue);
    expect(catchFilterMatchesWaterTemperature(context, " temp", cat), isTrue);
    expect(catchFilterMatchesWaterTemperature(context, "C", cat), isTrue);
    expect(catchFilterMatchesWaterTemperature(context, "30", cat), isTrue);
    expect(catchFilterMatchesWaterTemperature(context, "F", cat), isFalse);

    // With imperial water temperature.
    cat = Catch(
        waterTemperature: MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.fahrenheit,
        value: 30,
      ),
    ));
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
      mainValue: Measurement(
        unit: Unit.centimeters,
        value: 30,
      ),
    ));
    expect(catchFilterMatchesLength(context, "cm", cat), isTrue);
    expect(catchFilterMatchesLength(context, " CENTI", cat), isTrue);
    expect(catchFilterMatchesLength(context, "30", cat), isTrue);
    expect(catchFilterMatchesLength(context, "in", cat), isFalse);

    // With imperial length.
    cat = Catch(
        length: MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.inches,
        value: 30,
      ),
    ));
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
      mainValue: Measurement(
        unit: Unit.kilograms,
        value: 30,
      ),
    ));
    expect(catchFilterMatchesWeight(context, "kg", cat), isTrue);
    expect(catchFilterMatchesWeight(context, " KIlo", cat), isTrue);
    expect(catchFilterMatchesWeight(context, "30", cat), isTrue);
    expect(catchFilterMatchesWeight(context, "lbs", cat), isFalse);

    // With imperial weight.
    cat = Catch(
        weight: MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.pounds,
        value: 30,
      ),
      fractionValue: Measurement(
        unit: Unit.ounces,
        value: 6,
      ),
    ));
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
    var cat =
        Catch(atmosphere: Atmosphere(skyConditions: [SkyCondition.clear]));
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
        firstLowTimestamp: Int64(1626955003000),
        // Thursday, July 22, 2021 5:56:43 PM GMT
        firstHighTimestamp: Int64(1626976603000),
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
    var appManager = StubbedAppManager();
    when(appManager.fishingSpotManager.entity(any)).thenReturn(FishingSpot(
      name: "Spot 1",
    ));
    when(appManager.fishingSpotManager.displayName(
      any,
      any,
      useLatLngFallback: anyNamed("useLatLngFallback"),
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
    )).thenReturn("Fishing Spot Display Name");

    expect(
      CatchListItemModel(
        await buildContext(tester, appManager: appManager),
        Catch(fishingSpotId: randomId()),
      ).subtitle2,
      "Fishing Spot Display Name",
    );
  });

  testWidgets("Bait as second subtitle", (tester) async {
    var appManager = StubbedAppManager();
    when(appManager.fishingSpotManager.entity(any)).thenReturn(null);
    when(appManager.baitManager.attachmentDisplayValue(any, any))
        .thenReturn("Bait");

    expect(
      CatchListItemModel(
        await buildContext(tester, appManager: appManager),
        Catch(baits: [BaitAttachment(baitId: randomId())]),
      ).subtitle2,
      "Bait",
    );
  });

  testWidgets("No second subtitle", (tester) async {
    var appManager = StubbedAppManager();
    when(appManager.fishingSpotManager.entity(any)).thenReturn(null);
    when(appManager.baitManager.attachmentDisplayValue(any, any))
        .thenReturn("");

    expect(
      CatchListItemModel(
        await buildContext(tester, appManager: appManager),
        Catch(baits: [BaitAttachment(baitId: randomId())]),
      ).subtitle2,
      isNull,
    );
  });

  testWidgets("Null image name", (tester) async {
    var appManager = StubbedAppManager();
    when(appManager.fishingSpotManager.entity(any)).thenReturn(null);
    when(appManager.baitManager.formatNameWithCategory(any)).thenReturn(null);

    expect(
      CatchListItemModel(
        await buildContext(tester, appManager: appManager),
        Catch(imageNames: []),
      ).imageName,
      isNull,
    );
  });

  testWidgets("Non-null image name", (tester) async {
    var appManager = StubbedAppManager();
    when(appManager.fishingSpotManager.entity(any)).thenReturn(null);
    when(appManager.baitManager.formatNameWithCategory(any)).thenReturn(null);

    expect(
      CatchListItemModel(
        await buildContext(tester, appManager: appManager),
        Catch(imageNames: ["1.png"]),
      ).imageName,
      "1.png",
    );
  });

  testWidgets("Valid species", (tester) async {
    var appManager = StubbedAppManager();
    when(appManager.fishingSpotManager.entity(any)).thenReturn(null);
    when(appManager.baitManager.formatNameWithCategory(any)).thenReturn(null);
    when(appManager.speciesManager.entity(any)).thenReturn(Species(
      name: "Trout",
    ));

    expect(
      CatchListItemModel(
        await buildContext(tester, appManager: appManager),
        Catch(speciesId: randomId()),
      ).title,
      "Trout",
    );
  });

  testWidgets("Unknown species", (tester) async {
    var appManager = StubbedAppManager();
    when(appManager.fishingSpotManager.entity(any)).thenReturn(null);
    when(appManager.baitManager.formatNameWithCategory(any)).thenReturn(null);
    when(appManager.speciesManager.entity(any)).thenReturn(null);

    expect(
      CatchListItemModel(
        await buildContext(tester, appManager: appManager),
        Catch(speciesId: randomId()),
      ).title,
      "Unknown Species",
    );
  });

  testWidgets("CatchListItemModelSubtitleType.length", (tester) async {
    var appManager = StubbedAppManager();
    when(appManager.fishingSpotManager.entity(any)).thenReturn(null);
    when(appManager.baitManager.formatNameWithCategory(any)).thenReturn(null);
    when(appManager.speciesManager.entity(any)).thenReturn(null);

    expect(
      CatchListItemModel(
        await buildContext(tester, appManager: appManager),
        Catch(
          length: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.centimeters,
              value: 10,
            ),
          ),
        ),
        CatchListItemModelSubtitleType.length,
      ).subtitle2,
      "Length: 10 cm",
    );
  });

  testWidgets("CatchListItemModelSubtitleType.weight", (tester) async {
    var appManager = StubbedAppManager();
    when(appManager.fishingSpotManager.entity(any)).thenReturn(null);
    when(appManager.baitManager.formatNameWithCategory(any)).thenReturn(null);
    when(appManager.speciesManager.entity(any)).thenReturn(null);

    expect(
      CatchListItemModel(
        await buildContext(tester, appManager: appManager),
        Catch(
          weight: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.kilograms,
              value: 3,
            ),
          ),
        ),
        CatchListItemModelSubtitleType.weight,
      ).subtitle2,
      "Weight: 3 kg",
    );
  });

  test("catchQuantity", () {
    expect(catchQuantity(Catch()), 1);
    expect(catchQuantity(Catch(quantity: 5)), 5);
  });
}
