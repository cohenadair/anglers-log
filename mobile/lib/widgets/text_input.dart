import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:quiver/strings.dart';

class TextInput extends StatelessWidget {
  static const int inputLimitDefault = 40;
  static const int inputLimitName = 20;
  static const int inputLimitNumber = 10;
  static const int inputLimitDescription = 140;

  final String initialValue;
  final String label;
  final String requiredText;
  final TextCapitalization capitalization;
  final TextEditingController controller;
  final bool enabled;
  final bool required;
  final int maxLength;
  final int maxLines;
  final TextInputType keyboardType;
  final String Function(String) validator;

  TextInput({
    this.initialValue,
    this.label,
    this.requiredText,
    this.capitalization = TextCapitalization.none,
    this.controller,
    this.enabled = true,
    this.required = true,
    this.maxLength = inputLimitDefault,
    this.maxLines,
    this.keyboardType,
    this.validator,
  });

  TextInput.name(BuildContext context, {
    String label,
    String requiredText,
    String initialValue,
    TextEditingController controller,
    bool enabled,
    bool required = false,
  }) : this(
    initialValue: initialValue,
    label: isEmpty(label) ? Strings.of(context).inputNameLabel : label,
    requiredText: isEmpty(requiredText)
        ? Strings.of(context).inputNameRequired : requiredText,
    capitalization: TextCapitalization.words,
    controller: controller,
    maxLength: inputLimitName,
    enabled: enabled,
    required: required,
  );

  TextInput.description(BuildContext context, {
    String initialValue,
    TextEditingController controller,
    bool enabled,
    bool required = false,
  }) : this(
    initialValue: initialValue,
    label: Strings.of(context).inputDescriptionLabel,
    capitalization: TextCapitalization.sentences,
    controller: controller,
    maxLength: inputLimitDescription,
    enabled: enabled,
    required: required,
  );

  TextInput.number(BuildContext context, {
    double initialValue,
    String label,
    String requiredText,
    TextEditingController controller,
    bool enabled,
    bool required = false,
  }) : this(
    initialValue: initialValue == null ? null : initialValue.toString(),
    label: label,
    requiredText: requiredText,
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
    enabled: enabled,
    maxLength: inputLimitNumber,
    validator: (String value) {
      if (double.tryParse(value) == null) {
        return Strings.of(context).inputInvalidNumber;
      }
      return null;
    },
    required: required,
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      initialValue: initialValue,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      textCapitalization: capitalization,
      validator: required ? (String value) {
        String errorMessage;
        if (validator != null) {
          errorMessage = validator(value);
        }

        if (isEmpty(errorMessage)) {
          return _validationError(value);
        }

        return errorMessage;
      } : null,
      enabled: enabled,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }

  String _validationError(String input) =>
      isNotEmpty(requiredText) && input.isEmpty ? requiredText : null;
}