import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/widgets/input.dart';
import 'package:mobile/widgets/widget.dart';

import 'form_page.dart';

/// A input page for users to create custom fields to be used elsewhere in the
/// app. This form is immutable.
class AddCustomFieldPage extends StatefulWidget {
  final AppManager app;
  final Function(CustomEntity) onSave;

  AddCustomFieldPage({
    @required this.app,
    this.onSave,
  }) : assert(app != null);

  @override
  _AddCustomFieldPageState createState() => _AddCustomFieldPageState();
}

class _AddCustomFieldPageState extends State<AddCustomFieldPage> {
  static const String _keyName = "name";
  static const String _keyDescription = "description";
  static const String _keyDataType = "dataType";

  final Map<String, dynamic> _inputOptions = {
    _keyName: TextEditingController(),
    _keyDescription: TextEditingController(),
    _keyDataType: InputType.number,
  };

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      app: widget.app,
      title: Strings.of(context).addCustomFieldPageTitle,
      fieldBuilder: (BuildContext context, _) {
        return Map.fromIterable(_inputOptions.keys,
          key: (dynamic item) => item.toString(),
          value: (dynamic item) => _inputField(context, item.toString()),
        );
      },
      onSave: _save,
    );
  }

  Widget _inputField(BuildContext context, String key) {
    switch (key) {
      case _keyName: return TextInput.name(
        context,
        controller: _inputOptions[key] as TextEditingController,
      );
      case _keyDescription: return TextInput.description(
        context,
        controller: _inputOptions[key] as TextEditingController,
      );
      case _keyDataType: return DropdownInput<InputType>(
        options: InputType.values,
        value: _inputOptions[key] as InputType,
        buildOption: (InputType type) =>
            Text(inputTypeLocalizedString(context, type)),
        onChanged: (InputType newType) {
          setState(() {
            _inputOptions[key] = newType;
          });
        },
      );
      default: print("Unknown key: $key");
    }

    return Empty();
  }

  void _save() {
    var customField = CustomEntity(
      name: (_inputOptions[_keyName] as TextEditingController).text,
      description: (_inputOptions[_keyDescription] as TextEditingController)
          .text,
      type: _inputOptions[_keyDataType],
    );

    widget.app.customFieldManager.addField(customField);
    widget.onSave?.call(customField);
  }
}