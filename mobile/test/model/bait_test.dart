import 'package:mobile/model/bait.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/named_entity.dart';
import 'package:test/test.dart';

void main() {
  test("Mapping", () {
    var bait = Bait(
      name: "Test name",
      baseId: "BaseId",
      photoId: "PhotoId",
      baitCategoryId: "CategoryId",
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
    expect(map[Bait.keyType], BaitType.artificial);
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
      Bait.keyType : BaitType.artificial,
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
  });
}