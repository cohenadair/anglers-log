import 'dart:math';

import 'package:flutter/material.dart';

List<Color> accentColors() {
  var primaries = List.of(Colors.primaries)
    ..remove(Colors.brown)
    ..remove(Colors.blueGrey);

  // Use opacity to flatten the color a little bit.
  return primaries.map((e) => e.withOpacity(0.65)).toList();
}

Color randomAccentColor() {
  var colors = accentColors();
  return colors[Random().nextInt(colors.length)];
}
