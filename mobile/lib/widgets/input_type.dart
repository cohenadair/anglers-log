import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pbenum.dart';
import '../widgets/checkbox_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/text_input.dart';

/// Returns a user-visible label for the given [InputType]. Throws an
/// [ArgumentError] if [fieldType] is invalid.
String inputTypeLocalizedString(
    BuildContext context, CustomEntity_Type fieldType) {
  switch (fieldType) {
    case CustomEntity_Type.number:
      return Strings.of(context).fieldTypeNumber;
    case CustomEntity_Type.boolean:
      return Strings.of(context).fieldTypeBoolean;
    case CustomEntity_Type.text:
      return Strings.of(context).fieldTypeText;
  }

  throw ArgumentError(
      "fieldType $fieldType not handled in inputTypeLocalizedString");
}

/// Returns the default object used for value tracking for the given
/// [InputType]. Throws an [ArgumentError] if [fieldType] is invalid.
InputController inputTypeController(CustomEntity_Type fieldType) {
  switch (fieldType) {
    case CustomEntity_Type.number:
      return NumberInputController();
    case CustomEntity_Type.boolean:
      return BoolInputController();
    case CustomEntity_Type.text:
      return TextInputController();
  }

  throw ArgumentError(
      "fieldType $fieldType not handled in inputTypeController");
}

/// Returns a widget based on the given [InputType]. Throws an [ArgumentError]
/// if [type] is invalid.
Widget inputTypeWidget(
  BuildContext context, {
  required CustomEntity_Type type,
  required String label,
  InputController? controller,
  Function(bool)? onCheckboxChanged,
  Function(String)? onTextFieldChanged,
  bool enabled = true,
}) {
  switch (type) {
    case CustomEntity_Type.number:
      assert(controller == null || controller is NumberInputController);
      return TextInput.number(
        context,
        label: label,
        initialValue: null,
        controller: controller as NumberInputController?,
        enabled: enabled,
        onChanged: onTextFieldChanged,
      );
    case CustomEntity_Type.boolean:
      return CheckboxInput(
        label: label,
        value: controller != null && controller.value is bool
            ? controller.value! as bool
            : false,
        onChanged: onCheckboxChanged,
        enabled: enabled,
      );
    case CustomEntity_Type.text:
      assert(controller == null || controller is TextInputController);
      return TextInput(
        capitalization: TextCapitalization.sentences,
        label: label,
        initialValue: null,
        controller: controller as TextInputController?,
        enabled: enabled,
        onChanged: onTextFieldChanged,
      );
  }

  throw ArgumentError("type $type not handled in inputTypeWidget");
}
