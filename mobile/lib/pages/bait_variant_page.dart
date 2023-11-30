import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../bait_manager.dart';
import '../entity_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/custom_entity_values.dart';
import '../widgets/label_value.dart';
import '../widgets/list_item.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';
import 'bait_page.dart';
import 'entity_page.dart';

class BaitVariantPage extends StatefulWidget {
  final BaitVariant variant;

  /// When true, allows users to view the base [Bait] object. This should only
  /// be set to true when a [BaitVariantPage] is not displayed from a
  /// [BaitPage], otherwise an infinite number of pages can be pushed on to the
  /// navigation stack.
  final bool allowBaseViewing;

  const BaitVariantPage(
    this.variant, {
    this.allowBaseViewing = false,
  });

  @override
  BaitVariantPageState createState() => BaitVariantPageState();
}

class BaitVariantPageState extends State<BaitVariantPage> {
  Bait? _bait;
  late BaitVariant _variant;

  BaitManager get _baitManager => BaitManager.of(context);

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [
        _baitManager,
      ],
      builder: (context) {
        // Always fetch latest values.
        _bait = _baitManager.entity(widget.variant.baseId);
        _variant = _bait == null
            ? widget.variant
            : _baitManager.variant(_bait!, widget.variant.id) ?? widget.variant;

        return EntityPage(
          isStatic: true,
          padding: insetsZero,
          children: [
            _buildBase(),
            _buildColor(),
            _buildModel(),
            _buildSize(),
            _buildDiveDepth(),
            _buildCustomEntityValues(),
            _buildDescription(),
          ],
        );
      },
    );
  }

  Widget _buildBase() {
    var name = _baitManager.formatNameWithCategory(_variant.baseId);
    if (isEmpty(name)) {
      return const Empty();
    }

    VoidCallback? onTap;
    Widget? trailing;
    if (_bait != null && widget.allowBaseViewing) {
      onTap = () => push(context, BaitPage(_bait!));
      trailing = RightChevronIcon();
    }

    return ListItem(
      padding: const EdgeInsets.only(
        right: paddingDefault,
        top: paddingDefault,
        bottom: paddingDefault,
      ),
      title: Padding(
        padding: insetsHorizontalDefault,
        child: Text(
          Strings.of(context).baitVariantPageVariantLabel,
          style: styleListHeading(context),
        ),
      ),
      subtitle: TitleLabel.style1(
        name!,
        overflow: TextOverflow.visible,
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildLabelValue(String label, String? value) {
    if (isEmpty(value)) {
      return const Empty();
    }

    return LabelValue(
      label: label,
      value: value!,
    );
  }

  Widget _buildColor() {
    return _buildLabelValue(
        Strings.of(context).inputColorLabel, _variant.color);
  }

  Widget _buildModel() {
    return _buildLabelValue(
        Strings.of(context).baitVariantPageModel, _variant.modelNumber);
  }

  Widget _buildSize() {
    return _buildLabelValue(
        Strings.of(context).baitVariantPageSize, _variant.size);
  }

  Widget _buildDiveDepth() {
    return _buildLabelValue(Strings.of(context).baitVariantPageDiveDepth,
        _variant.diveDepthDisplayValue(context));
  }

  Widget _buildCustomEntityValues() {
    return CustomEntityValues(values: _variant.customEntityValues);
  }

  Widget _buildDescription() {
    return _buildLabelValue(
        Strings.of(context).inputDescriptionLabel, _variant.description);
  }
}
