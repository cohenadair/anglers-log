import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/widgets/input.dart';

enum FieldType {
  number, boolean, text
}

/// Returns a user-visible label for the given [FieldType].
String fieldTypeLocalizedString(BuildContext context, FieldType fieldType) {
  switch (fieldType) {
    case FieldType.number:  return Strings.of(context).fieldTypeNumber;
    case FieldType.boolean: return Strings.of(context).fieldTypeBoolean;
    case FieldType.text:    return Strings.of(context).fieldTypeText;
  }

  // To remove static warning.
  return null;
}

/// Returns the default object used for value tracking for the given
/// [FieldType].
InputController fieldTypeController(FieldType fieldType) {
  switch (fieldType) {
    case FieldType.text:
    case FieldType.number:
      return TextInputController(controller: TextEditingController());
    case FieldType.boolean:
      return InputController();
  }

  // To remove static warning.
  return null;
}

/// Converts the [CustomField] object to the appropriate [Widget].
/// @param controller The object that controls the value of the [CustomField].
///   Could be a [TextEditingController], or a primitive data type.
Widget fieldTypeWidget(BuildContext context, {
  FieldType type,
  String label,
  dynamic controller,
  Function(bool) onCheckboxChanged,
  bool enabled = false,
}) {
  TextEditingController textController = controller is TextEditingController
      ? controller : null;

  switch (type) {
    case FieldType.number: return TextInput.number(context,
      label: label,
      initialValue: null,
      controller: textController,
      enabled: enabled,
    );
    case FieldType.boolean: return CheckboxInput(
      label: label,
      value: controller is bool ? controller : false,
      onChanged: onCheckboxChanged,
      enabled: enabled,
    );
    case FieldType.text: return TextInput(
      label: label,
      initialValue: null,
      controller: textController,
      enabled: enabled,
    );
  }

  // To remove static warning.
  return null;
}