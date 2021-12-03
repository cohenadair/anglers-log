import 'dart:math';

import 'package:flutter/material.dart';

List<Color> accentColors([List<Color>? exclude]) {
  var primaries = List.of(Colors.primaries)
    ..remove(Colors.brown)
    ..remove(Colors.blueGrey)
    ..removeWhere((e) => exclude?.contains(e) ?? false);

  // Use opacity to flatten the color a little bit.
  return primaries.map((e) => e.withOpacity(0.65)).toList();
}

Color randomAccentColor([List<Color>? exclude]) {
  var colors = accentColors(exclude);
  return colors[Random().nextInt(colors.length)];
}
