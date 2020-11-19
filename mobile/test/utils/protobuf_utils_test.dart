import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  group("Id", () {
    test("Invalid input", () {
      expect(() => parseId(""), throwsAssertionError);
      expect(() => parseId(null), throwsAssertionError);
      expect(() => parseId("zzz"), throwsArgumentError);
      expect(() => parseId("b860cddd-dc47-48a2-8d02-c8112a2ed5eb"), isNotNull);
      expect(randomId(), isNotNull);
    });

    /// Tests that the [Id] object can be used as a key in a [Map]. No matter the
    /// structure of [Id], it needs to be equatable.
    test("Id used in Map", () {
      String uuid0 = randomId().uuid;
      String uuid1 = randomId().uuid;
      String uuid2 = randomId().uuid;

      Map<Id, int> map = {
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
    test("Input", () {
      expect(
        () => entityValuesCount<Catch>(
            [Catch()..id = randomId()], randomId(), null),
        throwsAssertionError,
      );
    });

    test("Empty entities", () {
      expect(entityValuesCount<Catch>([], randomId(), null), 0);
    });

    test("Null getValues", () {
      expect(
        entityValuesCount<Catch>(
            [Catch()..id = randomId()], randomId(), (_) => null),
        0,
      );
    });

    test("Empty getValues", () {
      expect(
        entityValuesCount<Catch>(
            [Catch()..id = randomId()], randomId(), (_) => []),
        0,
      );
    });

    test("0 count", () {
      Catch cat = Catch()..id = randomId();
      cat.customEntityValues
          .add(CustomEntityValue()..customEntityId = randomId());
      expect(
        entityValuesCount<Catch>(
            [cat], randomId(), (cat) => cat.customEntityValues),
        0,
      );
    });

    test("Greater than 0 count", () {
      Catch cat = Catch()..id = randomId();

      Id customId1 = randomId();
      Id customId2 = randomId();
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
    MockCustomEntityManager customEntityManager = MockCustomEntityManager();
    when(customEntityManager.matchesFilter(any, any)).thenReturn(false);

    test("Empty or null filter", () {
      expect(entityValuesMatchesFilter(null, null, null), isTrue);
      expect(entityValuesMatchesFilter([], "", null), isTrue);
      expect(entityValuesMatchesFilter(null, "", null), isTrue);
      expect(
        entityValuesMatchesFilter(
            [CustomEntityValue()], "", customEntityManager),
        isFalse,
      );
    });

    test("Empty values", () {
      expect(entityValuesMatchesFilter([], "Filter", null), isFalse);
    });

    test("Null values", () {
      expect(
        entityValuesMatchesFilter(
            [CustomEntityValue()..value = ""], "Filter", customEntityManager),
        isFalse,
      );
    });

    test("Values value matches filter", () {
      expect(
        entityValuesMatchesFilter(
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
      Id id1 = randomId();
      Id id2 = randomId();
      Id id3 = randomId();

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
            CustomEntity_Type.NUMBER, CustomEntityValue()..value = "50"),
        "50",
      );
    });

    test("Text", () {
      expect(
        valueForCustomEntityType(
            CustomEntity_Type.TEXT, CustomEntityValue()..value = "50"),
        "50",
      );
    });

    test("Bool without context", () {
      expect(
        valueForCustomEntityType(
            CustomEntity_Type.BOOL, CustomEntityValue()..value = "1"),
        isTrue,
      );
    });

    testWidgets("Bool with context", (WidgetTester tester) async {
      expect(
        valueForCustomEntityType(CustomEntity_Type.BOOL,
            CustomEntityValue()..value = "1", await buildContext(tester)),
        "Yes",
      );
      expect(
        valueForCustomEntityType(CustomEntity_Type.BOOL,
            CustomEntityValue()..value = "0", await buildContext(tester)),
        "No",
      );
    });
  });

  group("parseId", () {
    test("Input", () {
      expect(() => parseId(null), throwsAssertionError);
      expect(() => parseId(""), throwsAssertionError);
    });

    test("Bad UUID string", () {
      expect(() => parseId("XYZ"), throwsArgumentError);
    });

    test("Good UUID string", () {
      Id id = parseId(Uuid().v1());
      expect(id, isNotNull);
      expect(id.uuid, isNotEmpty);
    });
  });
}
