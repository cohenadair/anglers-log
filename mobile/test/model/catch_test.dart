import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/entity.dart';

void main() {
  test("Mapping", () {
    var testCatch = Catch(
      id: "Catch1",
      timestamp: 5000,
      speciesId: "species_id",
      fishingSpotId: "fishing_spot_id",
      baitId: "bait_id",
    );

    var map = testCatch.toMap();
    expect(map[Entity.keyId], isNotNull);
    expect(map[Catch.keyTimestamp], 5000);
    expect(map[Catch.keySpeciesId], "species_id");
    expect(map[Catch.keyFishingSpotId], "fishing_spot_id");
    expect(map[Catch.keyBaitId], "bait_id");

    map = {
      Entity.keyId : "ID",
      Catch.keyTimestamp : 10000,
      Catch.keySpeciesId : "species_id_1",
      Catch.keyFishingSpotId : "fishing_spot_id_1",
      Catch.keyBaitId : "bait_id_1",
    };
    testCatch = Catch.fromMap(map);
    expect(testCatch.id, "ID");
    expect(testCatch.timestamp, 10000);
    expect(testCatch.baitId, "bait_id_1");
    expect(testCatch.fishingSpotId, "fishing_spot_id_1");
    expect(testCatch.speciesId, "species_id_1");
  });

  test("Map missing parameters", () {
    expect(() => Catch(
      id: "Catch1",
      timestamp: 5000,
      speciesId: null,
    ), throwsAssertionError);

    expect(() => Catch(
      id: "Catch1",
      timestamp: null,
      speciesId: "ID",
    ), throwsAssertionError);

    expect(() => Catch(
      id: "Catch1",
      timestamp: 5000,
      speciesId: "ID",
    ), isNotNull);
  });
}