import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/entity.dart';
import 'package:quiver/core.dart';

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

  test("Copy", () {
    var cat = Catch(
      id: "CatchId",
      timestamp: 5000,
      speciesId: "SpeciesId",
      baitId: "BaitId",
      fishingSpotId: "FishingSpotId",
    );

    // No changes.
    var copy = cat.copyWith();
    expect(copy.id, "CatchId");
    expect(copy.timestamp, 5000);
    expect(copy.speciesId, "SpeciesId");
    expect(copy.baitId, "BaitId");
    expect(copy.fishingSpotId, "FishingSpotId");

    // Changed.
    copy = cat.copyWith(
      id: "CatchId2",
      timestamp: 5002,
      speciesId: "SpeciesId2",
      baitId: Optional.of("BaitId2"),
      fishingSpotId: Optional.of("FishingSpotId2"),
    );
    expect(copy.id, "CatchId2");
    expect(copy.timestamp, 5002);
    expect(copy.speciesId, "SpeciesId2");
    expect(copy.baitId, "BaitId2");
    expect(copy.fishingSpotId, "FishingSpotId2");

    // Null properties.
    copy = cat.copyWith(
      id: "CatchId2",
      timestamp: 5002,
      speciesId: "SpeciesId2",
      baitId: Optional.absent(),
      fishingSpotId: Optional.absent(),
    );
    expect(copy.id, "CatchId2");
    expect(copy.timestamp, 5002);
    expect(copy.speciesId, "SpeciesId2");
    expect(copy.baitId, isNull);
    expect(copy.fishingSpotId, isNull);
  });
}