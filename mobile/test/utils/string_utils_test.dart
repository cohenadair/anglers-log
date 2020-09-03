import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/string_utils.dart';

void main() {
  test("isEqualTrimmedLowercase", () {
    expect(isEqualTrimmedLowercase(null, null), true);
    expect(isEqualTrimmedLowercase("", ""), true);
    expect(isEqualTrimmedLowercase(null, ""), false);
    expect(isEqualTrimmedLowercase("", null), false);
    expect(isEqualTrimmedLowercase(null, "Test"), false);
    expect(isEqualTrimmedLowercase("Test", null), false);
    expect(isEqualTrimmedLowercase("", "Test"), false);
    expect(isEqualTrimmedLowercase("Test", ""), false);
    expect(isEqualTrimmedLowercase("Test", "Test"), true);
    expect(isEqualTrimmedLowercase("Test1", "Test2"), false);
  });

  test("Format function", () {
    var formatString = format("You caught %s fish in %s days.", [5, 3]);
    expect(formatString, "You caught 5 fish in 3 days.");

    formatString = format("You've added angler %s to your log.",
        ["Cohen Adair"]);
    expect(formatString, "You've added angler Cohen Adair to your log.");
  });
}