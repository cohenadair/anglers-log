extension Doubles on double {
  bool get isWhole => this % 1 == 0;

  int? roundIfWhole() => isWhole ? round() : null;
}
