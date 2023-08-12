import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/number_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
    expect(10.5556.displayValue(decimalPlaces: 3), "10.556");

    // Floating number with comma locale.
    expect(10.55.displayValue(locale: "fi_FI"), "10,55");
  });

  test("tryLocaleParse", () {
    // Empty input.
    expect(null, Doubles.tryLocaleParse(null));
    expect(null, Doubles.tryLocaleParse(""));

    // Invalid input.
    expect(null, Doubles.tryLocaleParse("Not a double"));

    // Valid input for current locale.
    expect(10.5, Doubles.tryLocaleParse("10.5"));

    // Valid input for foreign locale.
    expect(10.5, Doubles.tryLocaleParse("10,5", locale: "fi_FI"));

    // Input that will fail locale parse.
    expect(10.5, Doubles.tryLocaleParse("10.5", locale: "nb-NO"));
  });

  test("percent", () {
    expect(percent(50, 200), 25);
    expect(percent(0, 200), 0);
    expect(percent(200, 200), 100);
    expect(percent(100, 50), 200);
    expect(() => percent(200, 0), throwsAssertionError);
  });
}
