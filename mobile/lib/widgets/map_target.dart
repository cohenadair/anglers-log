import 'package:flutter/material.dart';

import '../res/gen/custom_icons.dart';
import '../utils/map_utils.dart';
import 'widget.dart';

/// A "cross hairs" icon meant to pinpoint a point on the map.
class MapTarget extends StatelessWidget {
  final bool isShowing;
  final MapType? mapType;

  const MapTarget({
    this.isShowing = true,
    this.mapType,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedVisibility(
      visible: isShowing,
      child: Center(
        child: Icon(
          CustomIcons.mapTarget,
          color: mapIconColor(mapType ?? MapType.of(context)),
        ),
      ),
    );
  }
}
