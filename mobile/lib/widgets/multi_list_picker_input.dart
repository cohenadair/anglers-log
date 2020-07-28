import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

/// A generic picker widget for selecting multiple items from a list. For
/// selecting only a single item, use [ListPickerInput].
class MultiListPickerInput extends StatelessWidget {
  final String title;
  final Set<String> values;
  final VoidCallback onTap;
  final EdgeInsets padding;

  /// The text that is displayed when no items are selected.
  final String Function(BuildContext) emptyValue;

  MultiListPickerInput({
    this.title,
    this.values,
    this.padding,
    @required this.emptyValue,
    @required this.onTap,
  }) : assert(emptyValue != null),
       assert(onTap != null);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (isNotEmpty(title)) {
      children.add(Padding(
        padding: EdgeInsets.only(
          left: padding?.left ?? 0,
          right: padding?.right ?? 0,
          bottom: paddingWidgetSmall
        ),
        child: HeadingLabel(title),
      ));
    }

    List<Widget> chips = [];
    if (values == null || values.isEmpty) {
      chips.add(_chip(emptyValue(context)));
    } else {
      for (String value in values) {
        chips.add(_chip(value));
      }
    }

    children.add(InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: padding?.left ?? 0,
          right: padding?.right ?? 0,
          top: paddingWidgetSmall,
          bottom: paddingWidgetSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Wrap(
                spacing: paddingWidgetSmall,
                runSpacing: paddingWidgetSmall,
                children: chips,
              ),
            ),
            RightChevronIcon(),
          ],
        ),
      ),
    ));

    return Padding(
      padding: EdgeInsets.only(
        top: padding?.top ?? 0,
        bottom: padding?.bottom ?? 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _chip(String label) {
    return Chip(
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}