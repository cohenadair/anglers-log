import 'package:adair_flutter_lib/utils/page.dart';
import 'package:flutter/material.dart';

import '../bait_manager.dart';
import '../custom_entity_manager.dart';
import '../model/gen/anglers_log.pb.dart';
import '../pages/bait_variant_page.dart';
import '../pages/save_bait_variant_page.dart';
import 'list_item.dart';
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
    var customEntityManager = CustomEntityManager.of(context);
    var baitManager = BaitManager.of(context);

    VoidCallback onTap;
    if (isEditing) {
      onTap = () {
        present(context, SaveBaitVariantPage.edit(variant, onSave: onSave));
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
      child: ManageableListImageItem(
        imageName: variant.imageName,
        title: title,
        subtitle: customEntityManager.customValuesDisplayValue(
          variant.customEntityValues,
          context,
        ),
        subtitle2: title.contains(variant.description)
            ? null
            : variant.description,
      ),
    );
  }

  bool get _isPicking => onPicked != null;
}
