import 'package:flutter/material.dart';
import '../res/dimen.dart';
import '../res/style.dart';

import 'widget.dart';

/// A widget to be used when some UI blocking work has finished, such as after
/// importing data or subscribing to Anglers' Log Pro.
class WorkResult extends StatelessWidget {
  static const _iconSize = 40.0;

  final String description;

  final TextStyle _style;
  final IconData _icon;

  WorkResult.success(this.description)
      : _style = styleSuccess,
        _icon = Icons.check_circle;

  WorkResult.error(this.description)
      : _style = styleError,
        _icon = Icons.error;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          _icon,
          color: _style.color,
          size: _iconSize,
        ),
        VerticalSpace(paddingWidgetSmall),
        Text(
          description,
          style: styleSuccess,
        ),
      ],
    );
  }
}
