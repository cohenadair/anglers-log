import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/id.dart';
import 'package:uuid/uuid.dart';

void main() {
  test("Invalid input", () {
    expect(() => Id([0]), throwsArgumentError);
    expect(() => Id.parse(""), throwsAssertionError);
    expect(() => Id.parse(null), throwsAssertionError);
    expect(() => Id.parse("zzz"), throwsArgumentError);
    expect(() => Id.parse("b860cddd-dc47-48a2-8d02-c8112a2ed5eb"), isNotNull);
    expect(Id.random(), isNotNull);
  });

  test("Id used in Map", () {
    List<int> uuid0 = Uuid().parse(Uuid().v1());
    List<int> uuid1 = Uuid().parse(Uuid().v1());
    List<int> uuid2 = Uuid().parse(Uuid().v1());

    Map<Id, int> map = {
      Id(uuid0): 5,
      Id(uuid1): 10,
      Id(uuid2): 15,
    };

    expect(map[Id(uuid0)], 5);
    expect(map[Id(uuid1)], 10);
    expect(map[Id(uuid2)], 15);
    expect(map[Id(Uuid().parse(Uuid().v1()))], isNull);
  });

  // TODO: Test fromPbId
}