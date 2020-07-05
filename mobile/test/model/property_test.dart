import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/angler.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/property.dart';
import 'package:mobile/widgets/input_type.dart';

void main() {
  test("Property equality", () {
    var prop1 = Property<int>(
      key: "Test Property",
      value: 10,
    );

    var prop2 = Property<int>(
      key: "Test Property",
      value: 10,
    );

    expect(prop1, prop2);
    expect(prop1.hashCode, prop2.hashCode);

    var prop3 = Property<int>(
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

  test("Invalid property type", () {
    expect(() => Property<Angler>(key: "Key", value: Angler(name: "Cohen")),
        throwsAssertionError);
  });

  test("Get database value", () {
    var prop = Property<InputType>(
      key: "Test Property",
      value: InputType.boolean,
    );
    expect(prop.dbValue, 1);

    var prop2 = Property<BaitType>(
      key: "Test Property",
      value: BaitType.live,
    );
    expect(prop2.dbValue, 1);

    var prop3 = Property<int>(
      key: "Test Property",
      value: 5,
    );
    expect(prop3.dbValue, 5);
  });
}