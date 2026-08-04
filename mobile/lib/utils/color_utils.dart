import 'dart:math';

import 'package:adair_flutter_lib/utils/color.dart';
import 'package:flutter/material.dart';

Color randomAccentColor() {
  var colors = accentColors();
  return colors[Random().nextInt(colors.length)];
}
