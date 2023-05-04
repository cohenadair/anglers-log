import 'package:flutter/material.dart';

import 'our_bottom_sheet.dart';
import 'list_item.dart';
import 'widget.dart';

class BottomSheetPicker<T> extends StatelessWidget {
  final void Function(T?)? onPicked;
  final T? currentValue;
  final Map<String, T> items;
  final String? title;
  final TextStyle? itemStyle;
  final Widget? footer;

  const BottomSheetPicker({
    this.items = const {},
    this.onPicked,
    this.currentValue,
    this.title,
    this.itemStyle,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return OurBottomSheet(
      title: title,
      children: [
        ...items.keys.map((key) => _buildItem(context, key, items[key])),
        footer ?? const Empty()
      ],
    );
  }

  Widget _buildItem(BuildContext context, String title, T? value) {
    Widget titleWidget = Text(title);
    if (itemStyle != null) {
      titleWidget = Text(title, style: itemStyle);
    }

    return ListItem(
      title: titleWidget,
      trailing: Visibility(
        visible: currentValue != null && currentValue == value,
        child: const ItemSelectedIcon(),
      ),
      onTap: () {
        Navigator.pop(context);
        onPicked?.call(value);
      },
    );
  }
}
