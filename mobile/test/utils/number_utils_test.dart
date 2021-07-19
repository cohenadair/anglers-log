import 'package:mobile/utils/number_utils.dart';
import 'package:test/test.dart';

void main() {
  test("isWhole", () {
    expect(2.5.isWhole, isFalse);
    expect(2.0.isWhole, isTrue);
    expect(2.toDouble().isWhole, isTrue);
  });

  test("roundIfWhole", () {
    expect(2.5.roundIfWhole(), isNull);
    expect(2.0.roundIfWhole(), 2);
    expect(2.toDouble().roundIfWhole(), 2);
  });

  test("displayValue", () {
    // Whole number.
    expect(10.toDouble().displayValue, "10");

    // Floating number.
    expect(10.58694.displayValue, "10.59");

    // Whole floating number.
    expect(10.0.displayValue, "10");

    // Trailing 0.
    expect(10.50.displayValue, "10.5");
  });
}
