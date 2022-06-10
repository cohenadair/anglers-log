import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/widget.dart';

class BulletList extends StatelessWidget {
  final EdgeInsets padding;
  final Set<String> items;

  const BulletList({
    this.padding = insetsZero,
    this.items = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((e) => _buildRow(context, e)).toList(),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String item) {
    return Padding(
      padding: item == items.last ? insetsZero : insetsBottomSmall,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("\u2022", style: stylePrimary(context)),
          const HorizontalSpace(paddingDefault),
          Expanded(child: Text(item, style: stylePrimary(context))),
        ],
      ),
    );
  }
}
