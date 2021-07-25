import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../entity_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/bait_category_list_page.dart';
import '../res/dimen.dart';
import '../utils/animated_list_model.dart';
import '../utils/dialog_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/button.dart';
import '../widgets/input_controller.dart';
import '../widgets/list_item.dart';
import '../widgets/list_picker_input.dart';
import '../widgets/text_input.dart';
import '../widgets/widget.dart';
import 'form_page.dart';
import 'manageable_list_page.dart';
import 'save_bait_variant_page.dart';

class SaveBaitPage extends StatefulWidget {
  final Bait? oldBait;

  SaveBaitPage() : oldBait = null;

  SaveBaitPage.edit(this.oldBait);

  @override
  _SaveBaitPageState createState() => _SaveBaitPageState();
}

class _SaveBaitPageState extends State<SaveBaitPage> {
  final _baitCategoryController = IdInputController();
  final _nameController = TextInputController.name();

  final _baitVariantsKey = GlobalKey<AnimatedListState>();
  late AnimatedListModel<BaitVariant, AnimatedListState> _baitVariants;

  Bait? get _oldBait => widget.oldBait;

  bool get _isEditing => _oldBait != null;

  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  @override
  void initState() {
    super.initState();

    var baitVariants = <BaitVariant>[];
    if (_isEditing) {
      _nameController.value = _oldBait!.name;
      _baitCategoryController.value =
          _oldBait!.hasBaitCategoryId() ? _oldBait!.baitCategoryId : null;
      baitVariants = _oldBait!.variants;
    }

    _baitVariants = AnimatedListModel<BaitVariant, AnimatedListState>(
      listKey: _baitVariantsKey,
      initialItems: baitVariants,
      removedItemBuilder: _buildVariantItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      title: _isEditing
          ? Text(Strings.of(context).saveBaitPageEditTitle)
          : Text(Strings.of(context).saveBaitPageNewTitle),
      padding: insetsZero,
      fieldBuilder: (context) => [
        _buildCategory(),
        _buildName(),
        _buildVariants(),
      ],
      onSave: _save,
      isInputValid: _isInputValid,
      runSpacing: 0,
    );
  }

  Widget _buildCategory() {
    return EntityListenerBuilder(
      managers: [_baitCategoryManager],
      builder: (context) {
        var baitCategory =
            _baitCategoryManager.entity(_baitCategoryController.value);
        return ListPickerInput(
          title: Strings.of(context).saveBaitPageCategoryLabel,
          value: baitCategory?.name,
          onTap: () {
            push(
              context,
              BaitCategoryListPage(
                pickerSettings:
                    ManageableListPagePickerSettings<BaitCategory>.single(
                  onPicked: (context, category) {
                    setState(
                        () => _baitCategoryController.value = category?.id);
                    return true;
                  },
                  initialValue: baitCategory,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildName() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.name(
        context,
        controller: _nameController,
        autofocus: true,
        // Trigger "Save" button state refresh.
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildVariants() {
    VoidCallback? onTap;
    if (_isInputValid) {
      onTap = () {
        present(
          context,
          SaveBaitVariantPage(onSave: _addOrUpdateVariant),
        );
      };
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: paddingWidgetSmall,
            bottom: paddingWidget,
          ),
          child: HeadingDivider(
            Strings.of(context).saveBaitPageVariants,
            trailing: MinimumIconButton(
              icon: Icons.add,
              onTap: onTap,
            ),
          ),
        ),
        AnimatedList(
          key: _baitVariantsKey,
          initialItemCount: _baitVariants.length,
          itemBuilder: (context, index, animation) =>
              _buildVariantItem(context, _baitVariants[index], animation),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
        ),
      ],
    );
  }

  Widget _buildVariantItem(
      BuildContext context, BaitVariant variant, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: _BaitVariantListItem(
        variant,
        onAddOrUpdate: _addOrUpdateVariant,
        onConfirmDelete: () => _baitVariants.remove(variant),
      ),
    );
  }

  void _addOrUpdateVariant(BaitVariant? variant) {
    if (variant == null ||
        _baitVariants.items.firstWhereOrNull((e) => variant.isDuplicate(e)) !=
            null) {
      return;
    }

    var index = _baitVariants.items.indexWhere((e) => e.id == variant.id);
    if (index >= 0) {
      _baitVariants.replace(index, variant);
    } else {
      _baitVariants.insert(0, variant);
    }
  }

  FutureOr<bool> _save(BuildContext context) {
    var newBait = Bait()
      ..id = _oldBait?.id ?? randomId()
      ..name = _nameController.value!
      ..variants.addAll(_baitVariants.items);

    if (_baitCategoryController.value != null) {
      newBait.baitCategoryId = _baitCategoryController.value!;
    }

    if (_baitManager.duplicate(newBait)) {
      showErrorDialog(
        context: context,
        description: Text(Strings.of(context).saveBaitPageBaitExists),
      );
      return false;
    }

    _baitManager.addOrUpdate(newBait);
    return true;
  }

  bool get _isInputValid => _nameController.isValid(context);
}

class _BaitVariantListItem extends StatelessWidget {
  final BaitVariant baitVariant;
  final void Function(BaitVariant?)? onAddOrUpdate;

  /// See [ManageableListItem.onConfirmDelete].
  final VoidCallback? onConfirmDelete;

  _BaitVariantListItem(
    this.baitVariant, {
    this.onAddOrUpdate,
    this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ManageableListItem(
      child: Text(baitVariant.color),
      editing: true,
      onTap: () {
        present(
          context,
          SaveBaitVariantPage.edit(
            baitVariant,
            onSave: onAddOrUpdate,
          ),
        );
      },
      // TODO: Need to consider catches with bait variant being deleted.
      deleteMessageBuilder: (context) => Text("TODO"),
      onConfirmDelete: onConfirmDelete ?? () {},
    );
  }
}
