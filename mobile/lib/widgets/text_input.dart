import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:quiver/strings.dart';

class TextInput extends StatelessWidget {
  static const int inputLimitDefault = 40;
  static const int inputLimitName = 20;
  static const int inputLimitNumber = 10;
  static const int inputLimitDescription = 140;

  final String initialValue;
  final String label;
  final TextCapitalization capitalization;
  final TextInputController controller;
  final bool enabled;
  final bool autofocus;
  final int maxLength;
  final int maxLines;
  final TextInputType keyboardType;

  /// Invoked when the [TextInput] text changes. The updated text value can be
  /// read from the [TextInputController] used when creating this widget.
  final void Function() onTextChange;

  TextInput({
    this.initialValue,
    this.label,
    this.capitalization = TextCapitalization.none,
    this.controller,
    this.enabled = true,
    this.autofocus = false,
    this.maxLength = inputLimitDefault,
    this.maxLines,
    this.keyboardType,
    this.onTextChange,
  });

  TextInput.name(BuildContext context, {
    String label,
    String initialValue,
    TextInputController controller,
    bool enabled,
    bool autofocus = false,
    void Function() onTextChange,
  }) : this(
    initialValue: initialValue,
    label: isEmpty(label) ? Strings.of(context).inputNameLabel : label,
    capitalization: TextCapitalization.words,
    controller: controller,
    maxLength: inputLimitName,
    enabled: enabled,
    autofocus: autofocus,
    onTextChange: onTextChange,
  );

  TextInput.description(BuildContext context, {
    String initialValue,
    TextInputController controller,
    bool enabled,
    bool autofocus = false,
  }) : this(
    initialValue: initialValue,
    label: Strings.of(context).inputDescriptionLabel,
    capitalization: TextCapitalization.sentences,
    controller: controller,
    maxLength: inputLimitDescription,
    enabled: enabled,
    autofocus: autofocus,
  );

  TextInput.number(BuildContext context, {
    double initialValue,
    String label,
    String requiredText,
    TextInputController controller,
    bool enabled,
    bool autofocus = false,
    bool required = false,
  }) : this(
    initialValue: initialValue == null ? null : initialValue.toString(),
    label: label,
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
    enabled: enabled,
    autofocus: autofocus,
    maxLength: inputLimitNumber,
    onTextChange: () {
      if (double.tryParse(controller.value.text) == null) {
        controller.errorCallback =
            (context) => Strings.of(context).inputInvalidNumber;
      }
      controller.errorCallback = null;
    },
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      initialValue: initialValue,
      controller: controller.value,
      decoration: InputDecoration(
        labelText: label,
        errorText: controller.error(context),
      ),
      textCapitalization: capitalization,
      validator: (text) => controller.error(context),
      enabled: enabled,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: (_) => onTextChange?.call(),
      autofocus: autofocus,
    );
  }
}