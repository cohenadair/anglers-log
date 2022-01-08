import 'package:mobile/model/fraction.dart';
import 'package:test/test.dart';

void main() {
  test("fromValue null input", () {
    expect(Fraction.fromValue(null), Fraction.zero);
  });

  test("fromValue less than 0 input", () {
    expect(Fraction.fromValue(-1), Fraction.zero);
  });

  test("fromValue with exact input", () {
    expect(Fraction.fromValue(0).value, Fraction.zero.value);
    expect(Fraction.fromValue(0.125).value, Fraction.eighth.value);
    expect(Fraction.fromValue(0.25).value, Fraction.quarter.value);
    expect(Fraction.fromValue(0.375).value, Fraction.threeEighths.value);
    expect(Fraction.fromValue(0.5).value, Fraction.half.value);
    expect(Fraction.fromValue(0.625).value, Fraction.fiveEights.value);
    expect(Fraction.fromValue(0.75).value, Fraction.threeQuarters.value);
    expect(Fraction.fromValue(0.875).value, Fraction.sevenEighths.value);
  });

  test("fromValue with close input", () {
    expect(Fraction.fromValue(0.05).value, Fraction.zero.value);
    expect(Fraction.fromValue(0.122).value, Fraction.eighth.value);
    expect(Fraction.fromValue(0.27).value, Fraction.quarter.value);
    expect(Fraction.fromValue(0.385).value, Fraction.threeEighths.value);
    expect(Fraction.fromValue(0.525).value, Fraction.half.value);
    expect(Fraction.fromValue(0.675).value, Fraction.fiveEights.value);
    expect(Fraction.fromValue(0.775).value, Fraction.threeQuarters.value);
    expect(Fraction.fromValue(0.9).value, Fraction.sevenEighths.value);
  });
}
