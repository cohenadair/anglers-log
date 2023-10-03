import 'package:flutter/material.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import '../res/style.dart';

/// A widget that displays a primary label with a secondary label value text.
/// By default, the label and value are displayed in a [Row]. If [value] is
/// too long, its [Widget] is rendered below [label] in a [Column].
class LabelValue extends StatelessWidget {
  /// The maximum length of a value's text before rendering as a title-subtitle
  /// [Column] instead of a [Row].
  static const _textWrapLength = 30;

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final EdgeInsets? padding;

  LabelValue({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.padding,
  })  : assert(isNotEmpty(label)),
        assert(isNotEmpty(value));

  @override
  Widget build(BuildContext context) {
    var title = Text(
      label,
      style: labelStyle ?? stylePrimary(context),
    );

    var subtitle = Text(
      value,
      style: valueStyle ?? styleSecondary(context),
    );

    Widget child;
    if (value.length > _textWrapLength) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: insetsBottomSmall,
            child: title,
          ),
          subtitle,
        ],
      );
    } else {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: title),
          const HorizontalSpace(paddingDefault),
          subtitle,
        ],
      );
    }

    return Padding(
      padding: padding ?? insetsDefault,
      child: child,
    );
  }
}
