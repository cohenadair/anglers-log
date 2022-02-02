import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

import 'label_value.dart';

class LabelValueList extends StatelessWidget {
  final Iterable<LabelValueListItem> items;
  final String? title;
  final EdgeInsets? padding;

  const LabelValueList({
    required this.items,
    this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Empty();
    }

    Widget titleWidget = const Empty();
    if (isNotEmpty(title)) {
      titleWidget = Padding(
        padding: insetsBottomDefault,
        child: HeadingDivider(title!),
      );
    }

    return Padding(
      padding: padding ?? insetsZero,
      child: Column(
        children: [
          titleWidget,
          ...items.map((e) {
            return LabelValue(
              label: e.label,
              value: e.value,
              padding: insetsHorizontalDefaultVerticalSmall,
            );
          }),
        ],
      ),
    );
  }
}

class LabelValueListItem {
  final String label;
  final String value;

  LabelValueListItem(this.label, this.value);
}
