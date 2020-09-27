import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';

void main() {
  test("Invalid input", () {
    expect(() => parseId(""), throwsAssertionError);
    expect(() => parseId(null), throwsAssertionError);
    expect(() => parseId("zzz"), throwsArgumentError);
    expect(() => parseId("b860cddd-dc47-48a2-8d02-c8112a2ed5eb"), isNotNull);
    expect(randomId(), isNotNull);
  });

  /// Tests that the [Id] object can be used as a key in a [Map]. No matter the
  /// structure of [Id], it needs to be equatable.
  test("Id used in Map", () {
    String uuid0 = randomId().uuid;
    String uuid1 = randomId().uuid;
    String uuid2 = randomId().uuid;

    Map<Id, int> map = {
      Id()..uuid = uuid0: 5,
      Id()..uuid = uuid1: 10,
      Id()..uuid = uuid2: 15,
    };

    expect(map[Id()..uuid = String.fromCharCodes(uuid0.codeUnits)], 5);
    expect(map[Id()..uuid = String.fromCharCodes(uuid1.codeUnits)], 10);
    expect(map[Id()..uuid = String.fromCharCodes(uuid2.codeUnits)], 15);
    expect(map[randomId()], isNull);
  });
}