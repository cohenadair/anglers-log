import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/utils/validator.dart';
import 'package:mobile/widgets/dropdown_input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/input_type.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

import 'form_page.dart';

/// A input page for users to create custom fields to be used elsewhere in the
/// app. This form is immutable.
class SaveCustomEntityPage extends StatefulWidget {
  final CustomEntity oldEntity;
  final void Function(CustomEntity) onSave;

  SaveCustomEntityPage({
    this.onSave,
  }) : oldEntity = null;

  SaveCustomEntityPage.edit(this.oldEntity, {
    this.onSave,
  }) : assert(oldEntity != null);

  @override
  _SaveCustomEntityPageState createState() => _SaveCustomEntityPageState();
}

class _SaveCustomEntityPageState extends State<SaveCustomEntityPage> {
  static const String _nameId = "name";
  static const String _descriptionId = "description";
  static const String _dataTypeId = "dataType";

  final Log _log = Log("SaveCustomEntityPage");

  final Map<String, InputController> _inputOptions = {
    _nameId: TextInputController(
      validate: (context) => Strings.of(context).inputGenericRequired,
    ),
    _descriptionId: TextInputController(),
    _dataTypeId: InputController<InputType>(
      value: InputType.number,
    ),
  };

  TextInputController get _nameController =>
      _inputOptions[_nameId] as TextInputController;

  TextInputController get _descriptionController =>
      _inputOptions[_descriptionId] as TextInputController;

  InputController<InputType> get _dataTypeController =>
      _inputOptions[_dataTypeId] as InputController<InputType>;

  bool get _editing => widget.oldEntity != null;

  @override
  void initState() {
    super.initState();

    if (_editing) {
      // If editing an entity, the name will be set, and therefore, valid.
      _nameController.validate = null;
      _nameController.value = widget.oldEntity.name;

      _descriptionController.value = widget.oldEntity.description;
      _dataTypeController.value = widget.oldEntity.type ?? InputType.number;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      title: _editing
          ? Text(Strings.of(context).saveCustomEntityPageEditTitle)
          : Text(Strings.of(context).saveCustomEntityPageNewTitle),
      fieldBuilder: (BuildContext context) {
        return Map.fromIterable(_inputOptions.keys,
          key: (dynamic item) => item.toString(),
          value: (dynamic item) => _inputField(context, item.toString()),
        );
      },
      onSave: _save,
      isInputValid: isEmpty(_nameController.error(context)),
    );
  }

  Widget _inputField(BuildContext context, String key) {
    switch (key) {
      case _nameId: return TextInput.name(
        context,
        controller: _nameController,
        autofocus: true,
        validator: NameValidator(
          nameExistsMessage: Strings.of(context).saveCustomEntityPageNameExists,
          nameExists: CustomEntityManager.of(context).nameExists,
          oldName: widget.oldEntity?.name,
        ),
        // Trigger "Save" button state refresh.
        onChanged: () => setState(() {}),
      );
      case _descriptionId: return TextInput.description(
        context,
        controller: _descriptionController,
      );
      case _dataTypeId: return DropdownInput<InputType>(
        options: InputType.values,
        value: _dataTypeController.value,
        buildOption: (InputType type) =>
            Text(inputTypeLocalizedString(context, type)),
        onChanged: (InputType newType) {
          setState(() {
            _dataTypeController.value = newType;
          });
        },
      );
      default: _log.e("Unknown key: $key");
    }

    return Empty();
  }

  FutureOr<bool> _save(BuildContext _) {
    var customField = CustomEntity(
      id: widget.oldEntity?.id,
      name: _nameController.value,
      description: _descriptionController.value,
      type: _dataTypeController.value,
    );

    CustomEntityManager.of(context).addOrUpdate(customField);
    widget.onSave?.call(customField);
    return true;
  }
}