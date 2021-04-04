import 'package:flutter/material.dart';

import '../custom_entity_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/label_value.dart';
import '../widgets/widget.dart';

/// A widget that displays a list of [LabelValue] widgets backed by
/// [CustomEntityValue] objects.
class CustomEntityValues extends StatelessWidget {
  final List<CustomEntityValue> values;

  CustomEntityValues(this.values);

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Empty();
    }

    var entityManager = CustomEntityManager.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: values
          .map((value) => _buildWidget(context, entityManager, value))
          .toList(),
    );
  }

  Widget _buildWidget(BuildContext context, CustomEntityManager entityManager,
      CustomEntityValue entityValue) {
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
}
