import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/validator.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/input_type.dart';
import 'package:mobile/widgets/radio_input.dart';
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

  SaveCustomEntityPage.edit(
    this.oldEntity, {
    this.onSave,
  }) : assert(oldEntity != null);

  @override
  _SaveCustomEntityPageState createState() => _SaveCustomEntityPageState();
}

class _SaveCustomEntityPageState extends State<SaveCustomEntityPage> {
  static final _idName = randomId();
  static final _idDescription = randomId();
  static final _idType = randomId();

  final Log _log = Log("SaveCustomEntityPage");

  Map<Id, InputController> _inputOptions;

  CustomEntityManager get _customEntityManager =>
      CustomEntityManager.of(context);

  TextInputController get _nameController =>
      _inputOptions[_idName] as TextInputController;

  TextInputController get _descriptionController =>
      _inputOptions[_idDescription] as TextInputController;

  InputController<CustomEntity_Type> get _dataTypeController =>
      _inputOptions[_idType] as InputController<CustomEntity_Type>;

  CustomEntity get _oldEntity => widget.oldEntity;
  bool get _editing => _oldEntity != null;

  @override
  void initState() {
    super.initState();

    _inputOptions = {
      _idName: TextInputController(
        validator: NameValidator(
          nameExistsMessage: (context) =>
              Strings.of(context).saveCustomEntityPageNameExists,
          nameExists: _customEntityManager.nameExists,
          oldName: _oldEntity?.name,
        ),
      ),
      _idDescription: TextInputController(),
      _idType: InputController<CustomEntity_Type>(
        value: CustomEntity_Type.NUMBER,
      ),
    };

    if (_editing) {
      _nameController.value = _oldEntity.name;
      _descriptionController.value = _oldEntity.description;
      _dataTypeController.value = _oldEntity.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      title: _editing
          ? Text(Strings.of(context).saveCustomEntityPageEditTitle)
          : Text(Strings.of(context).saveCustomEntityPageNewTitle),
      fieldBuilder: (context) {
        return Map.fromIterable(
          _inputOptions.keys,
          key: (item) => item,
          value: (item) => _inputField(context, item),
        );
      },
      onSave: _save,
      isInputValid: _nameController.valid(context),
    );
  }

  Widget _inputField(BuildContext context, Id id) {
    if (id == _idName) {
      return TextInput.name(
        context,
        controller: _nameController,
        autofocus: true,
        // Trigger "Save" button state refresh.
        onChanged: () => setState(() {}),
      );
    } else if (id == _idDescription) {
      return TextInput.description(
        context,
        controller: _descriptionController,
      );
    } else if (id == _idType) {
      return RadioInput(
        initialSelectedIndex:
            CustomEntity_Type.values.indexOf(_dataTypeController.value),
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
      ..name = _nameController.value
      ..type = _dataTypeController.value;

    if (isNotEmpty(_descriptionController.value)) {
      customEntity.description = _descriptionController.value;
    }

    _customEntityManager.addOrUpdate(customEntity);
    widget.onSave?.call(customEntity);
    return true;
  }
}
