import 'package:flutter/material.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/model/custom_entity_value.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/input_type.dart';
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
    CustomEntity entity = entityManager.entity(id: entityValue.customEntityId);

    var value;
    switch (entity.type) {
      case InputType.number:
      // Fallthrough.
      case InputType.text:
        value = entityValue.textValue;
        break;
      case InputType.boolean:
        value = entityValue.boolValue
            ? Strings.of(context).yes : Strings.of(context).no;
        break;
    }

    return Padding(
      padding: insetsVerticalWidgetSmall,
      child: LabelValue(
        label: entity.name,
        value: value,
      ),
    );
  }
}