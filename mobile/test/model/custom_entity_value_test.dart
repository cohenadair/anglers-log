import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/custom_entity_value.dart';
import 'package:mobile/widgets/input_type.dart';

main() {
  test("Test listFromIdValueMap", () {
    var list = CustomEntityValue.listFromIdValueMap("ID", EntityType.bait, {
      "cid0": true,
      "cid1": "Test",
      "cid2": 2.0,
      "cid3": null,
      "cid4": "",
    });
    expect(list.length, 3);
  });

  test("Init from map", () {
    var value = CustomEntityValue.fromMap({
      "entity_id": "eid1",
      "custom_entity_id": "cid1",
      "value": "Value",
      "entity_type": 1,
    });
    expect(value.textValue, equals("Value"));
    expect(value.numberValue, isNull);
    expect(value.boolValue, isFalse);
  });

  test("To map", () {
    var value = CustomEntityValue(
      entityId: "eid",
      customEntityId: "cid",
      textValue: "Value",
      entityType: EntityType.bait,
    );
    expect(value.toMap(), {
      "entity_id": "eid",
      "custom_entity_id": "cid",
      "value": "Value",
      "entity_type": 1,
    });
  });

  test("Test valueFromInputType method", () {
    var value = CustomEntityValue(
      entityId: "eid",
      customEntityId: "cid",
      textValue: "Value",
      entityType: EntityType.bait,
    );
    expect(value.valueFromInputType(InputType.text), equals("Value"));
    expect(value.valueFromInputType(InputType.number), equals("Value"));
    expect(value.valueFromInputType(InputType.boolean), isFalse);

    value = CustomEntityValue(
      entityId: "eid",
      customEntityId: "cid",
      textValue: "2.0",
      entityType: EntityType.bait,
    );
    expect(value.valueFromInputType(InputType.text), equals("2.0"));
    expect(value.valueFromInputType(InputType.number), equals("2.0"));
    expect(value.valueFromInputType(InputType.boolean), isFalse);
    expect(value.numberValue, equals(2.0));

    value = CustomEntityValue(
      entityId: "eid",
      customEntityId: "cid",
      textValue: "1",
      entityType: EntityType.bait,
    );

    expect(value.valueFromInputType(InputType.text), equals("1"));
    expect(value.valueFromInputType(InputType.number), equals("1"));
    expect(value.valueFromInputType(InputType.boolean), isTrue);
    expect(value.numberValue, equals(1));
  });
}