import 'package:flutter/material.dart';

import '../bait_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/bait_variant_page.dart';
import '../pages/save_bait_variant_page.dart';
import '../res/style.dart';
import '../utils/page_utils.dart';
import 'custom_entity_values.dart';
import 'list_item.dart';
import 'text.dart';
import 'widget.dart';

class BaitVariantListItem extends StatelessWidget {
  final BaitVariant variant;
  final Widget? trailing;
  final bool isEditing;
  final bool isCondensed;
  final void Function(BaitVariant)? onPicked;
  final VoidCallback? onDelete;
  final void Function(BaitVariant)? onSave;

  const BaitVariantListItem(
    this.variant, {
    this.trailing,
    this.isEditing = false,
    this.isCondensed = false,
    this.onPicked,
    this.onDelete,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    var baitManager = BaitManager.of(context);

    VoidCallback onTap;
    if (isEditing) {
      onTap = () {
        present(
          context,
          SaveBaitVariantPage.edit(
            variant,
            onSave: onSave,
          ),
        );
      };
    } else {
      onTap = () => push(context, BaitVariantPage(variant));
    }

    var title = baitManager.variantDisplayValue(context, variant);

    return ManageableListItem(
      editing: isEditing,
      onTap: () => _isPicking ? onPicked!.call(variant) : onTap(),
      deleteMessageBuilder: (context) =>
          Text(baitManager.deleteVariantMessage(context, variant)),
      onConfirmDelete: onDelete ?? () {},
      isCondensed: isCondensed,
      trailing: trailing ?? (_isPicking ? null : RightChevronIcon()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleLineText(
            title,
            style: stylePrimary(context),
          ),
          CustomEntityValues(
            values: variant.customEntityValues,
            isSingleLine: true,
          ),
          // Only show a separate description line if the description isn't
          // already present in the title.
          SingleLineText(
            title.contains(variant.description) ? null : variant.description,
            style: styleSubtitle(context),
          ),
        ],
      ),
    );
  }

  bool get _isPicking => onPicked != null;
}
