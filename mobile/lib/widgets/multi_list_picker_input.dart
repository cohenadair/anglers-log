import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

/// A generic picker widget for selecting multiple items from a list. For
/// selecting only a single item, use [ListPickerInput].
///
/// This widget should not be used with a title widget such as [HeadingLabel].
/// The [emptyValue] property should be descriptive enough to clearly show
/// what the [MultiListPickerInput] is for.
class MultiListPickerInput extends StatelessWidget {
  final Set<String> values;
  final VoidCallback onTap;
  final EdgeInsets padding;

  /// The text that is displayed when no items are selected.
  final String Function(BuildContext) emptyValue;

  MultiListPickerInput({
    this.values,
    this.padding,
    @required this.emptyValue,
    @required this.onTap,
  }) : assert(emptyValue != null),
       assert(onTap != null);

  @override
  Widget build(BuildContext context) {
    Set<String> items = {};
    if (values == null || values.isEmpty) {
      items.add(emptyValue(context));
    } else {
      for (String value in values) {
        items.add(value);
      }
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding ?? insetsZero,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ChipWrap(items)
            ),
            RightChevronIcon(),
          ],
        ),
      ),
    );
  }
}