import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/property.dart';

void main() {
  test("Entity equality", () {
    var entity1 = Entity([
      SingleProperty<int>(key: "numberOfLegs", value: 4),
      SingleProperty<bool>(key: "hasTail", value: true),
      SingleProperty<String>(key: "name", value: "dog"),
      CustomProperty<String>(key: "ID123", value: "black"),
      CustomProperty<int>(key: "ID321", value: 9),
    ], id: "ID1");

    var entity2 = Entity([
      SingleProperty<int>(key: "numberOfLegs", value: 4),
      SingleProperty<bool>(key: "hasTail", value: true),
      SingleProperty<String>(key: "name", value: "dog"),
      CustomProperty<String>(key: "ID123", value: "black"),
      CustomProperty<int>(key: "ID321", value: 9),
    ], id: "ID1");

    expect(entity1, entity2);
    expect(entity1.hashCode, entity2.hashCode);

    var entity3 = Entity([
      SingleProperty<int>(key: "numberOfLegs", value: 5),
      SingleProperty<bool>(key: "hasTail", value: true),
      SingleProperty<String>(key: "name", value: "dog"),
      CustomProperty<String>(key: "ID123", value: "black"),
      CustomProperty<int>(key: "ID321", value: 9),
    ], id: "ID1");

    expect(entity1 == entity3, false);
    expect(entity1.hashCode == entity3.hashCode, false);

    var set = HashSet();
    set.add(entity1);
    expect(set.length, 1);
    set.add(entity2);
    expect(set.length, 1);
    set.add(entity3);
    expect(set.length, 2);
  });

  test("Entity mapping", () {
    var entity1 = Entity([
      SingleProperty<int>(key: "numberOfLegs", value: 4),
      SingleProperty<bool>(key: "hasTail", value: true),
      SingleProperty<String>(key: "name", value: "dog"),
      CustomProperty<String>(key: "ID123", value: "black"),
      CustomProperty<int>(key: "ID321", value: 9),
    ]);

    var map = entity1.toMap();
    expect(map["numberOfLegs"], 4);
    expect(map["hasTail"], true);
    expect(map["name"], "dog");
    expect(map["custom_properties"][0].key, "ID123");
    expect(map["custom_properties"][0].value, "black");
    expect(map["custom_properties"][1].key, "ID321");
    expect(map["custom_properties"][1].value, 9);

    map = {
      "id" : "testId",
    };
    var entity2 = Entity.fromMap([], map);
    expect(entity2.id, "testId");

    map = {};
    expect(() => Entity.fromMap([], map), throwsAssertionError);
  });
}