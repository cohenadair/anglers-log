import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/widgets/entity_picker_input.dart';

import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/bait_category_list_page.dart';
import '../res/dimen.dart';
import '../utils/dialog_utils.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/bait_variant_list_input.dart';
import '../widgets/image_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/radio_input.dart';
import '../widgets/text_input.dart';
import 'form_page.dart';
import 'image_picker_page.dart';

class SaveBaitPage extends StatefulWidget {
  final Bait? oldBait;

  const SaveBaitPage() : oldBait = null;

  const SaveBaitPage.edit(this.oldBait);

  @override
  SaveBaitPageState createState() => SaveBaitPageState();
}

class SaveBaitPageState extends State<SaveBaitPage> {
  final _baitCategoryController = IdInputController();
  final _nameController = TextInputController.name();
  final _imageController = InputController<PickedImage>();
  final _typeController = InputController<Bait_Type>();
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
      _typeController.value = _oldBait!.hasType() ? _oldBait!.type : null;
      _variantsController.value = _oldBait!.variants;
    }

    if (!_typeController.hasValue) {
      _typeController.value = Bait_Type.artificial;
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
        _buildType(),
        _buildImage(),
        _buildVariants(),
      ],
      onSave: _save,
      isInputValid: _isInputValid,
      runSpacing: 0,
    );
  }

  Widget _buildCategory() {
    return EntityPickerInput<BaitCategory>.single(
      manager: _baitCategoryManager,
      controller: _baitCategoryController,
      title: Strings.of(context).saveBaitPageCategoryLabel,
      listPage: (settings) => BaitCategoryListPage(pickerSettings: settings),
    );
  }

  Widget _buildName() {
    return Padding(
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingSmall,
      ),
      child: TextInput.name(
        context,
        controller: _nameController,
        autofocus: true,
        // Trigger "Save" button state refresh.
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildType() {
    return RadioInput(
      padding: insetsHorizontalDefaultVerticalSmall,
      initialSelectedIndex: _typeController.value!.value,
      optionCount: Bait_Type.values.length,
      optionBuilder: (context, index) =>
          Bait_Type.values[index].displayName(context),
      onSelect: (selectedIndex) =>
          _typeController.value = Bait_Type.values[selectedIndex],
    );
  }

  Widget _buildImage() {
    return SingleImageInput(
      initialImageName: _oldBait?.imageName,
      controller: _imageController,
    );
  }

  Widget _buildVariants() {
    return BaitVariantListInput(controller: _variantsController);
  }

  FutureOr<bool> _save() {
    // imageName is set in _baitManager.addOrUpdate.
    var newBait = Bait()
      ..id = _oldBait?.id ?? randomId()
      ..name = _nameController.value!;

    newBait.variants.clear();
    newBait.variants.addAll(_variantsController.value);

    if (_baitCategoryController.hasValue) {
      newBait.baitCategoryId = _baitCategoryController.value!;
    }

    if (_typeController.hasValue) {
      newBait.type = _typeController.value!;
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

    File? imageFile;
    if (_imageController.hasValue &&
        _imageController.value!.originalFile != null) {
      imageFile = _imageController.value!.originalFile!;
    }

    _baitManager.addOrUpdate(newBait, imageFile: imageFile);
    return true;
  }

  bool get _isInputValid => _nameController.isValid(context);
}
