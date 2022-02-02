import 'package:flutter/material.dart';
import 'package:mobile/widgets/label_value_list.dart';

import '../custom_entity_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/style.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/label_value.dart';
import '../widgets/widget.dart';

/// A widget that displays a list of [LabelValue] widgets backed by
/// [CustomEntityValue] objects.
class CustomEntityValues extends StatelessWidget {
  final String? title;
  final List<CustomEntityValue> values;
  final bool isSingleLine;
  final EdgeInsets? padding;

  const CustomEntityValues({
    this.title,
    this.values = const [],
    this.isSingleLine = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const Empty();
    }

    var entityManager = CustomEntityManager.of(context);

    if (isSingleLine) {
      return _buildCondensed(context, entityManager);
    }

    return LabelValueList(
      title: title,
      items: _labelValueItems(context, entityManager),
      padding: padding,
    );
  }

  List<LabelValueListItem> _labelValueItems(
      BuildContext context, CustomEntityManager entityManager) {
    var result = <LabelValueListItem>[];
    for (var entityValue in values) {
      var entity = entityManager.entity(entityValue.customEntityId);
      if (entity == null) {
        continue;
      }

      dynamic value =
          valueForCustomEntityType(entity.type, entityValue, context);
      result.add(LabelValueListItem(entity.name, value.toString()));
    }

    return result;
  }

  Widget _buildCondensed(
      BuildContext context, CustomEntityManager entityManager) {
    return Text(
      entityManager.customValuesDisplayValue(values, context),
      style: styleSubtitle(context),
    );
  }
}
