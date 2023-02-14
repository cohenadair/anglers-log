import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:quiver/strings.dart';

import '../custom_entity_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../utils/protobuf_utils.dart';
import '../utils/validator.dart';
import '../widgets/input_controller.dart';
import '../widgets/input_type.dart';
import '../widgets/radio_input.dart';
import '../widgets/text_input.dart';
import 'form_page.dart';

/// A input page for users to create custom fields to be used elsewhere in the
/// app. This form is immutable.
class SaveCustomEntityPage extends StatefulWidget {
  final CustomEntity? oldEntity;
  final void Function(CustomEntity)? onSave;

  const SaveCustomEntityPage({
    this.onSave,
  }) : oldEntity = null;

  const SaveCustomEntityPage.edit(
    CustomEntity this.oldEntity, {
    this.onSave,
  });

  @override
  SaveCustomEntityPageState createState() => SaveCustomEntityPageState();
}

class SaveCustomEntityPageState extends State<SaveCustomEntityPage> {
  late final TextInputController _nameController;
  final _descriptionController = TextInputController();
  final _dataTypeController = InputController<CustomEntity_Type>();

  CustomEntityManager get _customEntityManager =>
      CustomEntityManager.of(context);

  CustomEntity? get _oldEntity => widget.oldEntity;

  bool get _editing => _oldEntity != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextInputController(
      validator: NameValidator(
        nameExistsMessage: (context) =>
            Strings.of(context).saveCustomEntityPageNameExists,
        nameExists: _customEntityManager.nameExists,
        oldName: _oldEntity?.name,
      ),
    );

    if (_editing) {
      _nameController.value = _oldEntity!.name;
      _descriptionController.value = _oldEntity!.description;
      _dataTypeController.value = _oldEntity!.type;
    } else {
      _dataTypeController.value = CustomEntity_Type.number;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      title: _editing
          ? Text(Strings.of(context).saveCustomEntityPageEditTitle)
          : Text(Strings.of(context).saveCustomEntityPageNewTitle),
      padding: insetsZero,
      fieldBuilder: (context) => [
        Padding(
          padding: insetsHorizontalDefault,
          child: TextInput.name(
            context,
            controller: _nameController,
            autofocus: true,
            textInputAction: TextInputAction.next,
            // Trigger "Save" button state refresh.
            onChanged: (_) => setState(() {}),
          ),
        ),
        Padding(
          padding: insetsHorizontalDefault,
          child: TextInput.description(
            context,
            controller: _descriptionController,
          ),
        ),
        RadioInput(
          padding: insetsHorizontalDefault,
          initialSelectedIndex:
              CustomEntity_Type.values.indexOf(_dataTypeController.value!),
          optionCount: CustomEntity_Type.values.length,
          optionBuilder: (context, i) =>
              inputTypeLocalizedString(context, CustomEntity_Type.values[i]),
          onSelect: (i) => setState(() {
            _dataTypeController.value = CustomEntity_Type.values[i];
          }),
        ),
      ],
      onSave: _save,
      isInputValid: _nameController.isValid(context),
    );
  }

  FutureOr<bool> _save() {
    var customEntity = CustomEntity()
      ..id = _oldEntity?.id ?? randomId()
      ..name = _nameController.value!
      ..type = _dataTypeController.value!;

    if (isNotEmpty(_descriptionController.value)) {
      customEntity.description = _descriptionController.value!;
    }

    _customEntityManager.addOrUpdate(customEntity);
    widget.onSave?.call(customEntity);
    return true;
  }
}
