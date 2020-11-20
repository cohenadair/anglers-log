import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import '../res/style.dart';
import '../widgets/text.dart';

/// A widget that displays a bold label with a slightly larger and lighter
/// value text. By default, the label and value are displayed in a [Row].
/// If [value] is too long, its [Widget] is rendered below [label] in a
/// [Column].
class LabelValue extends StatelessWidget {
  /// The maximum length of a value's text before rendering as a title-subtitle
  /// [Column] instead of a [Row].
  static const _textWrapLength = 20;

  final String label;
  final String value;
  final EdgeInsets padding;

  LabelValue({
    @required this.label,
    @required this.value,
    this.padding,
  })  : assert(isNotEmpty(label)),
        assert(isNotEmpty(value));

  @override
  Widget build(BuildContext context) {
    var title = Label(
      label,
      style: TextStyle(
        fontWeight: fontWeightBold,
      ),
    );

    var subtitle = SecondaryLabel(value);

    var child;
    if (value.length > _textWrapLength) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          subtitle,
        ],
      );
    } else {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title,
          subtitle,
        ],
      );
    }

    return Padding(
      padding: padding ?? insetsZero,
      child: child,
    );
  }
}
