import 'package:flutter/material.dart';

Color colorGreyAccent = Colors.grey.shade300;

const FontWeight fontWeightBold = FontWeight.w500;

const TextStyle styleHeading = TextStyle(
  fontSize: 18,
  fontWeight: fontWeightBold,
);

const TextStyle styleHeadingSmall = TextStyle(
  fontSize: 14,
  fontWeight: fontWeightBold,
);

const TextStyle styleTitle1 = TextStyle(
  fontSize: 36,
  fontWeight: fontWeightBold,
);

const TextStyle styleTitle2 = TextStyle(
  fontSize: 24,
  color: Colors.black,
);

const TextStyle styleTitleAppBar = TextStyle(
  fontSize: 20,
  color: Colors.black,
  fontWeight: fontWeightBold,
);

const TextStyle styleTitleAlert = TextStyle(
  fontSize: 24,
  color: Colors.black,
);

TextStyle styleHyperlink(BuildContext context) =>
    stylePrimary(context).copyWith(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    );

TextStyle styleError(BuildContext context) =>
    stylePrimary(context).copyWith(color: Colors.red);

TextStyle styleWarning(BuildContext context) =>
    stylePrimary(context).copyWith(color: Colors.orange);

TextStyle styleSuccess(BuildContext context) =>
    stylePrimary(context).copyWith(color: Colors.green);

/// For displaying on dark backgrounds.
TextStyle styleLight(BuildContext context) =>
    stylePrimary(context).copyWith(color: Colors.white);

const TextStyle styleSubtext = TextStyle(
  fontSize: 11.0,
  fontStyle: FontStyle.italic,
);

TextStyle styleNote(BuildContext context) =>
    stylePrimary(context).copyWith(fontStyle: FontStyle.italic);

TextStyle stylePrimary(
  BuildContext context, {
  bool enabled = true,
}) {
  return Theme.of(context).textTheme.subtitle1!.copyWith(
        color: enabled
            ? Theme.of(context).textTheme.subtitle1!.color
            : Theme.of(context).disabledColor,
      );
}

TextStyle styleSecondary(BuildContext context) =>
    stylePrimary(context).copyWith(color: Colors.black54);

TextStyle styleDisabled(BuildContext context) =>
    stylePrimary(context, enabled: false);

TextStyle styleSubtitle(
  BuildContext context, {
  bool enabled = true,
}) {
  return Theme.of(context).textTheme.subtitle2!.copyWith(
        color: enabled ? Colors.grey : Theme.of(context).disabledColor,
        fontWeight: FontWeight.normal,
      );
}

TextStyle styleListHeading(BuildContext context) {
  return Theme.of(context).textTheme.bodyText1!.copyWith(
        color: Theme.of(context).primaryColor,
      );
}

const List<BoxShadow> boxShadowDefault = [
  BoxShadow(
    color: Colors.grey,
    blurRadius: 1.0,
    offset: Offset(0, 1.0),
  ),
];
