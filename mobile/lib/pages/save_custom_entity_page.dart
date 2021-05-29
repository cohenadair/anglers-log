import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../custom_entity_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../utils/protobuf_utils.dart';
import '../utils/validator.dart';
import '../widgets/input_controller.dart';
import '../widgets/input_type.dart';
import '../widgets/radio_input.dart';
import '../widgets/text_input.dart';
import '../widgets/widget.dart';
import 'form_page.dart';

/// A input page for users to create custom fields to be used elsewhere in the
/// app. This form is immutable.
class SaveCustomEntityPage extends StatefulWidget {
  final CustomEntity? oldEntity;
  final void Function(CustomEntity)? onSave;

  SaveCustomEntityPage({
    this.onSave,
  }) : oldEntity = null;

  SaveCustomEntityPage.edit(
    CustomEntity this.oldEntity, {
    this.onSave,
  });

  @override
  _SaveCustomEntityPageState createState() => _SaveCustomEntityPageState();
}

class _SaveCustomEntityPageState extends State<SaveCustomEntityPage> {
  static final _idName = randomId();
  static final _idDescription = randomId();
  static final _idType = randomId();

  final _log = Log("SaveCustomEntityPage");

  final Map<Id, InputController> _inputOptions = {};

  CustomEntityManager get _customEntityManager =>
      CustomEntityManager.of(context);

  TextInputController get _nameController =>
      _inputOptions[_idName]! as TextInputController;

  TextInputController get _descriptionController =>
      _inputOptions[_idDescription]! as TextInputController;

  InputController<CustomEntity_Type> get _dataTypeController =>
      _inputOptions[_idType]! as InputController<CustomEntity_Type>;

  CustomEntity? get _oldEntity => widget.oldEntity;
  bool get _editing => _oldEntity != null;

  @override
  void initState() {
    super.initState();

    _inputOptions[_idName] = TextInputController(
      validator: NameValidator(
        nameExistsMessage: (context) =>
            Strings.of(context).saveCustomEntityPageNameExists,
        nameExists: _customEntityManager.nameExists,
        oldName: _oldEntity?.name,
      ),
    );

    _inputOptions[_idDescription] = TextInputController();

    _inputOptions[_idType] = InputController<CustomEntity_Type>(
      value: CustomEntity_Type.number,
    );

    if (_editing) {
      _nameController.value = _oldEntity!.name;
      _descriptionController.value = _oldEntity!.description;
      _dataTypeController.value = _oldEntity!.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      title: _editing
          ? Text(Strings.of(context).saveCustomEntityPageEditTitle)
          : Text(Strings.of(context).saveCustomEntityPageNewTitle),
      fieldBuilder: (context) => <Id, Widget>{
        for (var id in _inputOptions.keys) id: _inputField(context, id)
      },
      onSave: _save,
      isInputValid: _nameController.isValid(context),
    );
  }

  Widget _inputField(BuildContext context, Id id) {
    if (id == _idName) {
      return TextInput.name(
        context,
        controller: _nameController,
        autofocus: true,
        textInputAction: TextInputAction.next,
        // Trigger "Save" button state refresh.
        onChanged: (_) => setState(() {}),
      );
    } else if (id == _idDescription) {
      return TextInput.description(
        context,
        controller: _descriptionController,
      );
    } else if (id == _idType) {
      return RadioInput(
        initialSelectedIndex:
            CustomEntity_Type.values.indexOf(_dataTypeController.value!),
        optionCount: CustomEntity_Type.values.length,
        optionBuilder: (context, i) =>
            inputTypeLocalizedString(context, CustomEntity_Type.values[i]),
        onSelect: (i) => setState(() {
          _dataTypeController.value = CustomEntity_Type.values[i];
        }),
      );
    } else {
      _log.e("Unknown id: $id");
      return Empty();
    }
  }

  FutureOr<bool> _save(BuildContext _) {
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
