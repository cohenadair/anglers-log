import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';
import '../res/dimen.dart';
import '../res/style.dart';

import 'widget.dart';

/// A widget to be used when some UI blocking work has finished, such as after
/// importing data or subscribing to Anglers' Log Pro.
class WorkResult extends StatelessWidget {
  static const _iconSize = 40.0;

  final String? description;

  final TextStyle Function(BuildContext) _style;
  final IconData _icon;

  const WorkResult.success({
    this.description,
  })  : _style = styleSuccess,
        _icon = Icons.check_circle;

  const WorkResult.error({
    this.description,
  })  : _style = styleError,
        _icon = Icons.error;

  @override
  Widget build(BuildContext context) {
    var style = _style(context);

    Widget descriptionWidget = const Empty();
    if (isNotEmpty(description)) {
      descriptionWidget = Padding(
        padding: insetsTopSmall,
        child: Text(
          description!,
          style: style,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        Icon(
          _icon,
          color: style.color,
          size: _iconSize,
        ),
        descriptionWidget,
      ],
    );
  }
}
