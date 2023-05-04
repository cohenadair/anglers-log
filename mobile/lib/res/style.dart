import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';

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

TextStyle styleTitle2(BuildContext context) => TextStyle(
      fontSize: 24,
      color: context.colorText,
    );

TextStyle styleTitleAppBar(BuildContext context) => TextStyle(
      fontSize: 20,
      color: context.colorAppBarContent,
      fontWeight: fontWeightBold,
    );

TextStyle styleTitleAlert(BuildContext context) => TextStyle(
      fontSize: 24,
      color: context.colorText,
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
  return Theme.of(context).textTheme.titleMedium!.copyWith(
        color: enabled
            ? Theme.of(context).textTheme.titleMedium!.color
            : Theme.of(context).disabledColor,
      );
}

TextStyle styleSecondary(BuildContext context) =>
    stylePrimary(context).copyWith(color: Colors.grey);

TextStyle styleDisabled(BuildContext context) =>
    stylePrimary(context, enabled: false);

TextStyle styleSubtitle(
  BuildContext context, {
  bool enabled = true,
}) {
  return Theme.of(context).textTheme.titleSmall!.copyWith(
        color: enabled ? Colors.grey : Theme.of(context).disabledColor,
        fontWeight: FontWeight.normal,
      );
}

TextStyle styleListHeading(BuildContext context) {
  return Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: context.colorDefault,
      );
}

List<BoxShadow> boxShadowDefault(BuildContext context) {
  return [
    BoxShadow(
      color: context.colorBoxShadow,
      blurRadius: 1.0,
      offset: const Offset(0, 1.0),
    ),
  ];
}
