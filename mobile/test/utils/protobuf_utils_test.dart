import 'package:collection/collection.dart' show IterableExtension;
import 'package:fixnum/fixnum.dart';
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
      expect(
        items.firstWhereOrNull((e) => e.value == Period.period_all),
        isNull,
      );
      expect(
        items.firstWhereOrNull((e) => e.value == Period.period_none),
        isNull,
      );
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

    test("isValid", () {
      expect(Ids.isValid(Id(uuid: "")), isFalse);
      expect(Ids.isValid(randomId()), isTrue);
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
      var id = parseId(const Uuid().v1());
      expect(id, isNotNull);
      expect(id.uuid, isNotEmpty);
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
    testWidgets("displayValue for imperial_decimal", (tester) async {
      var context = await buildContext(tester);
      var measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_decimal,
        mainValue: Measurement(
          unit: Unit.inches,
          value: 10.5,
        ),
      );
      expect(measurement.displayValue(context), "10.5 in");
    });

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

    testWidgets("displayValue excludes fraction", (tester) async {
      var context = await buildContext(tester);

      var measurement = MultiMeasurement(
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

      expect(
        measurement.displayValue(context, includeFraction: false),
        "10 lbs",
      );
    });

    testWidgets("displayValue ifZero is returned", (tester) async {
      var context = await buildContext(tester);

      var measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          value: 0,
        ),
      );

      expect(
        measurement.displayValue(
          context,
          ifZero: "Zero",
        ),
        "Zero",
      );
    });

    testWidgets("displayValue resultFormat is returned", (tester) async {
      var context = await buildContext(tester);

      var measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
      );

      expect(
        measurement.displayValue(
          context,
          includeFraction: false,
          resultFormat: "Value: %s",
        ),
        "Value: 10 lbs",
      );
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

    test("compareTo returns -1", () {
      var measurement1 = MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 8,
        ),
      );
      var measurement2 = MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
      );
      expect(measurement1.compareTo(measurement2), -1);
    });

    testWidgets("compareTo returns 0", (tester) async {
      var measurement1 = MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
      );
      var measurement2 = MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
      );
      expect(measurement1.compareTo(measurement2), 0);
    });

    testWidgets("compareTo returns 1", (tester) async {
      var measurement1 = MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 12,
        ),
      );
      var measurement2 = MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
      );
      expect(measurement1.compareTo(measurement2), 1);
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

    test("Compare without main values", () {
      var smaller = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 5,
        ),
      );
      var larger = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 8,
        ),
      );
      expect(smaller < larger, isTrue);
    });

    test("average returns null when input is empty", () {
      expect(
          MultiMeasurements.average(
              [], MeasurementSystem.metric, Unit.kilograms),
          isNull);
    });

    test("average returns correct result", () {
      expect(
        MultiMeasurements.average(
          [
            MultiMeasurement(
              system: MeasurementSystem.metric,
              mainValue: Measurement(
                unit: Unit.kilograms,
                value: 10,
              ),
            ),
            MultiMeasurement(
              system: MeasurementSystem.metric,
              mainValue: Measurement(
                unit: Unit.kilograms,
                value: 30,
              ),
            ),
            MultiMeasurement(
              system: MeasurementSystem.metric,
              mainValue: Measurement(
                unit: Unit.kilograms,
                value: 20,
              ),
            ),
          ],
          MeasurementSystem.imperial_whole,
          Unit.pounds,
        ),
        MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.pounds,
            value: 44.0,
          ),
          fractionValue: Measurement(
            unit: Unit.ounces,
            value: 1.0,
          ),
        ),
      );
    });

    test("max returns null when input is empty", () {
      expect(
          MultiMeasurements.max([], MeasurementSystem.metric, Unit.kilograms),
          isNull);
    });

    test("max returns correct result", () {
      expect(
        MultiMeasurements.max(
          [
            MultiMeasurement(
              system: MeasurementSystem.metric,
              mainValue: Measurement(
                unit: Unit.kilograms,
                value: 10,
              ),
            ),
            MultiMeasurement(
              system: MeasurementSystem.metric,
              mainValue: Measurement(
                unit: Unit.kilograms,
                value: 30,
              ),
            ),
            MultiMeasurement(
              system: MeasurementSystem.metric,
              mainValue: Measurement(
                unit: Unit.kilograms,
                value: 20,
              ),
            ),
          ],
          MeasurementSystem.metric,
          Unit.kilograms,
        ),
        MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilograms,
            value: 30,
          ),
        ),
      );
    });

    test("max returns correct value after conversion", () {
      expect(
        MultiMeasurements.max(
          [
            MultiMeasurement(
              system: MeasurementSystem.metric,
              mainValue: Measurement(
                unit: Unit.kilograms,
                value: 10,
              ),
            ),
            MultiMeasurement(
              system: MeasurementSystem.metric,
              mainValue: Measurement(
                unit: Unit.kilograms,
                value: 30,
              ),
            ),
            MultiMeasurement(
              system: MeasurementSystem.imperial_whole,
              mainValue: Measurement(
                unit: Unit.pounds,
                value: 200,
              ),
            ),
          ],
          MeasurementSystem.metric,
          Unit.kilograms,
        ),
        MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilograms,
            value: 90.7184,
          ),
        ),
      );
    });

    test("max when measurements have no main value", () {
      expect(
        MultiMeasurements.max(
          [
            MultiMeasurement(
              system: MeasurementSystem.imperial_whole,
              fractionValue: Measurement(
                unit: Unit.ounces,
                value: 10,
              ),
            ),
            MultiMeasurement(
              system: MeasurementSystem.metric,
              mainValue: Measurement(
                unit: Unit.kilograms,
                value: 0,
              ),
            ),
          ],
          MeasurementSystem.imperial_whole,
          Unit.pounds,
        ),
        MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.pounds,
            value: 0,
          ),
          fractionValue: Measurement(
            unit: Unit.ounces,
            value: 10,
          ),
        ),
      );
    });

    test("sum returns null when input is empty", () {
      expect(
          MultiMeasurements.sum([], MeasurementSystem.metric, Unit.kilograms),
          isNull);
    });

    test("sum returns correct result", () {
      expect(
        MultiMeasurements.sum(
          [
            MultiMeasurement(
              system: MeasurementSystem.metric,
              mainValue: Measurement(
                unit: Unit.kilograms,
                value: 10,
              ),
            ),
            MultiMeasurement(
              system: MeasurementSystem.metric,
              mainValue: Measurement(
                unit: Unit.kilograms,
                value: 30,
              ),
            ),
            MultiMeasurement(
              system: MeasurementSystem.metric,
              mainValue: Measurement(
                unit: Unit.kilograms,
                value: 20,
              ),
            ),
          ],
          MeasurementSystem.metric,
          Unit.kilograms,
        ),
        MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilograms,
            value: 60,
          ),
        ),
      );
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
      expect(
        filter.containsMeasurement(
            Measurement(value: 13), MeasurementSystem.metric),
        isFalse,
      );
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
    test("toMultiMeasurement imperial whole inches", () {
      expect(
        Unit.inches.toMultiMeasurement(50.5, MeasurementSystem.imperial_whole),
        MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.inches,
            value: 50,
          ),
          fractionValue: Measurement(
            value: 0.5,
          ),
        ),
      );
    });

    testWidgets("toMultiMeasurement for inches < 0", (tester) async {
      expect(
        Unit.inches
            .toMultiMeasurement(0.5, MeasurementSystem.imperial_whole)
            .displayValue(await buildContext(tester)),
        "0 \u00BD in",
      );
    });

    testWidgets("toMultiMeasurement for pounds < 0", (tester) async {
      expect(
        Unit.pounds
            .toMultiMeasurement(0.5, MeasurementSystem.imperial_whole)
            .displayValue(await buildContext(tester)),
        "0 lbs 8 oz",
      );
    });

    testWidgets("toMultiMeasurement for feet < 0", (tester) async {
      expect(
        Unit.feet
            .toMultiMeasurement(0.5, MeasurementSystem.imperial_whole)
            .displayValue(await buildContext(tester)),
        "0 ft 6 in",
      );
    });

    test("toMultiMeasurement imperial whole no fraction unit", () {
      expect(
        Unit.ounces.toMultiMeasurement(50.5, MeasurementSystem.imperial_whole),
        MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.ounces,
            value: 50,
          ),
        ),
      );
    });

    test("toMultiMeasurement imperial whole fraction ounces", () {
      expect(
        Unit.pounds.toMultiMeasurement(50.5, MeasurementSystem.imperial_whole),
        MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.pounds,
            value: 50,
          ),
          fractionValue: Measurement(
            unit: Unit.ounces,
            value: 8,
          ),
        ),
      );
    });

    test("toMultiMeasurement imperial whole fraction inches", () {
      expect(
        Unit.feet.toMultiMeasurement(50.5, MeasurementSystem.imperial_whole),
        MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.feet,
            value: 50,
          ),
          fractionValue: Measurement(
            unit: Unit.inches,
            value: 6,
          ),
        ),
      );
    });

    test("toMultiMeasurement non-imperial whole", () {
      expect(
        Unit.meters.toMultiMeasurement(50.5, MeasurementSystem.metric),
        MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.meters,
            value: 50.5,
          ),
        ),
      );
    });

    test("convertFrom with the same unit", () {
      expect(Unit.kilometers.convertFrom(Unit.kilometers, 10), 10);
    });

    test("convertFrom with a non-opposite unit", () {
      expect(Unit.kilometers.convertFrom(Unit.pounds, 10), 10);
    });

    test("convertFrom with unsupported unit", () {
      expect(Unit.meters.convertFrom(Unit.kilometers, 10), 10);
    });

    test("Fahrenheit to celsius", () {
      expect(Unit.celsius.convertFrom(Unit.fahrenheit, 32), 0);
    });

    test("Miles to kilometers", () {
      expect(Unit.kilometers.convertFrom(Unit.miles, 1), 1.609344);
    });

    test("Millibars to pounds per square inch", () {
      expect(
        Unit.pounds_per_square_inch.convertFrom(Unit.millibars, 1),
        0.0145038,
      );
    });

    test("Inches to centimeters", () {
      expect(Unit.centimeters.convertFrom(Unit.inches, 1), 2.54);
    });

    test("Centimeters to inches", () {
      expect(Unit.inches.convertFrom(Unit.centimeters, 2.54).round(), 1);
    });

    test("Pounds to kilograms", () {
      expect(Unit.kilograms.convertFrom(Unit.pounds, 1), 0.453592);
    });

    test("Kilograms to pounds", () {
      expect(Unit.pounds.convertFrom(Unit.kilograms, 0.453592).round(), 1);
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

  group("Tides", () {
    testWidgets("displayValue returns null if no properties are set",
        (tester) async {
      expect(Tide().displayValue(await buildContext(tester)), isNull);
    });

    testWidgets("displayValue has type and uses chip name", (tester) async {
      expect(
        Tide(
          type: TideType.high,
        ).displayValue(await buildContext(tester), useChipName: true),
        "High Tide",
      );
    });

    testWidgets("displayValue has type and does not use chip name",
        (tester) async {
      expect(
        Tide(
          type: TideType.high,
        ).displayValue(await buildContext(tester), useChipName: false),
        "High",
      );
    });

    testWidgets("displayValue with tide times and no type", (tester) async {
      expect(
        Tide(
          // Thursday, July 22, 2021 11:56:43 AM GMT
          lowTimestamp: Int64(1626955003000),
          // Thursday, July 22, 2021 5:56:43 PM GMT
          highTimestamp: Int64(1626976603000),
        ).displayValue(await buildContext(tester)),
        "L: 7:56 AM, H: 1:56 PM",
      );
    });

    testWidgets("displayValue type and low tide", (tester) async {
      expect(
        Tide(
          type: TideType.high,
          // Thursday, July 22, 2021 11:56:43 AM GMT
          lowTimestamp: Int64(1626955003000),
        ).displayValue(await buildContext(tester)),
        "High (L: 7:56 AM)",
      );
    });

    testWidgets("displayValue type and high tide", (tester) async {
      expect(
        Tide(
          type: TideType.high,
          // Thursday, July 22, 2021 11:56:43 AM GMT
          highTimestamp: Int64(1626955003000),
        ).displayValue(await buildContext(tester)),
        "High (H: 7:56 AM)",
      );
    });

    testWidgets("displayValue low tide only", (tester) async {
      expect(
        Tide(
          // Thursday, July 22, 2021 11:56:43 AM GMT
          lowTimestamp: Int64(1626955003000),
        ).displayValue(await buildContext(tester)),
        "L: 7:56 AM",
      );
    });

    testWidgets("displayValue high tide only", (tester) async {
      expect(
        Tide(
          // Thursday, July 22, 2021 11:56:43 AM GMT
          highTimestamp: Int64(1626955003000),
        ).displayValue(await buildContext(tester)),
        "H: 7:56 AM",
      );
    });

    testWidgets("displayValue all properties", (tester) async {
      expect(
        Tide(
          type: TideType.high,
          // Thursday, July 22, 2021 11:56:43 AM GMT
          lowTimestamp: Int64(1626955003000),
          // Thursday, July 22, 2021 5:56:43 PM GMT
          highTimestamp: Int64(1626976603000),
        ).displayValue(await buildContext(tester)),
        "High (L: 7:56 AM, H: 1:56 PM)",
      );
    });
  });

  group("BaitVariants", () {
    testWidgets("diveDepthDisplayValue with both min and max", (tester) async {
      expect(
        BaitVariant(
          minDiveDepth: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.meters,
              value: 5,
            ),
          ),
          maxDiveDepth: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.meters,
              value: 10,
            ),
          ),
        ).diveDepthDisplayValue(await buildContext(tester)),
        "5 m - 10 m",
      );
    });

    testWidgets("diveDepthDisplayValue with min only", (tester) async {
      expect(
        BaitVariant(
          minDiveDepth: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.meters,
              value: 5,
            ),
          ),
        ).diveDepthDisplayValue(await buildContext(tester)),
        "5 m",
      );
    });

    testWidgets("diveDepthDisplayValue with max only", (tester) async {
      expect(
        BaitVariant(
          maxDiveDepth: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.meters,
              value: 10,
            ),
          ),
        ).diveDepthDisplayValue(await buildContext(tester)),
        "10 m",
      );
    });

    testWidgets("diveDepthDisplayValue with neither min nor max",
        (tester) async {
      expect(
        BaitVariant().diveDepthDisplayValue(await buildContext(tester)),
        isNull,
      );
    });
  });

  group("Atmospheres", () {
    testWidgets("catchFilterMatchesAtmosphere", (tester) async {
      var context = await buildContext(tester);
      var atmosphere = Atmosphere(
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
        sunriseTimestamp: Int64(10000),
        sunsetTimestamp: Int64(15000),
      );
      expect(atmosphere.matchesFilter(context, "58"), isTrue);
      expect(atmosphere.matchesFilter(context, "6.5"), isTrue);
      expect(atmosphere.matchesFilter(context, "1000"), isTrue);
      expect(atmosphere.matchesFilter(context, "50"), isTrue);
      expect(atmosphere.matchesFilter(context, "10"), isTrue);
      expect(atmosphere.matchesFilter(context, "full"), isTrue);
      expect(atmosphere.matchesFilter(context, "sunrise"), isTrue);
      expect(atmosphere.matchesFilter(context, "sunset"), isTrue);
      expect(atmosphere.matchesFilter(context, "500"), isFalse);
      expect(atmosphere.matchesFilter(context, "37"), isFalse);
      expect(atmosphere.matchesFilter(context, "nothing"), isFalse);
    });
  });

  group("Trips", () {
    test("incCatchesPerEntity early exit if ID isn't valid", () {
      var catchesPerEntity = <Trip_CatchesPerEntity>[];
      Trips.incCatchesPerEntity(catchesPerEntity, Id(uuid: ""), Catch());
      expect(catchesPerEntity, isEmpty);
    });

    test("incCatchesPerEntity existing is null", () {
      var catchesPerEntity = <Trip_CatchesPerEntity>[];
      Trips.incCatchesPerEntity(catchesPerEntity, randomId(), Catch());
      expect(catchesPerEntity.length, 1);
      expect(catchesPerEntity.first.value, 1);
    });

    test("incCatchesPerEntity existing is not null", () {
      var id = randomId();
      var catchesPerEntity = <Trip_CatchesPerEntity>[
        Trip_CatchesPerEntity(
          entityId: id,
          value: 5,
        ),
      ];
      Trips.incCatchesPerEntity(catchesPerEntity, id, Catch());
      expect(catchesPerEntity.length, 1);
      expect(catchesPerEntity.first.value, 6);
    });

    test("incCatchesPerBait early exit if baits are empty", () {
      var catchesPerBait = <Trip_CatchesPerBait>[];
      Trips.incCatchesPerBait(catchesPerBait, Catch());
      expect(catchesPerBait, isEmpty);
    });

    test("incCatchesPerBait existing is null", () {
      var catchesPerBait = <Trip_CatchesPerBait>[];
      Trips.incCatchesPerBait(
        catchesPerBait,
        Catch(
          baits: [
            BaitAttachment(baitId: randomId()),
            BaitAttachment(baitId: randomId()),
          ],
        ),
      );
      expect(catchesPerBait.length, 2);
      expect(catchesPerBait.first.value, 1);
      expect(catchesPerBait.last.value, 1);
    });

    test("incCatchesPerBait existing is not null", () {
      var attachment1 = BaitAttachment(baitId: randomId());
      var attachment2 = BaitAttachment(baitId: randomId());
      var catchesPerBait = <Trip_CatchesPerBait>[
        Trip_CatchesPerBait(
          attachment: attachment1,
          value: 3,
        ),
        Trip_CatchesPerBait(
          attachment: attachment2,
          value: 5,
        ),
      ];
      Trips.incCatchesPerBait(
        catchesPerBait,
        Catch(
          baits: [attachment2, attachment1],
        ),
      );
      expect(catchesPerBait.length, 2);
      expect(catchesPerBait.first.value, 4);
      expect(catchesPerBait.last.value, 6);
    });
  });
}
