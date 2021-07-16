import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import '../mocks/mocks.mocks.dart';
import '../test_utils.dart';

void main() {
  group("_pickerItems", () {
    testWidgets("Values are excluded", (tester) async {
      var items = Periods.pickerItems(await buildContext(tester));
      expect(items.length, Period.values.length - 2);
      expect(items.contains(Period.period_all), isFalse);
      expect(items.contains(Period.period_none), isFalse);
    });

    testWidgets("Values are sorted", (tester) async {
      var items = SkyConditions.pickerItems(await buildContext(tester));
      expect(items.length, SkyCondition.values.length - 2);
      expect(items[0].value, SkyCondition.clear);
    });

    testWidgets("Values are not sorted", (tester) async {
      var items = Periods.pickerItems(await buildContext(tester));
      expect(items.length, Period.values.length - 2);
      expect(items[0].value, Period.dawn);
    });
  });

  group("Id", () {
    test("Invalid input", () {
      expect(() => parseId(""), throwsAssertionError);
      expect(() => parseId("zzz"), throwsFormatException);
      expect(() => parseId("b860cddd-dc47-48a2-8d02-c8112a2ed5eb"), isNotNull);
      expect(randomId(), isNotNull);
    });

    /// Tests that the [Id] object can be used as a key in a [Map]. No matter
    /// the structure of [Id], it needs to be equatable.
    test("Id used in Map", () {
      var uuid0 = randomId().uuid;
      var uuid1 = randomId().uuid;
      var uuid2 = randomId().uuid;

      var map = <Id, int>{
        Id()..uuid = uuid0: 5,
        Id()..uuid = uuid1: 10,
        Id()..uuid = uuid2: 15,
      };

      expect(map[Id()..uuid = String.fromCharCodes(uuid0.codeUnits)], 5);
      expect(map[Id()..uuid = String.fromCharCodes(uuid1.codeUnits)], 10);
      expect(map[Id()..uuid = String.fromCharCodes(uuid2.codeUnits)], 15);
      expect(map[randomId()], isNull);
    });
  });

  group("entityValuesCount", () {
    test("Empty entities", () {
      expect(entityValuesCount<Catch>([], randomId(), (_) => []), 0);
    });

    test("Empty getValues", () {
      expect(
        entityValuesCount<Catch>(
            [Catch()..id = randomId()], randomId(), (_) => []),
        0,
      );
    });

    test("0 count", () {
      var cat = Catch()..id = randomId();
      cat.customEntityValues
          .add(CustomEntityValue()..customEntityId = randomId());
      expect(
        entityValuesCount<Catch>(
            [cat], randomId(), (cat) => cat.customEntityValues),
        0,
      );
    });

    test("Greater than 0 count", () {
      var cat = Catch()..id = randomId();

      var customId1 = randomId();
      var customId2 = randomId();
      cat.customEntityValues
        ..add(CustomEntityValue()..customEntityId = customId1)
        ..add(CustomEntityValue()..customEntityId = customId2);

      expect(
        entityValuesCount<Catch>(
            [cat], randomId(), (cat) => cat.customEntityValues),
        0,
      );
      expect(
        entityValuesCount<Catch>(
            [cat], customId1, (cat) => cat.customEntityValues),
        1,
      );
      expect(
        entityValuesCount<Catch>(
            [cat], customId2, (cat) => cat.customEntityValues),
        1,
      );
    });
  });

  group("entityValuesMatchesFilter", () {
    var customEntityManager = MockCustomEntityManager();
    when(customEntityManager.matchesFilter(any, any)).thenReturn(false);

    test("Empty or null filter", () {
      expect(filterMatchesEntityValues([], "", customEntityManager), isTrue);
      expect(filterMatchesEntityValues([], null, customEntityManager), isTrue);
    });

    test("Empty values", () {
      expect(filterMatchesEntityValues([], "Filter", customEntityManager),
          isFalse);
    });

    test("Null values", () {
      expect(
        filterMatchesEntityValues(
            [CustomEntityValue()..value = ""], "Filter", customEntityManager),
        isFalse,
      );
    });

    test("Values value matches filter", () {
      expect(
        filterMatchesEntityValues(
            [CustomEntityValue()..value = "A filter value"],
            "Filter",
            customEntityManager),
        isTrue,
      );
    });
  });

  group("entityValuesFromMap", () {
    test("Input", () {
      expect(entityValuesFromMap({}), []);
      expect(entityValuesFromMap(null), []);
    });

    test("Parse values", () {
      var id1 = randomId();
      var id2 = randomId();
      var id3 = randomId();

      expect(
        entityValuesFromMap({
          randomId(): null,
          randomId(): "",
          id1: "Value 1",
          id2: "Value 2",
          id3: "Value 3",
        }),
        [
          CustomEntityValue()
            ..customEntityId = id1
            ..value = "Value 1",
          CustomEntityValue()
            ..customEntityId = id2
            ..value = "Value 2",
          CustomEntityValue()
            ..customEntityId = id3
            ..value = "Value 3",
        ],
      );
    });
  });

  group("valueForCustomEntityType", () {
    test("Number", () {
      expect(
        valueForCustomEntityType(
            CustomEntity_Type.number, CustomEntityValue()..value = "50"),
        "50",
      );
    });

    test("Text", () {
      expect(
        valueForCustomEntityType(
            CustomEntity_Type.text, CustomEntityValue()..value = "50"),
        "50",
      );
    });

    test("Bool without context", () {
      expect(
        valueForCustomEntityType(
            CustomEntity_Type.boolean, CustomEntityValue()..value = "1"),
        isTrue,
      );
    });

    testWidgets("Bool with context", (tester) async {
      expect(
        valueForCustomEntityType(CustomEntity_Type.boolean,
            CustomEntityValue()..value = "1", await buildContext(tester)),
        "Yes",
      );
      expect(
        valueForCustomEntityType(CustomEntity_Type.boolean,
            CustomEntityValue()..value = "0", await buildContext(tester)),
        "No",
      );
    });
  });

  group("Collections entity ID or object", () {
    test("Non-GeneratedMessage item calls List.indexOf", () {
      expect(indexOfEntityIdOrOther(["String", 12, 15.4], 12), 1);
      expect(containsEntityIdOrOther(["String", 12, 15.4], 12), isTrue);
    });

    test("Non-GeneratedMessage list items with GeneratedMessage item", () {
      expect(indexOfEntityIdOrOther(["String", 12, Catch()], Catch()), 2);
      expect(containsEntityIdOrOther(["String", 12, 15.4], Catch()), isFalse);
    });

    test("ID is found", () {
      var cat = Catch()..id = randomId();
      expect(indexOfEntityIdOrOther([cat, 12, Catch()], cat), 0);
      expect(containsEntityIdOrOther(["String", 12, cat], cat), isTrue);
    });
  });

  group("parseId", () {
    test("Input", () {
      expect(() => parseId(""), throwsAssertionError);
    });

    test("Bad UUID string", () {
      expect(() => parseId("XYZ"), throwsFormatException);
    });

    test("Good UUID string", () {
      var id = parseId(Uuid().v1());
      expect(id, isNotNull);
      expect(id.uuid, isNotEmpty);
    });
  });

  group("FishingSpots", () {
    testWidgets("Spot with name", (tester) async {
      expect(
        (FishingSpot()
              ..id = randomId()
              ..name = "Test Name"
              ..lat = 0.0
              ..lng = 0.0)
            .displayName(await buildContext(tester)),
        "Test Name",
      );
    });

    testWidgets("Spot without name", (tester) async {
      expect(
        (FishingSpot()
              ..id = randomId()
              ..lat = 0.0
              ..lng = 0.0)
            .displayName(await buildContext(tester)),
        "Lat: 0.000000, Lng: 0.000000",
      );
    });
  });

  group("Measurements", () {
    testWidgets("displayValue without units", (tester) async {
      var context = await buildContext(tester);
      var measurement = Measurement(value: 10);
      expect(measurement.displayValue(context), "10");
    });

    testWidgets("displayValue with units", (tester) async {
      var context = await buildContext(tester);

      // With space between value and unit.
      var measurement = Measurement(
        unit: Unit.pounds,
        value: 10,
      );
      expect(measurement.displayValue(context), "10 lbs");

      // Without space between value and unit.
      measurement = Measurement(
        unit: Unit.fahrenheit,
        value: 10,
      );
      expect(measurement.displayValue(context), "10\u00B0F");
    });

    test("stringValue", () {
      // Whole number.
      var measurement = Measurement(
        unit: Unit.pounds,
        value: 10,
      );
      expect(measurement.stringValue, "10");

      // Floating number.
      measurement = Measurement(
        unit: Unit.pounds,
        value: 10.556842132,
      );
      expect(measurement.stringValue, "10.6");

      // Whole floating number.
      measurement = Measurement(
        unit: Unit.pounds,
        value: 10.0,
      );
      expect(measurement.stringValue, "10");
    });

    test("toSystem", () {
      // No change in system.
      var measurement = Measurement(
        unit: Unit.pounds,
        value: 10,
      );
      expect(
          measurement, measurement.toSystem(MeasurementSystem.imperial_whole));

      // Change system.
      measurement = Measurement(
        unit: Unit.pounds,
        value: 10,
      ).toSystem(MeasurementSystem.metric);
      expect(measurement.unit, Unit.kilograms);
      expect(measurement.value, 10);
    });

    test("Comparing different units returns false", () {
      var pounds = Measurement(
        unit: Unit.pounds,
        value: 10,
      );
      var kilograms = Measurement(
        unit: Unit.kilograms,
        value: 5,
      );

      expect(kilograms < pounds, isFalse);
      expect(kilograms <= pounds, isFalse);
      expect(pounds > kilograms, isFalse);
      expect(pounds >= kilograms, isFalse);
    });

    test("Comparing same units returns correct result", () {
      var pounds = Measurement(
        unit: Unit.kilograms,
        value: 10,
      );
      var kilograms = Measurement(
        unit: Unit.kilograms,
        value: 5,
      );

      expect(kilograms < pounds, isTrue);
      expect(kilograms <= pounds, isTrue);
      expect(pounds > kilograms, isTrue);
      expect(pounds >= kilograms, isTrue);
    });
  });

  group("MultiMeasurements", () {
    testWidgets("displayValue for inches", (tester) async {
      var context = await buildContext(tester);

      // No fraction.
      var measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.inches,
          value: 10,
        ),
      );
      expect(measurement.displayValue(context), "10 in");

      // Fraction.
      measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.inches,
          value: 10,
        ),
        fractionValue: Measurement(
          value: 0.5,
        ),
      );
      expect(measurement.displayValue(context), "10 \u00BD in");

      // Fraction without unit.
      measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.inches,
          value: 10,
        ),
        fractionValue: Measurement(
          value: 0.5,
        ),
      );
      expect(measurement.displayValue(context), "10 \u00BD in");
    });

    testWidgets("displayValue general", (tester) async {
      var context = await buildContext(tester);

      // No fraction.
      var measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 10,
        ),
      );
      expect(measurement.displayValue(context), "10 ft");

      // Fraction.
      measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 8,
        ),
      );
      expect(measurement.displayValue(context), "10 lbs 8 oz");
    });

    test("from with null system", () {
      var measurement = MultiMeasurements.from(
        Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
        null,
      );
      expect(measurement.system, MeasurementSystem.imperial_whole);
      expect(measurement.mainValue.unit, Unit.pounds);
      expect(measurement.mainValue.value, 10);
    });

    test("from with non-null system", () {
      var measurement = MultiMeasurements.from(
        Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
        MeasurementSystem.metric,
      );
      expect(measurement.system, MeasurementSystem.metric);
      expect(measurement.mainValue.unit, Unit.pounds);
      expect(measurement.mainValue.value, 10);
    });

    test("toSystem", () {
      // No change in system.
      var measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 5,
        ),
      );
      expect(
          measurement, measurement.toSystem(MeasurementSystem.imperial_whole));

      // Change system.
      measurement = measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.inches,
          value: 5,
        ),
      ).toSystem(MeasurementSystem.metric);
      expect(measurement.system, MeasurementSystem.metric);
      expect(measurement.mainValue.unit, Unit.meters);
      expect(measurement.mainValue.value, 10);
      expect(measurement.fractionValue.unit, Unit.centimeters);
      expect(measurement.fractionValue.value, 5);
    });

    testWidgets("filterString with no values", (tester) async {
      var measurement = MultiMeasurement();
      expect(measurement.filterString(await buildContext(tester)), isEmpty);
    });

    testWidgets("filterString with main value only", (tester) async {
      var measurement = MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
      );
      var context = await buildContext(tester);
      expect(measurement.filterString(context), isNotEmpty);
      expect(measurement.filterString(context).contains("lbs"), isTrue);
    });

    testWidgets("filterString with fraction value only", (tester) async {
      var measurement = MultiMeasurement(
        fractionValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
      );
      var context = await buildContext(tester);
      expect(measurement.filterString(context), isNotEmpty);
      expect(measurement.filterString(context).contains("lbs"), isTrue);
    });

    testWidgets("filterString with main and fraction values", (tester) async {
      var measurement = MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.kilometers,
          value: 15,
        ),
      );
      var context = await buildContext(tester);
      expect(measurement.filterString(context), isNotEmpty);
      expect(measurement.filterString(context).contains("lbs"), isTrue);
      expect(measurement.filterString(context).contains("km"), isTrue);
    });

    test("Comparing equals", () {
      var measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 10,
        ),
      );
      expect(measurement < measurement, isFalse);
      expect(measurement <= measurement, isTrue);
      expect(measurement > measurement, isFalse);
      expect(measurement >= measurement, isTrue);
    });

    test("Comparing different systems always returns false", () {
      var metric = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 10,
        ),
      );
      var imperial = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 10,
        ),
      );
      expect(metric < imperial, isFalse);
      expect(metric <= imperial, isFalse);
      expect(metric > imperial, isFalse);
      expect(metric >= imperial, isFalse);
    });

    test("Imperial whole and imperial decimal are still comparable", () {
      // Equals.
      var whole = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 8,
        ),
      );
      var decimal = MultiMeasurement(
        system: MeasurementSystem.imperial_decimal,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10.5,
        ),
      );
      expect(whole < decimal, isFalse);
      expect(whole <= decimal, isTrue);
      expect(whole > decimal, isFalse);
      expect(whole >= decimal, isTrue);

      // Left hand side is smaller.
      whole = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.inches,
          value: 5,
        ),
      );
      decimal = MultiMeasurement(
        system: MeasurementSystem.imperial_decimal,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 10.5,
        ),
      );
      expect(whole < decimal, isTrue);
      expect(whole <= decimal, isTrue);
      expect(whole > decimal, isFalse);
      expect(whole >= decimal, isFalse);

      // Right hand side is smaller.
      whole = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 8,
        ),
      );
      decimal = MultiMeasurement(
        system: MeasurementSystem.imperial_decimal,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10.25,
        ),
      );
      expect(whole < decimal, isFalse);
      expect(whole <= decimal, isFalse);
      expect(whole > decimal, isTrue);
      expect(whole >= decimal, isTrue);
    });

    test("Comparing main values", () {
      var ten = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 10,
        ),
      );
      var fifteen = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 15,
        ),
      );
      expect(ten < fifteen, isTrue);
      expect(ten <= fifteen, isTrue);
      expect(ten > fifteen, isFalse);
      expect(ten >= fifteen, isFalse);
    });

    test("Comparing fraction values when mains are equal", () {
      var smaller = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 5,
        ),
      );
      var larger = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 8,
        ),
      );
      expect(smaller < larger, isTrue);
      expect(smaller <= larger, isTrue);
      expect(smaller > larger, isFalse);
      expect(smaller >= larger, isFalse);
    });
  });

  group("NumberFilters", () {
    test("isSet", () {
      // No boundary.
      var filter = NumberFilter();
      expect(filter.isSet, isFalse);

      // Neither from or to is set.
      filter = NumberFilter(
        boundary: NumberBoundary.greater_than,
      );
      expect(filter.isSet, isFalse);

      // Just from set.
      filter = NumberFilter(
        boundary: NumberBoundary.greater_than,
        from: MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        ),
      );
      expect(filter.isSet, isTrue);

      // Just to set.
      filter = NumberFilter(
        boundary: NumberBoundary.greater_than,
        to: MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        ),
      );
      expect(filter.isSet, isTrue);

      // Both set.
      filter = NumberFilter(
        boundary: NumberBoundary.greater_than,
        from: MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        ),
        to: MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        ),
      );
      expect(filter.isSet, isTrue);
    });

    testWidgets("Any displayValue", (tester) async {
      var filter = NumberFilter(
        boundary: NumberBoundary.number_boundary_any,
      );
      expect(filter.displayValue(await buildContext(tester)), "Any");
    });

    testWidgets("Signed displayValue", (tester) async {
      var filter = NumberFilter(
        boundary: NumberBoundary.greater_than,
        from: MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        ),
      );
      expect(filter.displayValue(await buildContext(tester)), "> 10");
    });

    testWidgets("Range displayValue", (tester) async {
      // Both from and to set.
      var filter = NumberFilter(
        boundary: NumberBoundary.range,
        from: MultiMeasurement(
          mainValue: Measurement(
            value: 5,
          ),
        ),
        to: MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        ),
      );
      expect(filter.displayValue(await buildContext(tester)), "5 - 10");

      // Only one set.
      filter = NumberFilter(
        boundary: NumberBoundary.range,
        from: MultiMeasurement(
          mainValue: Measurement(
            value: 5,
          ),
        ),
      );
      expect(filter.displayValue(await buildContext(tester)), "Any");
    });

    testWidgets("Invalid start value in displayValue", (tester) async {
      var filter = NumberFilter(
        boundary: NumberBoundary.greater_than,
      );
      expect(filter.displayValue(await buildContext(tester)), "Any");
    });

    test("Range containsMultiMeasurement", () {
      var filter = NumberFilter(
        boundary: NumberBoundary.range,
        from: MultiMeasurement(
          mainValue: Measurement(
            value: 5,
          ),
        ),
        to: MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        ),
      );
      expect(
        filter.containsMultiMeasurement(MultiMeasurement(
          mainValue: Measurement(
            value: 5,
          ),
        )),
        isTrue,
      );
      expect(
        filter.containsMultiMeasurement(MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        )),
        isTrue,
      );
      expect(
        filter.containsMultiMeasurement(MultiMeasurement(
          mainValue: Measurement(
            value: 8,
          ),
        )),
        isTrue,
      );
      expect(
        filter.containsMultiMeasurement(MultiMeasurement(
          mainValue: Measurement(
            value: 13,
          ),
        )),
        isFalse,
      );
    });

    test("containsMeasurement", () {
      var filter = NumberFilter(
        boundary: NumberBoundary.range,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.meters,
            value: 5,
          ),
        ),
        to: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.meters,
            value: 10,
          ),
        ),
      );
      expect(filter.containsMeasurement(Measurement(value: 13)), isFalse);
    });

    test("containsInt", () {
      var filter = NumberFilter(
        boundary: NumberBoundary.range,
        from: MultiMeasurement(mainValue: Measurement(value: 5)),
        to: MultiMeasurement(mainValue: Measurement(value: 10)),
      );
      expect(filter.containsInt(5), isTrue);
      expect(filter.containsInt(10), isTrue);
      expect(filter.containsInt(8), isTrue);
      expect(filter.containsInt(13), isFalse);
    });
  });

  group("DateRanges", () {
    assertStatsDateRange({
      required DateRange dateRange,
      required DateTime now,
      required DateTime expectedStart,
      DateTime? expectedEnd,
    }) {
      expect(dateRange.startDate(now), equals(expectedStart));
      expect(dateRange.endDate(now), equals(expectedEnd ?? now));
    }

    test("Today", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.today),
        now: DateTime(2019, 1, 15, 15, 30),
        expectedStart: DateTime(2019, 1, 15),
      );
    });

    test("Yesterday", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.yesterday),
        now: DateTime(2019, 1, 15, 15, 30),
        expectedStart: DateTime(2019, 1, 14),
        expectedEnd: DateTime(2019, 1, 15),
      );
    });

    test("This week - year overlap", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.thisWeek),
        now: DateTime(2019, 1, 3, 15, 30),
        expectedStart: DateTime(2018, 12, 31, 0, 0, 0),
      );
    });

    test("This week - within the same month", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.thisWeek),
        now: DateTime(2019, 2, 13, 15, 30),
        expectedStart: DateTime(2019, 2, 11, 0, 0, 0),
      );
    });

    test("This week - same day as week start", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.thisWeek),
        now: DateTime(2019, 2, 4, 15, 30),
        expectedStart: DateTime(2019, 2, 4, 0, 0, 0),
      );
    });

    test("This week - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.thisWeek),
        now: DateTime(2019, 3, 10, 15, 30),
        expectedStart: DateTime(2019, 3, 4, 0, 0, 0),
      );
    });

    test("This month - first day", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.thisMonth),
        now: DateTime(2019, 2, 1, 15, 30),
        expectedStart: DateTime(2019, 2, 1, 0, 0, 0),
      );
    });

    test("This month - last day", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.thisMonth),
        now: DateTime(2019, 3, 31, 15, 30),
        expectedStart: DateTime(2019, 3, 1, 0, 0, 0),
      );

      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.thisMonth),
        now: DateTime(2019, 2, 28, 15, 30),
        expectedStart: DateTime(2019, 2, 1, 0, 0, 0),
      );

      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.thisMonth),
        now: DateTime(2019, 4, 30, 15, 30),
        expectedStart: DateTime(2019, 4, 1, 0, 0, 0),
      );
    });

    test("This month - somewhere in the middle", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.thisMonth),
        now: DateTime(2019, 5, 17, 15, 30),
        expectedStart: DateTime(2019, 5, 1, 0, 0, 0),
      );
    });

    test("This month - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.thisMonth),
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 3, 1, 0, 0, 0),
      );
    });

    test("This year - first day", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.thisYear),
        now: DateTime(2019, 1, 1, 15, 30),
        expectedStart: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("This year - last day", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.thisYear),
        now: DateTime(2019, 12, 31, 15, 30),
        expectedStart: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("This year - somewhere in the middle", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.thisYear),
        now: DateTime(2019, 5, 17, 15, 30),
        expectedStart: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("This year - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.thisYear),
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("Last week - year overlap", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.lastWeek),
        now: DateTime(2019, 1, 3, 15, 30),
        expectedStart: DateTime(2018, 12, 24, 0, 0, 0),
        expectedEnd: DateTime(2018, 12, 31, 0, 0, 0),
      );
    });

    test("Last week - within the same month", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.lastWeek),
        now: DateTime(2019, 2, 13, 15, 30),
        expectedStart: DateTime(2019, 2, 4, 0, 0, 0),
        expectedEnd: DateTime(2019, 2, 11, 0, 0, 0),
      );
    });

    test("Last week - same day as week start", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.lastWeek),
        now: DateTime(2019, 2, 4, 15, 30),
        expectedStart: DateTime(2019, 1, 28, 0, 0, 0),
        expectedEnd: DateTime(2019, 2, 4, 0, 0, 0),
      );
    });

    test("Last week - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.lastWeek),
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 3, 3, 23, 0, 0),
        expectedEnd: DateTime(2019, 3, 11, 0, 0, 0),
      );
    });

    test("Last month - year overlap", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.lastMonth),
        now: DateTime(2019, 1, 3, 15, 30),
        expectedStart: DateTime(2018, 12, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("Last month - within same year", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.lastMonth),
        now: DateTime(2019, 2, 4, 15, 30),
        expectedStart: DateTime(2019, 1, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 2, 1, 0, 0, 0),
      );
    });

    test("Last month - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.lastMonth),
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 2, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 3, 1, 0, 0, 0),
      );
    });

    test("Last year - normal case", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.lastYear),
        now: DateTime(2019, 12, 26, 15, 30),
        expectedStart: DateTime(2018, 1, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("Last year - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.lastYear),
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2018, 1, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("Last 7 days - normal case", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.last7Days),
        now: DateTime(2019, 2, 20, 15, 30),
        expectedStart: DateTime(2019, 2, 13, 15, 30, 0),
      );
    });

    test("Last 7 days - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.last7Days),
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 3, 6, 14, 30, 0),
      );
    });

    test("Last 14 days - normal case", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.last14Days),
        now: DateTime(2019, 2, 20, 15, 30),
        expectedStart: DateTime(2019, 2, 6, 15, 30, 0),
      );
    });

    test("Last 14 days - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.last14Days),
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 2, 27, 14, 30, 0),
      );
    });

    test("Last 30 days - normal case", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.last30Days),
        now: DateTime(2019, 2, 20, 15, 30),
        expectedStart: DateTime(2019, 1, 21, 15, 30, 0),
      );
    });

    test("Last 30 days - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.last30Days),
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 2, 11, 14, 30, 0),
      );
    });

    test("Last 60 days - normal case", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.last60Days),
        now: DateTime(2019, 2, 20, 15, 30),
        expectedStart: DateTime(2018, 12, 22, 15, 30, 0),
      );
    });

    test("Last 60 days - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.last60Days),
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 1, 12, 14, 30, 0),
      );
    });

    test("Last 12 months - normal case", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.last12Months),
        now: DateTime(2019, 2, 20, 15, 30),
        expectedStart: DateTime(2018, 2, 20, 15, 30),
      );
    });

    test("Last 12 months - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DateRange(period: DateRange_Period.last12Months),
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2018, 3, 13, 15, 30),
      );
    });
  });

  group("Units", () {
    test("convertFrom with the same unit", () {
      expect(Unit.kilometers.convertFrom(Unit.kilometers, 10), 10);
    });

    test("convertFrom with a non-opposite unit", () {
      expect(Unit.kilometers.convertFrom(Unit.pounds, 10), 10);
    });

    test("convertFrom with unsupported unit", () {
      expect(Unit.meters.convertFrom(Unit.kilometers, 10), 10);
    });
  });

  group("Directions", () {
    test("fromDegrees north", () {
      expect(Directions.fromDegrees(0), Direction.north);
      expect(Directions.fromDegrees(360), Direction.north);
      expect(Directions.fromDegrees(10), Direction.north);
      expect(Directions.fromDegrees(350), Direction.north);
    });

    test("fromDegrees north east", () {
      expect(Directions.fromDegrees(45), Direction.north_east);
      expect(Directions.fromDegrees(35), Direction.north_east);
      expect(Directions.fromDegrees(55), Direction.north_east);
    });

    test("fromDegrees east", () {
      expect(Directions.fromDegrees(90), Direction.east);
      expect(Directions.fromDegrees(80), Direction.east);
      expect(Directions.fromDegrees(100), Direction.east);
    });

    test("fromDegrees south east", () {
      expect(Directions.fromDegrees(135), Direction.south_east);
      expect(Directions.fromDegrees(125), Direction.south_east);
      expect(Directions.fromDegrees(145), Direction.south_east);
    });

    test("fromDegrees south", () {
      expect(Directions.fromDegrees(180), Direction.south);
      expect(Directions.fromDegrees(170), Direction.south);
      expect(Directions.fromDegrees(190), Direction.south);
    });

    test("fromDegrees south west", () {
      expect(Directions.fromDegrees(225), Direction.south_west);
      expect(Directions.fromDegrees(215), Direction.south_west);
      expect(Directions.fromDegrees(235), Direction.south_west);
    });

    test("fromDegrees west", () {
      expect(Directions.fromDegrees(270), Direction.west);
      expect(Directions.fromDegrees(260), Direction.west);
      expect(Directions.fromDegrees(280), Direction.west);
    });

    test("fromDegrees north west", () {
      expect(Directions.fromDegrees(315), Direction.north_west);
      expect(Directions.fromDegrees(305), Direction.north_west);
      expect(Directions.fromDegrees(325), Direction.north_west);
    });
  });

  group("SkyConditions", () {
    test("fromTypes", () {
      expect(SkyConditions.fromTypes("type_31,type_33,type_6"), [
        SkyCondition.snow,
        SkyCondition.drizzle,
      ]);
    });
  });
}
