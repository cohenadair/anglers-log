import 'package:flutter/material.dart';

const FontWeight fontWeightBold = FontWeight.w500;

const TextStyle styleHeading = TextStyle(
  fontSize: 18,
  fontWeight: fontWeightBold,
);

const TextStyle styleTitle = TextStyle(
  fontSize: 36,
  fontWeight: fontWeightBold,
);

const TextStyle styleTitleAlert = TextStyle(
  fontSize: 24,
  color: Colors.black,
);

const TextStyle styleSecondary = TextStyle(
  color: Colors.black54,
);

const TextStyle styleHyperlink = TextStyle(
  color: Colors.blue,
  decoration: TextDecoration.underline,
);

const TextStyle styleError = TextStyle(
  color: Colors.red,
);

const List<BoxShadow> boxShadowDefault = [
  BoxShadow(
    color: Colors.grey,
    blurRadius: 5.0,
  ),
];

const List<BoxShadow> boxShadowSmallBottom = [
  BoxShadow(
    color: Colors.grey,
    blurRadius: 2.0,
    offset: Offset(0, 2.0),
  ),
];