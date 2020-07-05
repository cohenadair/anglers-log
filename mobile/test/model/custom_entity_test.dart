import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/widgets/input_type.dart';
import 'package:test/test.dart';

void main() {
  test("Test getters", () {
    var entity = CustomEntity(
      name: "Water Temperature",
      type: InputType.number,
    );
    expect(entity.name, "Water Temperature");
    expect(entity.description, null);
    expect(entity.type, InputType.number);

    entity = CustomEntity(
      name: "Water Temperature",
      description: "The temperature of the body of water.",
      type: InputType.number,
    );
    expect(entity.name, "Water Temperature");
    expect(entity.description, "The temperature of the body of water.");
    expect(entity.type, InputType.number);
  });

  test("Initialize from map", () {
    var entity = CustomEntity.fromMap({
      "id" : "ID",
      "name" : "Bait Color",
      "description" : "The color of the bait.",
      "type" : 1,
    });
    expect(entity.name, "Bait Color");
    expect(entity.description, "The color of the bait.");
    expect(entity.type, InputType.boolean);

    entity = CustomEntity.fromMap({
      "id" : "ID",
      "name" : "Bait Color",
      "type" : InputType.values.length,
    });
    expect(entity.name, "Bait Color");
    expect(entity.description, isNull);
    expect(entity.type, InputType.text);

    entity = CustomEntity.fromMap({
      "id" : "ID",
      "name" : "Bait Color",
      "type" : InputType.values.length + 1,
    });
    expect(entity.type, InputType.text);
  });
}