import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../pages/manageable_list_page.dart';
import '../pages/picker_page.dart';
import '../res/dimen.dart';
import '../widgets/radio_input.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';

/// A generic picker widget for selecting items from a list. This should be used
/// in place of a [RadioInput] when there are a lot of options. If multiple,
/// items can be picked, use [MultiListPickerInput].
///
/// If [title] is not provided, [value] is rendered at the beginning of the
/// row, otherwise [title] is rendered at the beginning and [value] is rendered
/// in a different text style at the end of the row.
///
/// A [ListPickerInput] is commonly used with [PickerPage] or
/// [ManageableListPage].
class ListPickerInput extends StatelessWidget {
  final String? title;
  final String? value;
  final VoidCallback? onTap;

  ListPickerInput({
    this.title,
    this.value,
    this.onTap,
  }) : assert(isNotEmpty(title) || isNotEmpty(value));

  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: insetsDefault,
        child: HorizontalSafeArea(
          child: Row(
            children: [
              PrimaryLabel(isEmpty(title) ? value! : title!),
              Expanded(
                // If there's no title widget, the value widget will render at
                // the start of the row.
                child: isEmpty(title)
                    ? Empty()
                    : SecondaryLabel(
                        isEmpty(value)
                            ? Strings.of(context).inputNotSelected
                            : value!,
                        align: TextAlign.right,
                      ),
              ),
              Padding(
                padding: insetsLeftWidgetSmall,
                child: RightChevronIcon(),
              ),
            ],
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
