import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';

const FontWeight fontWeightBold = FontWeight.w500;

const TextStyle styleHeading = TextStyle(
  fontSize: 18,
  fontWeight: fontWeightBold,
);

const TextStyle styleHeadingSmall = TextStyle(
  fontSize: 14,
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

const TextStyle styleWarning = TextStyle(
  color: Colors.orange,
);

const TextStyle styleSuccess = TextStyle(
  color: Colors.green,
);

/// For displaying on dark backgrounds.
const TextStyle styleLight = TextStyle(
  color: Colors.white,
);

TextStyle styleNote(BuildContext context) =>
    Theme.of(context).textTheme.subtitle1.copyWith(
      fontStyle: FontStyle.italic,
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

/// A [BoxDecoration] wrapper that should be used for any "floating" widgets
/// used throughout the app.
class FloatingBoxDecoration extends BoxDecoration {
  final Color color = Colors.white;
  final bool elevated;

  FloatingBoxDecoration.rectangle({
    this.elevated = true,
  }) : super(
    color: Colors.white,
    boxShadow: elevated ? boxShadowSmallBottom : null,
    borderRadius: BorderRadius.all(
      Radius.circular(floatingCornerRadius),
    ),
  );

  FloatingBoxDecoration.circle({
    this.elevated = true,
  }) : super(
    color: Colors.white,
    boxShadow: elevated ? boxShadowSmallBottom : null,
    shape: BoxShape.circle,
  );
}