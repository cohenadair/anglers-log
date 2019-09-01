import 'dart:collection';

import 'package:mobile/model/property.dart';
import 'package:test/test.dart';

void main() {
  test("SingleProperty equality", () {
    var prop1 = SingleProperty<int>(
      key: "Test Property",
      value: 10,
    );

    var prop2 = SingleProperty<int>(
      key: "Test Property",
      value: 10,
    );

    expect(prop1, prop2);
    expect(prop1.hashCode, prop2.hashCode);

    var prop3 = SingleProperty<int>(
      key: "Test Property",
      value: 15,
    );

    expect(prop1 == prop3, false);
    expect(prop1.hashCode == prop3.hashCode, false);

    var set = HashSet();
    set.add(prop1);
    expect(set.length, 1);
    set.add(prop2);
    expect(set.length, 1);
    set.add(prop3);
    expect(set.length, 2);
  });

  test("CustomProperty mapping", () {
    var prop1 = CustomProperty<String>(
      key: "ID12345",
      value: "A test value",
    );
    expect(prop1.toMap()["ID12345"] == "A test value", true);
  });
}