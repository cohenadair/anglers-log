import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

/// A generic picker widget for selecting items from a list. This should be used
/// in place of a [DropdownButton] when there are a lot of options. If multiple,
/// items can be picked, use [MultiListPickerInput].
///
/// If [title] is not provided, [value] is rendered at the beginning of the
/// row, otherwise [title] is rendered at the beginning and [value] is rendered
/// in a different text style at the end of the row.
///
/// A [ListPickerInput] is commonly used with [PickerPage].
class ListPickerInput extends StatelessWidget {
  final String title;
  final String value;
  final bool enabled;
  final VoidCallback onTap;

  ListPickerInput({
    this.title,
    this.value,
    this.enabled = true,
    this.onTap,
  }) : assert(title != null || value != null);

  Widget build(BuildContext context) {
    Widget titleWidget;
    if (title != null) {
      titleWidget = Label(title);
    } else {
      titleWidget = Label(value);
    }

    return EnabledOpacity(
      enabled: enabled,
      child: ListItem(
        contentPadding: enabled ? null : insetsLeftDefault,
        title: titleWidget,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildSingleDetail(context),
            RightChevronIcon(),
          ],
        ),
        onTap: enabled ? onTap : null,
      ),
    );
  }

  Widget _buildSingleDetail(BuildContext context) {
    if (title == null || isEmpty(value)) {
      // If there's no title widget, the value widget will render at the
      // start of the row.
      return Empty();
    }

    return Padding(
      padding: insetsRightWidgetSmall,
      child: SecondaryLabel(value ?? Strings.of(context).inputNotSelected),
    );
  }
}