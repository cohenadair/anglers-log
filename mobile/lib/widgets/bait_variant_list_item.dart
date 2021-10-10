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
  final bool isPicking;
  final VoidCallback? onDelete;
  final void Function(BaitVariant)? onSave;

  const BaitVariantListItem(
    this.variant, {
    this.trailing,
    this.isEditing = false,
    this.isCondensed = false,
    this.isPicking = false,
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

    var title = baitManager.variantDisplayValue(variant, context);

    return ManageableListItem(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleLineText(
            title,
            style: stylePrimary(context),
          ),
          CustomEntityValues(
            variant.customEntityValues,
            isCondensed: true,
          ),
          // Only show a separate description line if the description isn't
          // already present in the title.
          SingleLineText(
            title.contains(variant.description) ? null : variant.description,
            style: styleSubtitle(context),
          ),
        ],
      ),
      editing: isEditing,
      onTap: isPicking ? null : onTap,
      deleteMessageBuilder: (context) =>
          Text(baitManager.deleteVariantMessage(context, variant)),
      onConfirmDelete: onDelete ?? () {},
      isCondensed: isCondensed,
      trailing: trailing ?? RightChevronIcon(),
    );
  }
}
