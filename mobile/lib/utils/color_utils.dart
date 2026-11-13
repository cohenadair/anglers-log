import 'dart:math';

import 'package:adair_flutter_lib/utils/color.dart';
import 'package:material_ui/material_ui.dart';

Color randomAccentColor() {
  var colors = accentColors();
  return colors[Random().nextInt(colors.length)];
}
