import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/text_input.dart';

enum InputType {
  number, boolean, text
}

/// Returns a user-visible label for the given [InputType].
String inputTypeLocalizedString(BuildContext context, InputType fieldType) {
  switch (fieldType) {
    case InputType.number:  return Strings.of(context).fieldTypeNumber;
    case InputType.boolean: return Strings.of(context).fieldTypeBoolean;
    case InputType.text:    return Strings.of(context).fieldTypeText;
  }

  // To remove static warning.
  return null;
}

/// Returns the default object used for value tracking for the given
/// [InputType].
InputController inputTypeController(InputType fieldType) {
  switch (fieldType) {
    case InputType.text:
    case InputType.number:
      return TextInputController(controller: TextEditingController());
    case InputType.boolean:
      return InputController();
  }

  // To remove static warning.
  return null;
}

/// Converts the [CustomField] object to the appropriate [Widget].
/// @param controller The object that controls the value of the [CustomField].
///        Could be a [TextEditingController], or a primitive data type.
Widget inputTypeWidget(BuildContext context, {
  InputType type,
  String label,
  dynamic controller,
  Function(bool) onCheckboxChanged,
  bool enabled = false,
}) {
  TextEditingController textController = controller is TextEditingController
      ? controller : null;

  switch (type) {
    case InputType.number: return TextInput.number(context,
      label: label,
      initialValue: null,
      controller: textController,
      enabled: enabled,
    );
    case InputType.boolean: return CheckboxInput(
      label: label,
      value: controller is bool ? controller : false,
      onChanged: onCheckboxChanged,
      enabled: enabled,
    );
    case InputType.text: return TextInput(
      label: label,
      initialValue: null,
      controller: textController,
      enabled: enabled,
    );
  }

  // To remove static warning.
  return null;
}