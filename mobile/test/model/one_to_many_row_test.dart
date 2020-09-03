import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/one-to-many-row.dart';

class TestOneToManyRow extends OneToManyRow {
  TestOneToManyRow({
    String firstColumn,
    String secondColumn,
    String first,
    String second,
  }) : super(
    firstColumn: firstColumn,
    secondColumn: secondColumn,
    firstValue: first,
    secondValue: second,
  );

  TestOneToManyRow.fromMap({
    String firstColumn,
    String secondColumn,
    Map<String, dynamic> map,
  }) : super.fromMap(
    firstColumn: firstColumn,
    secondColumn: secondColumn,
    map: map,
  );

  String get first => firstValue;
  String get second => secondValue;
}

void main() {
  test("Invalid input", () {
    expect(() => TestOneToManyRow(), throwsAssertionError);

    expect(() => TestOneToManyRow(
      firstColumn: "column_one",
    ), throwsAssertionError);

    expect(() => TestOneToManyRow(
      firstColumn: "column_one",
      secondColumn: "column_two",
    ), throwsAssertionError);

    expect(() => TestOneToManyRow(
      firstColumn: "column_one",
      secondColumn: "column_two",
      first: "1",
    ), throwsAssertionError);

    expect(() => TestOneToManyRow(
      firstColumn: "column_one",
      secondColumn: "column_two",
      first: "1",
      second: "2",
    ), isNotNull);

    expect(() => TestOneToManyRow(
      firstColumn: "column_one",
      secondColumn: "column_one",
      first: "1",
      second: "2",
    ), throwsAssertionError);
  });

  test("Mapping", () {
    TestOneToManyRow row = TestOneToManyRow(
      firstColumn: "column_one",
      secondColumn: "column_two",
      first: "Val1",
      second: "Val2",
    );

    var map = row.toMap();
    expect(map["column_one"], "Val1");
    expect(map["column_two"], "Val2");

    map = {
      "column_one" : "Val3",
      "column_two" : "Val4",
    };
    row = TestOneToManyRow.fromMap(
      firstColumn: "column_one",
      secondColumn: "column_two",
      map: map,
    );
    expect(row.first, "Val3");
    expect(row.second, "Val4");
  });
}