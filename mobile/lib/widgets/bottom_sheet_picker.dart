import 'package:flutter/material.dart';

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

  BottomSheetPicker({
    this.items = const {},
    this.onPicked,
    this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SwipeChip(),
        ]..addAll(
            items.keys.map((key) => _buildItem(context, key, items[key]))),
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, T? value) {
    return ListItem(
      title: Text(title),
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
