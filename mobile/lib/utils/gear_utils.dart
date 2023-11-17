import 'package:flutter/material.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/utils/catch_utils.dart';

import '../body_of_water_manager.dart';
import '../gps_trail_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/style.dart';
import '../widgets/widget.dart';
import 'protobuf_utils.dart';
import 'string_utils.dart';

class GearListItemModel {
  late final String title;
  late final String? subtitle;

  GearListItemModel(BuildContext context, Gear gear) {
    var gearManager = GearManager.of(context);
    title = gearManager.displayName(context, gear);
    subtitle = formatNumberOfCatches(
        context, gearManager.numberOfCatchQuantities(gear.id));
  }
}
