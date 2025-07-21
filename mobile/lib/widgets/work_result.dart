import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../res/style.dart';

/// A widget to be used when some UI blocking work has finished, such as after
/// importing data or subscribing to Anglers' Log Pro.
class WorkResult extends StatelessWidget {
  static const _iconSize = 40.0;

  final String? description;
  final String? descriptionDetail;

  final TextStyle Function(BuildContext) _style;
  final IconData _icon;

  const WorkResult.success({this.description, this.descriptionDetail})
    : _style = styleSuccess,
      _icon = Icons.check_circle;

  const WorkResult.error({this.description, this.descriptionDetail})
    : _style = styleError,
      _icon = Icons.error;

  @override
  Widget build(BuildContext context) {
    var style = _style(context);
    return Column(
      children: [
        Icon(_icon, color: style.color, size: _iconSize),
        _buildDescriptionWidget(description, style),
        _buildDescriptionWidget(
          descriptionDetail,
          styleSecondarySubtext(context),
        ),
      ],
    );
  }

  Widget _buildDescriptionWidget(String? description, TextStyle style) {
    if (isEmpty(description)) {
      return const SizedBox();
    }

    return Padding(
      padding: insetsTopSmall,
      child: Text(description!, style: style, textAlign: TextAlign.center),
    );
  }
}
