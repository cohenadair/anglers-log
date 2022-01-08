class Fraction {
  static const zero = Fraction("0", 0);
  static const eighth = Fraction("\u215B", 0.125);
  static const quarter = Fraction("\u00BC", 0.25);
  static const threeEighths = Fraction("\u215C", 0.375);
  static const half = Fraction("\u00BD", 0.5);
  static const fiveEights = Fraction("\u215D", 0.625);
  static const threeQuarters = Fraction("\u00BE", 0.75);
  static const sevenEighths = Fraction("\u215E", 0.875);

  static const all = <Fraction>[
    zero,
    eighth,
    quarter,
    threeEighths,
    half,
    fiveEights,
    threeQuarters,
    sevenEighths,
  ];

  static Fraction fromValue(double? input) {
    if (input == null || input <= 0) {
      return zero;
    }

    var result = zero;
    var largestDifference = double.infinity;

    for (var fraction in all) {
      var value = fraction.value;

      if (input == value) {
        return fraction;
      }

      var difference = (value - input).abs();
      if (difference < largestDifference) {
        largestDifference = difference;
        result = fraction;
      }
    }

    return result;
  }

  final String symbol;
  final double value;

  const Fraction(this.symbol, this.value);
}
