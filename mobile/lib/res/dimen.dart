import 'package:flutter/material.dart';

const paddingXL = 32.0;
const paddingLarge = 24.0;
const paddingDefault = 16.0;
const paddingMedium = 12.0;
const paddingSmall = 8.0;
const paddingTiny = 4.0;

const insetsXL = EdgeInsets.all(paddingDefault * 2);
const insetsDefault = EdgeInsets.all(paddingDefault);
const insetsMedium = EdgeInsets.all(paddingMedium);
const insetsSmall = EdgeInsets.all(paddingSmall);
const insetsTiny = EdgeInsets.all(paddingTiny);
const insetsZero = EdgeInsets.all(0);

const insetsRowDefault = EdgeInsets.only(
  left: paddingDefault,
  right: paddingDefault,
  top: paddingSmall,
  bottom: paddingSmall,
);

const insetsVerticalDefault = EdgeInsets.only(
  top: paddingDefault,
  bottom: paddingDefault,
);

const insetsVerticalSmall = EdgeInsets.only(
  top: paddingSmall,
  bottom: paddingSmall,
);

const insetsHorizontalDefault = EdgeInsets.only(
  left: paddingDefault,
  right: paddingDefault,
);

const insetsHorizontalMedium = EdgeInsets.only(
  left: paddingMedium,
  right: paddingMedium,
);

const insetsHorizontalSmall = EdgeInsets.only(
  left: paddingSmall,
  right: paddingSmall,
);

const insetsHorizontalTiny = EdgeInsets.only(
  left: paddingTiny,
  right: paddingTiny,
);

const insetsTopDefault = EdgeInsets.only(top: paddingDefault);
const insetsTopSmall = EdgeInsets.only(top: paddingSmall);
const insetsTopDefaultRightDefault = EdgeInsets.only(
  top: paddingDefault,
  right: paddingDefault,
);

const insetsBottomXL = EdgeInsets.only(bottom: paddingXL);
const insetsBottomDefault = EdgeInsets.only(bottom: paddingDefault);
const insetsBottomSmall = EdgeInsets.only(bottom: paddingSmall);

const insetsLeftDefault = EdgeInsets.only(left: paddingDefault);
const insetsLeftSmall = EdgeInsets.only(left: paddingSmall);

const insetsRightDefault = EdgeInsets.only(right: paddingDefault);
const insetsRightSmall = EdgeInsets.only(right: paddingSmall);
const insetsRightTiny = EdgeInsets.only(right: paddingTiny);

const insetsVerticalDefaultHorizontalSmall = EdgeInsets.only(
  left: paddingSmall,
  right: paddingSmall,
  top: paddingDefault,
  bottom: paddingDefault,
);

const insetsHorizontalDefaultVerticalSmall = EdgeInsets.only(
  left: paddingDefault,
  right: paddingDefault,
  top: paddingSmall,
  bottom: paddingSmall,
);

const insetsHorizontalDefaultVerticalXL = EdgeInsets.only(
  left: paddingDefault,
  right: paddingDefault,
  top: paddingXL,
  bottom: paddingXL,
);

const insetsHorizontalDefaultBottomDefault = EdgeInsets.only(
  left: paddingDefault,
  right: paddingDefault,
  bottom: paddingDefault,
);

const insetsHorizontalDefaultBottomSmall = EdgeInsets.only(
  left: paddingDefault,
  right: paddingDefault,
  bottom: paddingSmall,
);

const insetsHorizontalDefaultTopDefault = EdgeInsets.only(
  left: paddingDefault,
  right: paddingDefault,
  top: paddingDefault,
);

const insetsHorizontalDefaultTopSmall = EdgeInsets.only(
  left: paddingDefault,
  right: paddingDefault,
  top: paddingSmall,
);

EdgeInsets insetsVertical(double padding) => EdgeInsets.only(
      top: padding,
      bottom: padding,
    );

const iconSizeLarge = 32.0;
const iconSizeDefault = 24.0;

const checkboxSizeDefault = 24.0;

const floatingCornerRadius = 10.0;
const defaultBorderRadius =
    BorderRadius.all(Radius.circular(floatingCornerRadius));

const galleryMaxThumbSize = 120.0;
const gallerySpacing = 2.0;
