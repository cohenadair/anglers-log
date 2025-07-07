import 'package:flutter/material.dart';

import '../body_of_water_manager.dart';
import '../gps_trail_manager.dart';
import '../model/gen/anglers_log.pb.dart';
import '../res/style.dart';
import '../utils/string_utils.dart';
import '../widgets/widget.dart';
import 'protobuf_utils.dart';

class GpsTrailListItemModel {
  late final String title;
  late final String? subtitle;
  late final TextStyle? subtitleStyle;
  late final Widget trailing;

  GpsTrailListItemModel(BuildContext context, GpsTrail trail) {
    var bodyOfWaterManager = BodyOfWaterManager.of(context);
    var gpsTrailManager = GpsTrailManager.of(context);

    var subtitle =
        bodyOfWaterManager.displayNameFromId(context, trail.bodyOfWaterId);
    TextStyle? subtitleStyle;
    if (trail.isInProgress) {
      subtitle = Strings.of(context).gpsTrailListPageInProgress;
      subtitleStyle = styleSuccess(context)
          .copyWith(fontSize: styleSubtitle(context).fontSize);
    }

    title = gpsTrailManager.displayName(context, trail);
    this.subtitle = subtitle;
    this.subtitleStyle = subtitleStyle;
    trailing = MinChip(Strings.of(context)
        .gpsTrailListPageNumberOfPoints(trail.points.length));
  }
}
