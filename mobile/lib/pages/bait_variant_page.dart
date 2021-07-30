import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../bait_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/custom_entity_values.dart';
import '../widgets/label_value.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';
import 'entity_page.dart';

class BaitVariantPage extends StatelessWidget {
  final BaitVariant variant;

  BaitVariantPage(this.variant);

  @override
  Widget build(BuildContext context) {
    return EntityPage(
      static: true,
      padding: insetsZero,
      children: [
        VerticalSpace(paddingDefault),
        _buildBase(context),
        _buildColor(context),
        _buildModel(context),
        _buildSize(context),
        _buildDiveDepth(context),
        _buildCustomEntityValues(context),
        _buildDescription(context),
      ],
    );
  }

  Widget _buildBase(BuildContext context) {
    var name = BaitManager.of(context).formatNameWithCategory(variant.baseId);
    if (isEmpty(name)) {
      return Empty();
    }

    return Padding(
      padding: insetsBottomWidget,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: insetsHorizontalDefault,
            child: Text(
              Strings.of(context).baitVariantPageVariantLabel,
              style: styleListHeading(context),
            ),
          ),
          TitleLabel(
            name!,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }

  Widget _buildLabelValue(BuildContext context, String label, String? value) {
    if (isEmpty(value)) {
      return Empty();
    }
    return LabelValue(
      label: label,
      value: value!,
    );
  }

  Widget _buildColor(BuildContext context) {
    return _buildLabelValue(
        context, Strings.of(context).inputColorLabel, variant.color);
  }

  Widget _buildModel(BuildContext context) {
    return _buildLabelValue(
        context, Strings.of(context).baitVariantPageModel, variant.modelNumber);
  }

  Widget _buildSize(BuildContext context) {
    return _buildLabelValue(
        context, Strings.of(context).baitVariantPageSize, variant.size);
  }

  Widget _buildDiveDepth(BuildContext context) {
    return _buildLabelValue(context, Strings.of(context).baitVariantPageModel,
        variant.diveDepthDisplayValue(context));
  }

  Widget _buildCustomEntityValues(BuildContext context) {
    return CustomEntityValues(variant.customEntityValues);
  }

  Widget _buildDescription(BuildContext context) {
    return _buildLabelValue(context, Strings.of(context).inputDescriptionLabel,
        variant.description);
  }
}
