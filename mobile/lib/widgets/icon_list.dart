import 'package:flutter/material.dart';

import '../res/dimen.dart';
import '../res/style.dart';
import 'widget.dart';

/// A widget that displays an icon to the left of only the first item in the
/// list. All other items are horizontally aligned with the text from the first
/// item.
class IconList extends StatelessWidget {
  final List<String> values;
  final IconData icon;

  const IconList({
    required this.values,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: paddingTiny,
      children: values.map((value) => _buildRow(context, value)).toList(),
    );
  }

  Widget _buildRow(BuildContext context, String value) {
    return Row(
      children: [
        Opacity(
          // Use Opacity so items are horizontally aligned.
          opacity: values.indexOf(value) >= 1 ? 0.0 : 1.0,
          child: GreyAccentIcon(icon),
        ),
        const HorizontalSpace(paddingXL),
        Expanded(
          child: Text(
            value,
            style: stylePrimary(context),
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}
