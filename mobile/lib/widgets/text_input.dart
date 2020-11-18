import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/validator.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:quiver/strings.dart';

class TextInput extends StatefulWidget {
  static const int _inputLimitDefault = 40;
  static const int _inputLimitName = _inputLimitDefault;
  static const int _inputLimitNumber = 10;
  static const int _inputLimitDescription = 140;
  static const int _inputLimitEmail = 64;

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
    this.maxLength = _inputLimitDefault,
    this.maxLines,
    this.keyboardType,
    this.onChanged,
  });

  TextInput.name(
    BuildContext context, {
    String label,
    String initialValue,
    TextInputController controller,
    bool enabled,
    bool autofocus = false,
    VoidCallback onChanged,
  }) : this(
          initialValue: initialValue,
          label: isEmpty(label) ? Strings.of(context).inputNameLabel : label,
          capitalization: TextCapitalization.words,
          controller: controller,
          maxLength: _inputLimitName,
          enabled: enabled,
          autofocus: autofocus,
          onChanged: onChanged,
        );

  TextInput.description(
    BuildContext context, {
    String initialValue,
    TextInputController controller,
    bool enabled,
    bool autofocus = false,
  }) : this(
          initialValue: initialValue,
          label: Strings.of(context).inputDescriptionLabel,
          capitalization: TextCapitalization.sentences,
          controller: controller,
          maxLength: _inputLimitDescription,
          enabled: enabled,
          autofocus: autofocus,
        );

  TextInput.number(
    BuildContext context, {
    double initialValue,
    String label,
    String requiredText,
    NumberInputController controller,
    bool enabled,
    bool autofocus = false,
    bool required = false,
  }) : this(
          initialValue: initialValue == null ? null : initialValue.toString(),
          label: label,
          controller: controller,
          keyboardType:
              TextInputType.numberWithOptions(signed: true, decimal: true),
          enabled: enabled,
          autofocus: autofocus,
          maxLength: _inputLimitNumber,
        );

  TextInput.email(
    BuildContext context, {
    String initialValue,
    EmailInputController controller,
    bool enabled,
    bool autofocus = false,
    VoidCallback onChanged,
  }) : this(
          initialValue: initialValue,
          label: Strings.of(context).inputEmailLabel,
          capitalization: TextCapitalization.none,
          controller: controller,
          maxLength: _inputLimitEmail,
          enabled: enabled,
          autofocus: autofocus,
          onChanged: onChanged,
        );

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  ValidationCallback get _validationCallback =>
      widget.controller?.validator?.run(context, widget.controller.value);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateError();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: TextFormField(
        cursorColor: Theme.of(context).primaryColor,
        initialValue: widget.initialValue,
        controller: widget.controller?.editingController,
        decoration: InputDecoration(
          labelText: widget.label,
          errorText: widget.controller?.error,
        ),
        textCapitalization: widget.capitalization,
        enabled: widget.enabled,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        onChanged: (_) {
          widget.onChanged?.call();
          setState(() {
            _updateError();
          });
        },
        autofocus: widget.autofocus,
      ),
    );
  }

  void _updateError() {
    widget.controller?.error = _validationCallback?.call(context);
  }
}
