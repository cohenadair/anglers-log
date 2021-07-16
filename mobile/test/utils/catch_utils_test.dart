import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/catch_utils.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  testWidgets("allCatchFieldsSorted", (tester) async {
    var fields = allCatchFieldsSorted(
        await buildContext(tester), StubbedAppManager().timeManager);
    expect(fields[0].id, catchFieldIdAngler());
    expect(fields[1].id, catchFieldIdAtmosphere());
    expect(fields[2].id, catchFieldIdBait());
    expect(fields[3].id, catchFieldIdCatchAndRelease());
    expect(fields[4].id, catchFieldIdTimestamp());
    expect(fields[5].id, catchFieldIdFavorite());
    expect(fields[6].id, catchFieldIdMethods());
    expect(fields[7].id, catchFieldIdFishingSpot());
    expect(fields[8].id, catchFieldIdLength());
    expect(fields[9].id, catchFieldIdNotes());
    expect(fields[10].id, catchFieldIdImages());
    expect(fields[11].id, catchFieldIdQuantity());
    expect(fields[12].id, catchFieldIdSeason());
    expect(fields[13].id, catchFieldIdSpecies());
    expect(fields[14].id, catchFieldIdPeriod());
    expect(fields[15].id, catchFieldIdWaterClarity());
    expect(fields[16].id, catchFieldIdWaterDepth());
    expect(fields[17].id, catchFieldIdWaterTemperature());
    expect(fields[18].id, catchFieldIdWeight());
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
    cat = Catch(timestamp: Int64(DateTime(2021, 1, 15).millisecondsSinceEpoch));
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

    // Without atmosphere.
    var cat = Catch();
    expect(catchFilterMatchesAtmosphere(context, "", cat), isFalse);

    // With atmosphere.
    cat = Catch(
      atmosphere: Atmosphere(
        temperature: Measurement(
          unit: Unit.fahrenheit,
          value: 58,
        ),
        skyConditions: [SkyCondition.cloudy],
        windSpeed: Measurement(
          unit: Unit.kilometers_per_hour,
          value: 6.5,
        ),
        windDirection: Direction.north,
        pressure: Measurement(
          unit: Unit.pounds_per_square_inch,
          value: 1000,
        ),
        humidity: Measurement(
          unit: Unit.percent,
          value: 50,
        ),
        visibility: Measurement(
          unit: Unit.miles,
          value: 10,
        ),
        moonPhase: MoonPhase.full,
        sunriseMillis: Int64(10000),
        sunsetMillis: Int64(15000),
      ),
    );
    expect(catchFilterMatchesAtmosphere(context, "58", cat), isTrue);
    expect(catchFilterMatchesAtmosphere(context, "6.5", cat), isTrue);
    expect(catchFilterMatchesAtmosphere(context, "1000", cat), isTrue);
    expect(catchFilterMatchesAtmosphere(context, "50", cat), isTrue);
    expect(catchFilterMatchesAtmosphere(context, "10", cat), isTrue);
    expect(catchFilterMatchesAtmosphere(context, "full", cat), isTrue);
    expect(catchFilterMatchesAtmosphere(context, "sunrise", cat), isTrue);
    expect(catchFilterMatchesAtmosphere(context, "sunset", cat), isTrue);
    expect(catchFilterMatchesAtmosphere(context, "500", cat), isFalse);
    expect(catchFilterMatchesAtmosphere(context, "37", cat), isFalse);
    expect(catchFilterMatchesAtmosphere(context, "nothing", cat), isFalse);
  });
}
