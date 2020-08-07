import 'package:mobile/model/bait.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/named_entity.dart';
import 'package:quiver/core.dart';
import 'package:test/test.dart';

void main() {
  test("Mapping", () {
    var bait = Bait(
      name: "Test name",
      baseId: "BaseId",
      photoId: "PhotoId",
      categoryId: "CategoryId",
      color: "Red",
      model: "CD37",
      size: "8",
      type: BaitType.artificial,
      minDiveDepth: 5.0,
      maxDiveDepth: 9.0,
      description: "Crazy action. Good for dirty water.",
    );
    var map = bait.toMap();
    expect(map[Entity.keyId], isNotNull);
    expect(map[NamedEntity.keyName], "Test name");
    expect(map[Bait.keyBaseId], "BaseId");
    expect(map[Bait.keyPhotoId], "PhotoId");
    expect(map[Bait.keyBaitCategoryId], "CategoryId");
    expect(map[Bait.keyColor], "Red");
    expect(map[Bait.keyModel], "CD37");
    expect(map[Bait.keySize], "8");
    expect(map[Bait.keyType], 0);
    expect(map[Bait.keyMinDiveDepth], 5.0);
    expect(map[Bait.keyMaxDiveDepth], 9.0);
    expect(map[Bait.keyDescription], "Crazy action. Good for dirty water.");

    map = {
      Entity.keyId : "ID",
      NamedEntity.keyName : "Test name",
      Bait.keyBaseId : "BaseId",
      Bait.keyPhotoId : "PhotoId",
      Bait.keyBaitCategoryId : "CategoryId",
      Bait.keyColor : "Red",
      Bait.keyModel : "CD37",
      Bait.keySize : "8",
      Bait.keyType : 0,
      Bait.keyMinDiveDepth : 5.0,
      Bait.keyMaxDiveDepth : 9.0,
      Bait.keyDescription : "Crazy action. Good for dirty water.",
    };
    bait = Bait.fromMap(map);
    expect(bait.id, "ID");
    expect(bait.name, "Test name");
    expect(bait.baseId, "BaseId");
    expect(bait.photoId, "PhotoId");
    expect(bait.categoryId, "CategoryId");
    expect(bait.color, "Red");
    expect(bait.model, "CD37");
    expect(bait.size, "8");
    expect(bait.type, BaitType.artificial);
    expect(bait.minDiveDepth, 5.0);
    expect(bait.maxDiveDepth, 9.0);
    expect(bait.description, "Crazy action. Good for dirty water.");

    // Invalid BaitType value returns null.
    map[Bait.keyType] = 10;
    bait = Bait.fromMap(map);
    expect(bait.type, isNull);

    map[Bait.keyType] = null;
    bait = Bait.fromMap(map);
    expect(bait.type, isNull);
  });

  test("Copy", () {
    var bait = Bait(
      id: "bait_id",
      name: "Test name",
      baseId: "BaseId",
      photoId: "PhotoId",
      categoryId: "CategoryId",
      color: "Red",
      model: "CD37",
      size: "8",
      type: BaitType.artificial,
      minDiveDepth: 5.0,
      maxDiveDepth: 9.0,
      description: "Crazy action. Good for dirty water.",
    );

    // No changes.
    var copy = bait.copyWith();
    expect(copy.id, "bait_id");
    expect(copy.name, "Test name");
    expect(copy.baseId, "BaseId");
    expect(copy.photoId, "PhotoId");
    expect(copy.categoryId, "CategoryId");
    expect(copy.color, "Red");
    expect(copy.model, "CD37");
    expect(copy.size, "8");
    expect(copy.type, BaitType.artificial);
    expect(copy.minDiveDepth, 5.0);
    expect(copy.maxDiveDepth, 9.0);
    expect(copy.description, "Crazy action. Good for dirty water.");

    // Changed.
    copy = bait.copyWith(
      id: "bait_id_2",
      name: "Test name 2",
      baseId: Optional.of("BaseId2"),
      photoId: Optional.of("PhotoId2"),
      categoryId: Optional.of("CategoryId2"),
      color: Optional.of("Red2"),
      model: Optional.of("CD372"),
      size: Optional.of("82"),
      type: Optional.of(BaitType.real),
      minDiveDepth: Optional.of(5.2),
      maxDiveDepth: Optional.of(9.2),
      description: Optional.of("Crazy action. Good for dirty water 2."),
    );
    expect(copy.id, "bait_id_2");
    expect(copy.name, "Test name 2");
    expect(copy.baseId, "BaseId2");
    expect(copy.photoId, "PhotoId2");
    expect(copy.categoryId, "CategoryId2");
    expect(copy.color, "Red2");
    expect(copy.model, "CD372");
    expect(copy.size, "82");
    expect(copy.type, BaitType.real);
    expect(copy.minDiveDepth, 5.2);
    expect(copy.maxDiveDepth, 9.2);
    expect(copy.description, "Crazy action. Good for dirty water 2.");

    // Null properties.
    copy = bait.copyWith(
      id: "bait_id_2",
      name: "Test name 2",
      baseId: Optional.absent(),
      photoId: Optional.absent(),
      categoryId: Optional.absent(),
      color: Optional.absent(),
      model: Optional.absent(),
      size: Optional.absent(),
      type: Optional.absent(),
      minDiveDepth: Optional.absent(),
      maxDiveDepth: Optional.absent(),
      description: Optional.absent(),
    );
    expect(copy.id, "bait_id_2");
    expect(copy.name, "Test name 2");
    expect(copy.baseId, isNull);
    expect(copy.photoId, isNull);
    expect(copy.categoryId, isNull);
    expect(copy.color, isNull);
    expect(copy.model, isNull);
    expect(copy.size, isNull);
    expect(copy.type, isNull);
    expect(copy.minDiveDepth, isNull);
    expect(copy.maxDiveDepth, isNull);
    expect(copy.description, isNull);
  });

  test("Check duplication", () {
    var bait = Bait(
      id: "bait_id",
      name: "Test name",
      baseId: "BaseId",
      photoId: "PhotoId",
      categoryId: "CategoryId",
      color: "Red",
      model: "CD37",
      size: "8",
      type: BaitType.artificial,
      minDiveDepth: 5.0,
      maxDiveDepth: 9.0,
      description: "Crazy action. Good for dirty water.",
    );
    // Equal baits are not considered duplicates.
    expect(bait.isDuplicateOf(bait.copyWith()), false);

    // If ID is different, they are considered duplicates.
    expect(bait.isDuplicateOf(bait.copyWith(id: "bait_id_2")), true);

    // Photo ID and description aren't considered when calculating duplication.
    expect(bait.isDuplicateOf(
        bait.copyWith(description: Optional.of("Different"))), false);
    expect(bait.isDuplicateOf(
        bait.copyWith(photoId: Optional.of("Different"))), false);
  });
}