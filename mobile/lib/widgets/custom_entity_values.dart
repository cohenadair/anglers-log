import 'package:flutter/material.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/label_value.dart';

class CustomEntityValues extends StatelessWidget {
  final List<CustomEntityValue> values;

  CustomEntityValues(this.values);

  @override
  Widget build(BuildContext context) {
    CustomEntityManager entityManager = CustomEntityManager.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: values.map((value) => _buildWidget(context, entityManager,
          value)).toList(),
    );
  }

  Widget _buildWidget(BuildContext context, CustomEntityManager entityManager,
      CustomEntityValue entityValue)
  {
    CustomEntity entity = entityManager.entity(Id(entityValue.customEntityId));
    var value = valueForCustomEntityType(entity.type, entityValue, context);
    return Padding(
      padding: insetsVerticalWidgetSmall,
      child: LabelValue(
        label: entity.name,
        value: value,
      ),
    );
  }
}