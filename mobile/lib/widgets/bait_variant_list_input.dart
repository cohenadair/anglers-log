import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:quiver/collection.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/save_bait_variant_page.dart';
import '../res/dimen.dart';
import '../utils/animated_list_model.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import 'animated_list_transition.dart';
import 'bait_variant_list_item.dart';
import 'button.dart';
import 'checkbox_input.dart';
import 'input_controller.dart';
import 'widget.dart';

class BaitVariantListInput extends StatefulWidget {
  final void Function(BaitVariant?)? onSave;
  final ListInputController<BaitVariant> controller;
  final EdgeInsets? padding;
  final bool isEditing;
  final bool isCondensed;
  final bool showHeader;

  final void Function(BaitVariant, bool)? onCheckboxChanged;
  final Set<BaitVariant> selectedItems;

  BaitVariantListInput({
    required this.controller,
    this.onSave,
    this.onCheckboxChanged,
    this.padding,
    this.isEditing = true,
    this.isCondensed = false,
    this.showHeader = true,
    this.selectedItems = const {},
  });

  BaitVariantListInput.static(
    List<BaitVariant> items, {
    bool showHeader = true,
    bool isCondensed = false,
    EdgeInsets? padding,
    void Function(BaitVariant, bool)? onCheckboxChanged,
    Set<BaitVariant> selectedItems = const {},
  }) : this(
          controller: ListInputController<BaitVariant>()..value = items,
          isEditing: false,
          isCondensed: isCondensed,
          showHeader: showHeader,
          padding: padding,
          onCheckboxChanged: onCheckboxChanged,
          selectedItems: selectedItems,
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

    Widget header = Empty();
    if (widget.showHeader) {
      header = Padding(
        padding: insetsBottomWidget,
        child: HeadingDivider(
          Strings.of(context).saveBaitPageVariants,
          trailing: headerTrailing,
        ),
      );
    }

    return Column(
      children: [
        header,
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
    Widget? trailing;
    if (widget.onCheckboxChanged != null) {
      trailing = PaddedCheckbox(
        onChanged: (isChecked) => widget.onCheckboxChanged!(variant, isChecked),
        checked: widget.selectedItems.contains(variant),
      );
    }

    return AnimatedListTransition(
      animation: animation,
      child: BaitVariantListItem(
        variant,
        trailing: trailing,
        isEditing: widget.isEditing,
        isCondensed: widget.isCondensed,
        onDelete: () => _items.remove(variant),
        onSave: _onAddOrUpdate,
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
