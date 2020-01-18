import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/property.dart';

void main() {
  test("Entity equality", () {
    var entity1 = Entity([
      Property<int>(key: "numberOfLegs", value: 4),
      Property<bool>(key: "hasTail", value: true),
      Property<String>(key: "name", value: "dog"),
    ], id: "ID1");

    var entity2 = Entity([
      Property<int>(key: "numberOfLegs", value: 4),
      Property<bool>(key: "hasTail", value: true),
      Property<String>(key: "name", value: "dog"),
    ], id: "ID1");

    expect(entity1, entity2);
    expect(entity1.hashCode, entity2.hashCode);

    var entity3 = Entity([
      Property<int>(key: "numberOfLegs", value: 5),
      Property<bool>(key: "hasTail", value: true),
      Property<String>(key: "name", value: "dog"),
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
      Property<int>(key: "numberOfLegs", value: 4),
      Property<bool>(key: "hasTail", value: true),
      Property<String>(key: "name", value: "dog"),
    ]);

    var map = entity1.toMap();
    expect(map["numberOfLegs"], 4);
    expect(map["hasTail"], true);
    expect(map["name"], "dog");

    map = {
      "id" : "testId",
    };
    var entity2 = Entity.fromMap([], map);
    expect(entity2.id, "testId");

    map = {};
    expect(() => Entity.fromMap([], map), throwsAssertionError);
  });
}