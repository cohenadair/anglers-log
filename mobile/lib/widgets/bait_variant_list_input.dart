import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:quiver/collection.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/save_bait_variant_page.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/animated_list_model.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import 'animated_list_transition.dart';
import 'button.dart';
import 'custom_entity_values.dart';
import 'input_controller.dart';
import 'list_item.dart';
import 'widget.dart';

class BaitVariantListInput extends StatefulWidget {
  final void Function(BaitVariant?)? onSave;
  final ListInputController<BaitVariant> controller;
  final bool isEditing;

  BaitVariantListInput({
    required this.controller,
    this.onSave,
    this.isEditing = true,
  });

  BaitVariantListInput.static(List<BaitVariant> items)
      : this(
          controller: ListInputController<BaitVariant>()..value = items,
          isEditing: false,
        );

  @override
  _BaitVariantListInputState createState() => _BaitVariantListInputState();
}

class _BaitVariantListInputState extends State<BaitVariantListInput> {
  final _key = GlobalKey<AnimatedListState>();
  late AnimatedListModel<BaitVariant, AnimatedListState> _items;

  @override
  void initState() {
    super.initState();

    _items = AnimatedListModel<BaitVariant, AnimatedListState>(
      listKey: _key,
      controller: widget.controller,
      initialItems: widget.controller.value,
      removedItemBuilder: _buildItem,
    );
  }

  @override
  void didUpdateWidget(BaitVariantListInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listsEqual(_items.items, widget.controller.value)) {
      _items.resetItems(widget.controller.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget headerTrailing = Empty();
    if (widget.isEditing) {
      headerTrailing = MinimumIconButton(
        icon: Icons.add,
        onTap: () {
          present(
            context,
            SaveBaitVariantPage(onSave: _onAddOrUpdate),
          );
        },
      );
    }

    return Column(
      children: [
        Padding(
          padding: insetsBottomWidget,
          child: HeadingDivider(
            Strings.of(context).saveBaitPageVariants,
            trailing: headerTrailing,
          ),
        ),
        AnimatedList(
          key: _key,
          initialItemCount: _items.length,
          itemBuilder: (context, index, animation) =>
              _buildItem(context, _items[index], animation),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
        ),
      ],
    );
  }

  Widget _buildItem(
      BuildContext context, BaitVariant variant, Animation<double> animation) {
    VoidCallback? onTap;
    if (widget.isEditing) {
      onTap = () {
        present(
          context,
          SaveBaitVariantPage.edit(
            variant,
            onSave: _onAddOrUpdate,
          ),
        );
      };
    }

    return AnimatedListTransition(
      animation: animation,
      child: ManageableListItem(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              variant.color,
              style: stylePrimary(context),
            ),
            CustomEntityValues(variant.customEntityValues, isCondensed: true),
          ],
        ),
        editing: widget.isEditing,
        onTap: onTap,
        // TODO: Need to consider catches with bait variant being deleted.
        deleteMessageBuilder: (context) => Text("TODO"),
        onConfirmDelete: () => _items.remove(variant),
      ),
    );
  }

  void _onAddOrUpdate(BaitVariant? variant) {
    if (variant == null ||
        _items.items.firstWhereOrNull((e) => variant.isDuplicate(e)) != null) {
      return;
    }

    var index = _items.items.indexWhere((e) => e.id == variant.id);
    if (index >= 0) {
      _items.replace(index, variant);
    } else {
      _items.insert(0, variant);
    }
  }
}
