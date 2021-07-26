import 'package:flutter/material.dart';

import '../custom_entity_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/label_value.dart';
import '../widgets/widget.dart';

/// A widget that displays a list of [LabelValue] widgets backed by
/// [CustomEntityValue] objects.
class CustomEntityValues extends StatelessWidget {
  final List<CustomEntityValue> values;
  final bool isCondensed;

  CustomEntityValues(
    this.values, {
    this.isCondensed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Empty();
    }

    var entityManager = CustomEntityManager.of(context);

    if (isCondensed) {
      return _buildCondensed(context, entityManager);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: values
          .map((value) => _buildExpandedItem(context, entityManager, value))
          .toList(),
    );
  }

  Widget _buildExpandedItem(BuildContext context,
      CustomEntityManager entityManager, CustomEntityValue entityValue) {
    var entity = entityManager.entity(entityValue.customEntityId);
    if (entity == null) {
      return Empty();
    }

    dynamic value = valueForCustomEntityType(entity.type, entityValue, context);
    return Padding(
      padding: insetsVerticalWidgetSmall,
      child: LabelValue(
        label: entity.name,
        value: value,
      ),
    );
  }

  Widget _buildCondensed(
      BuildContext context, CustomEntityManager entityManager) {
    return Text(
      values.fold<String>("", (value, item) {
        var entity = entityManager.entity(item.customEntityId);
        if (entity == null) {
          return value;
        }

        value += "${entity.name}: "
            "${valueForCustomEntityType(entity.type, item, context)}";

        if (item != values.last) {
          value += ", ";
        }

        return value;
      }),
      style: styleSubtitle(context),
    );
  }
}
