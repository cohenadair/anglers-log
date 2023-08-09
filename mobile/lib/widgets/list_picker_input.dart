import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../pages/manageable_list_page.dart';
import '../pages/picker_page.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/page_utils.dart';
import '../widgets/radio_input.dart';
import '../widgets/widget.dart';
import 'detail_input.dart';
import 'input_controller.dart';

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
  /// A convenience method for using [ListPickerInput] with a [PickerPage] that
  /// shows a list of enum values of type [T].
  static ListPickerInput withSinglePickerPage<T>({
    required BuildContext context,
    required InputController<T> controller,
    required String title,
    required String pickerTitle,
    required String? valueDisplayName,
    required T noneItem,
    required List<PickerPageItem<T>> Function(BuildContext) itemBuilder,
    required void Function(T?) onPicked,
  }) {
    return ListPickerInput(
      title: title,
      value: valueDisplayName,
      onTap: () {
        push(
          context,
          PickerPage<T>.single(
            title: Text(pickerTitle),
            initialValue: controller.value ?? noneItem,
            itemBuilder: () => itemBuilder(context),
            allItem: PickerPageItem<T>(
              title: Strings.of(context).none,
              value: noneItem,
              onTap: () {
                onPicked(null);
                Navigator.of(context).pop();
              },
            ),
            onFinishedPicking: (context, pickedItem) {
              onPicked(pickedItem);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  final String? title;
  final String? value;

  /// The text shown on the right side of the input view. If null, defaults to
  /// [Strings.of(context).inputNotSelected].
  final String? placeholderText;

  final VoidCallback? onTap;
  final bool isEnabled;

  ListPickerInput({
    this.title,
    this.value,
    this.placeholderText,
    this.onTap,
    this.isEnabled = true,
  }) : assert(isNotEmpty(title) || isNotEmpty(value));

  @override
  Widget build(BuildContext context) {
    String titleText;
    String valueText;
    if (isEmpty(title)) {
      titleText = value!;
      valueText = "";
    } else {
      titleText = title!;
      valueText = isEmpty(value)
          ? (placeholderText ?? Strings.of(context).inputNotSelected)
          : value!;
    }

    Widget titleWidget = Text(
      titleText,
      style: stylePrimary(context),
    );
    Widget valueWidget = Text(
      valueText,
      textAlign: TextAlign.right,
      style: styleSecondary(context),
    );
    if (isEmpty(title)) {
      titleWidget = Expanded(child: titleWidget);
      valueWidget = const Empty();
    } else {
      valueWidget = Expanded(
        child: Padding(
          padding: insetsLeftDefault,
          child: valueWidget,
        ),
      );
    }

    return DetailInput(
      isEnabled: isEnabled,
      onTap: onTap,
      children: [
        titleWidget,
        valueWidget,
      ],
    );
  }
}
