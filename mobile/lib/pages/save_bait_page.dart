import 'dart:async';

import 'package:flutter/material.dart';

import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../entity_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/bait_category_list_page.dart';
import '../res/dimen.dart';
import '../utils/dialog_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/bait_variant_list_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/list_picker_input.dart';
import '../widgets/text_input.dart';
import 'form_page.dart';
import 'manageable_list_page.dart';

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
  final _variantsController = ListInputController<BaitVariant>();

  Bait? get _oldBait => widget.oldBait;

  bool get _isEditing => _oldBait != null;

  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _nameController.value = _oldBait!.name;
      _baitCategoryController.value =
          _oldBait!.hasBaitCategoryId() ? _oldBait!.baitCategoryId : null;
      _variantsController.value = _oldBait!.variants;
    }
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
        // TODO: Add remaining fields
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
    return Padding(
      padding: insetsTopWidget,
      child: BaitVariantListInput(controller: _variantsController),
    );
  }

  FutureOr<bool> _save(BuildContext context) {
    var newBait = Bait()
      ..id = _oldBait?.id ?? randomId()
      ..name = _nameController.value!;

    newBait.variants.clear();
    newBait.variants.addAll(_variantsController.value);

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

    // Set variant baseId only when validation as passed.
    for (var variant in newBait.variants) {
      variant.baseId = newBait.id;
    }

    _baitManager.addOrUpdate(newBait);
    return true;
  }

  bool get _isInputValid => _nameController.isValid(context);
}
