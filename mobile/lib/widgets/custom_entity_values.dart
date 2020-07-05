import 'package:flutter/material.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/model/custom_entity_value.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/input_type.dart';
import 'package:mobile/widgets/text.dart';

class CustomEntityValues extends StatelessWidget {
  /// The maximum length of a value's text before rendering as a title-subtitle
  /// [Column] instead of a [Row].
  static const _textWrapLength = 20;

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
      CustomEntityValue value)
  {
    CustomEntity entity = entityManager.entity(id: value.customEntityId);

    var title = Label(
      entity.name,
      style: TextStyle(
        fontWeight: fontWeightBold,
      ),
    );

    var subtitle;
    switch (entity.type) {
      case InputType.number:
      // Fallthrough.
      case InputType.text:
        subtitle = SecondaryLabel(value.textValue);
        break;
      case InputType.boolean:
        subtitle = SecondaryLabel(value.boolValue
            ? Strings.of(context).yes : Strings.of(context).no);
        break;
    }

    var child;
    if (value.textValue.length > _textWrapLength) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          subtitle,
        ],
      );
    } else {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title,
          subtitle,
        ],
      );
    }

    return Padding(
      padding: insetsVerticalWidgetSmall,
      child: child,
    );
  }
}