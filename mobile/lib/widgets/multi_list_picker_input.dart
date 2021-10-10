import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../widgets/list_picker_input.dart';
import '../widgets/widget.dart';
import 'detail_input.dart';

/// A generic picker widget for selecting multiple items from a list. For
/// selecting only a single item, use [ListPickerInput].
///
/// This widget should not be used with a title widget such as [HeadingLabel].
/// The [emptyValue] property should be descriptive enough to clearly show
/// the [MultiListPickerInput]'s purpose.
class MultiListPickerInput extends StatelessWidget {
  final Set<String> values;
  final VoidCallback onTap;
  final EdgeInsets? padding;

  /// The text that is displayed when no items are selected.
  final LocalizedString emptyValue;

  const MultiListPickerInput({
    required this.values,
    this.padding,
    required this.emptyValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var items = <String>{};
    if (values.isEmpty) {
      items.add(emptyValue(context));
    } else {
      for (var value in values) {
        if (isEmpty(value)) {
          continue;
        }
        items.add(value);
      }
    }

    return DetailInput(
      onTap: onTap,
      padding: padding,
      children: [
        Expanded(child: ChipWrap(items)),
      ],
    );
  }
}
