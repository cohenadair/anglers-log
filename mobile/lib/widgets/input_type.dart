import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/text_input.dart';

// Do not change order of enum values as their ordinal number is recorded in the
// database.
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
      return TextInputController();
    case InputType.number:
      return NumberInputController();
    case InputType.boolean:
      return InputController<bool>();
  }

  // To remove static warning.
  return null;
}

/// Returns a widget based on the given [InputType].
/// @param controller The object that controls the value of the [CustomField].
///        Could be a [TextEditingController], or a primitive data type.
Widget inputTypeWidget(BuildContext context, {
  InputType type,
  String label,
  InputController controller,
  Function(bool) onCheckboxChanged,
  bool enabled = true,
}) {
  switch (type) {
    case InputType.number: return TextInput.number(context,
      label: label,
      initialValue: null,
      controller: controller,
      enabled: enabled,
    );
    case InputType.boolean: return CheckboxInput(
      label: label,
      value: controller.value is bool ? controller.value : false,
      onChanged: onCheckboxChanged,
      enabled: enabled,
    );
    case InputType.text: return TextInput(
      capitalization: TextCapitalization.sentences,
      label: label,
      initialValue: null,
      controller: controller,
      enabled: enabled,
    );
  }

  // To remove static warning.
  return null;
}