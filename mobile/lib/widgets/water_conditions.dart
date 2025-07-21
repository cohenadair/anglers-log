import 'package:flutter/material.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/widget.dart';

import '../model/gen/anglers_log.pb.dart';
import '../water_clarity_manager.dart';
import 'list_item.dart';

class WaterConditions extends StatelessWidget {
  /// Must be a proto class that includes [water_temperature], [water_depth],
  /// and [water_clarity_id] fields.
  final dynamic entity;

  const WaterConditions(this.entity);

  @override
  Widget build(BuildContext context) {
    var waterValues = <String>[];

    var clarity = WaterClarityManager.of(context).entity(entity.waterClarityId);
    if (clarity != null) {
      waterValues.add(clarity.name);
    }

    if (entity.hasWaterTemperature()) {
      waterValues.add(
        (entity.waterTemperature as MultiMeasurement).displayValue(context),
      );
    }

    if (entity.hasWaterDepth()) {
      waterValues.add(
        (entity.waterDepth as MultiMeasurement).displayValue(context),
      );
    }

    if (waterValues.isEmpty) {
      return const SizedBox();
    }

    return ListItem(
      leading: const GreyAccentIcon(iconWaterClarity),
      title: Text(waterValues.join(", ")),
    );
  }
}
