import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/core.dart';

class BulletList extends StatelessWidget {
  final EdgeInsets padding;
  final Set<BulletListItem> items;

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

  Widget _buildRow(BuildContext context, BulletListItem item) {
    return Padding(
      padding: item == items.last ? insetsZero : insetsBottomSmall,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("\u2022", style: stylePrimary(context)),
          const HorizontalSpace(paddingDefault),
          Expanded(
            child: item.textArg == null
                ? Text(item.text, style: stylePrimary(context))
                : IconLabel(
                    text: item.text,
                    textArg: item.textArg!,
                    textStyle: stylePrimary(context),
                  ),
          ),
        ],
      ),
    );
  }
}

class BulletListItem {
  final String text;
  final Widget? textArg;

  BulletListItem(this.text, [this.textArg]);

  @override
  bool operator ==(Object other) =>
      other is BulletListItem && text == other.text && textArg == other.textArg;

  @override
  int get hashCode => hash2(text.hashCode, textArg.hashCode);
}
