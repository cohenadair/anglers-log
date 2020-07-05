import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/validator.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:quiver/strings.dart';

class TextInput extends StatefulWidget {
  static const int inputLimitDefault = 40;
  static const int inputLimitName = inputLimitDefault;
  static const int inputLimitNumber = 10;
  static const int inputLimitDescription = 140;
  static const int inputLimitEmail = 64;

  final String initialValue;
  final String label;
  final TextCapitalization capitalization;

  /// The controller for the [TextInput]. The [TextInput] will update the
  /// controller's [validate] property automatically.
  final TextInputController controller;

  final bool enabled;
  final bool autofocus;
  final int maxLength;
  final int maxLines;
  final TextInputType keyboardType;

  /// The [Validator.run] method is invoked when the [TextInput] is first
  /// created, and when the text changes. The updated text updated value can be
  /// read from the [TextInputController] used when creating this widget.
  final Validator validator;

  /// Invoked when the [TextInput] text changes, _after_ [Validator.run] is
  /// invoked. Implement this property to update the state of the parent
  /// widget.
  final VoidCallback onChanged;

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
    this.validator,
    this.onChanged,
  });

  TextInput.name(BuildContext context, {
    String label,
    String initialValue,
    TextInputController controller,
    bool enabled,
    bool autofocus = false,
    Validator validator,
    VoidCallback onChanged,
  }) : this(
    initialValue: initialValue,
    label: isEmpty(label) ? Strings.of(context).inputNameLabel : label,
    capitalization: TextCapitalization.words,
    controller: controller,
    maxLength: inputLimitName,
    enabled: enabled,
    autofocus: autofocus,
    validator: validator,
    onChanged: onChanged,
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
    validator: DoubleValidator(),
  );

  TextInput.email(BuildContext context, {
    String initialValue,
    TextInputController controller,
    bool enabled,
    bool autofocus = false,
    bool required = false,
    VoidCallback onChanged,
  }) : this(
    initialValue: initialValue,
    label: Strings.of(context).inputEmailLabel,
    capitalization: TextCapitalization.none,
    controller: controller,
    maxLength: inputLimitEmail,
    enabled: enabled,
    autofocus: autofocus,
    validator: EmailValidator(required: required),
    onChanged: onChanged,
  );

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  ValidationCallback get _validationCallback =>
      widget.validator?.run(context, widget.controller.value);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      initialValue: widget.initialValue,
      controller: widget.controller.editingController,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.controller.error(context),
      ),
      textCapitalization: widget.capitalization,
      validator: (text) {
        String validationError = _validationCallback?.call(context);
        return isEmpty(validationError) ? null : validationError;
      },
      enabled: widget.enabled,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      onChanged: (_) {
        ValidationCallback callback = _validationCallback;
        if (widget.controller.validate != callback) {
          widget.controller.validate = callback;
          setState(() {});
        }
        widget.onChanged?.call();
      },
      autofocus: widget.autofocus,
    );
  }
}