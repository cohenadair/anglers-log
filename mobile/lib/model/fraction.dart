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

  static Fraction fromValue(double? value) {
    if (value == null || value <= 0) {
      return zero;
    } else if (value == eighth.value) {
      return eighth;
    } else if (value == quarter.value) {
      return quarter;
    } else if (value == threeEighths.value) {
      return threeEighths;
    } else if (value == half.value) {
      return half;
    } else if (value == fiveEights.value) {
      return fiveEights;
    } else if (value == threeQuarters.value) {
      return threeQuarters;
    } else if (value == sevenEighths.value) {
      return sevenEighths;
    } else {
      return zero;
    }
  }

  final String symbol;
  final double value;

  const Fraction(this.symbol, this.value);
}
