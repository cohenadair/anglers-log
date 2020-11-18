import 'package:flutter/material.dart';

bool hasBottomSafeArea(BuildContext context) {
  return MediaQuery.of(context).viewPadding.bottom > 0;
}
