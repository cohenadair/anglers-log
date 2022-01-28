import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/number_utils.dart';

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
    expect(10.toDouble().displayValue(), "10");

    // Floating number.
    expect(10.58694.displayValue(), "10.59");

    // Whole floating number.
    expect(10.0.displayValue(), "10");

    // Trailing 0.
    expect(10.50.displayValue(), "10.5");

    // Set decimal places.
    expect(10.5556.displayValue(3), "10.556");
  });

  test("percent", () {
    expect(percent(50, 200), 25);
    expect(percent(0, 200), 0);
    expect(percent(200, 200), 100);
    expect(percent(100, 50), 200);
    expect(() => percent(200, 0), throwsAssertionError);
  });
}
