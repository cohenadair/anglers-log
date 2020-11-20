import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pbenum.dart';
import '../widgets/checkbox_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/text_input.dart';

/// Returns a user-visible label for the given [InputType].
String inputTypeLocalizedString(
    BuildContext context, CustomEntity_Type fieldType) {
  switch (fieldType) {
    case CustomEntity_Type.NUMBER:
      return Strings.of(context).fieldTypeNumber;
    case CustomEntity_Type.BOOL:
      return Strings.of(context).fieldTypeBoolean;
    case CustomEntity_Type.TEXT:
      return Strings.of(context).fieldTypeText;
  }

  // To remove static warning.
  return null;
}

/// Returns the default object used for value tracking for the given
/// [InputType].
InputController inputTypeController(CustomEntity_Type fieldType) {
  switch (fieldType) {
    case CustomEntity_Type.NUMBER:
      return NumberInputController();
    case CustomEntity_Type.BOOL:
      return InputController<bool>();
    case CustomEntity_Type.TEXT:
      return TextInputController();
  }

  // To remove static warning.
  return null;
}

/// Returns a widget based on the given [InputType].
/// @param controller The object that controls the value of the [CustomField].
///        Could be a [TextEditingController], or a primitive data type.
Widget inputTypeWidget(
  BuildContext context, {
  CustomEntity_Type type,
  String label,
  InputController controller,
  Function(bool) onCheckboxChanged,
  bool enabled = true,
}) {
  switch (type) {
    case CustomEntity_Type.NUMBER:
      return TextInput.number(
        context,
        label: label,
        initialValue: null,
        controller: controller,
        enabled: enabled,
      );
    case CustomEntity_Type.BOOL:
      return CheckboxInput(
        label: label,
        value: controller.value is bool ? controller.value : false,
        onChanged: onCheckboxChanged,
        enabled: enabled,
      );
    case CustomEntity_Type.TEXT:
      return TextInput(
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
