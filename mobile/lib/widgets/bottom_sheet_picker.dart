import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import '../res/style.dart';
import 'list_item.dart';
import 'widget.dart';

Future<void> showBottomSheetPicker(
    BuildContext context, BottomSheetPicker Function(BuildContext) builder) {
  return showModalBottomSheet<void>(
    isScrollControlled: true,
    useRootNavigator: true,
    context: context,
    builder: builder,
  );
}

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
    Widget titleWidget = Empty();
    if (isNotEmpty(title)) {
      titleWidget = Padding(
        padding: insetsDefault,
        child: Text(
          title!,
          style: styleHeadingSmall,
        ),
      );
    }

    return SafeArea(
      bottom: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: SwipeChip(),
          ),
          titleWidget,
          ...items.keys.map((key) => _buildItem(context, key, items[key])),
          footer ?? Empty()
        ],
      ),
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
        child: Icon(
          Icons.check,
          color: Theme.of(context).primaryColor,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onPicked?.call(value);
      },
    );
  }
}
