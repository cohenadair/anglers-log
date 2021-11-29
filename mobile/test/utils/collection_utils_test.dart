import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/collection_utils.dart';

enum TestEnum {
  a,
  b,
  c,
}

void main() {
  test("Default sortedMap", () {
    expect(
      sortedIntMap<String>({
        "0": 200,
        "6": 5678,
        "3": 1000,
        "2": 1035,
        "8": 109,
        "1": 100,
      }).values,
      {
        "6": 5678,
        "2": 1035,
        "3": 1000,
        "0": 200,
        "8": 109,
        "1": 100,
      }.values,
    );
  });

  test("sortedMap with comparator", () {
    var map = {
      "0": 200,
      "6": 5678,
      "3": 1000,
      "2": 1035,
      "8": 109,
      "1": 100,
    };

    expect(
      sortedIntMap<String>(map, (lhs, rhs) => map[lhs]!.compareTo(map[rhs]!))
          .values,
      {
        "1": 100,
        "8": 109,
        "0": 200,
        "3": 1000,
        "2": 1035,
        "6": 5678,
      }.values,
    );
  });

  test("firstElements", () {
    var map = {
      "0": 200,
      "6": 5678,
      "3": 1000,
      "2": 1035,
      "8": 109,
      "1": 100,
    };

    expect(firstElements<String>(map), {
      "0": 200,
      "6": 5678,
      "3": 1000,
      "2": 1035,
      "8": 109,
      "1": 100,
    });

    expect(firstElements<String>(map, numberOfElements: 3), {
      "0": 200,
      "6": 5678,
      "3": 1000,
    });

    expect(firstElements<String>(map, numberOfElements: 30), {
      "0": 200,
      "6": 5678,
      "3": 1000,
      "2": 1035,
      "8": 109,
      "1": 100,
    });
  });

  test("valueOf", () {
    expect(valueOf<TestEnum>(TestEnum.values, 0), TestEnum.a);
    expect(
        valueOf<TestEnum>(TestEnum.values, TestEnum.values.length + 1), isNull);
  });
}
