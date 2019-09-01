import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/widgets/input.dart';
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
}