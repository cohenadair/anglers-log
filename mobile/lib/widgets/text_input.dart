import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../res/style.dart';
import '../utils/validator.dart';
import '../widgets/input_controller.dart';

class TextInput extends StatefulWidget {
  static const int _inputLimitDefault = 40;
  static const int _inputLimitName = _inputLimitDefault;
  static const int _inputLimitNumber = 10;
  static const int _inputLimitEmail = 64;

  final String? initialValue;
  final String? label;
  final String? suffixText;
  final String? hintText;
  final TextCapitalization capitalization;
  final TextInputAction? textInputAction;

  /// The controller for the [TextInput]. The [TextInput] will update the
  /// controller's [validate] property automatically.
  final TextInputController? controller;

  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final int? maxLength;
  final int? maxLines;
  final TextInputType? keyboardType;

  /// Invoked when the [TextInput] text changes, _after_ [Validator.run] is
  /// invoked. Implement this property to update the state of the parent
  /// widget.
  final ValueChanged<String>? onChanged;

  /// Invoked when the "return" button is pressed on the keyboard when this
  /// [TextInput] is in focus.
  final VoidCallback? onSubmitted;

  /// See [TextField.focusNode].
  final FocusNode? focusNode;

  const TextInput({
    this.initialValue,
    this.label,
    this.suffixText,
    this.hintText,
    this.capitalization = TextCapitalization.none,
    this.textInputAction,
    required this.controller,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.obscureText = false,
    this.maxLength = _inputLimitDefault,
    this.maxLines,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
  });

  TextInput.name(
    BuildContext context, {
    String? label,
    String? initialValue,
    required TextInputController controller,
    bool enabled = true,
    bool autofocus = false,
    ValueChanged<String>? onChanged,
    TextInputAction? textInputAction,
  }) : this(
          initialValue: initialValue,
          label: isEmpty(label) ? Strings.of(context).inputNameLabel : label,
          capitalization: TextCapitalization.words,
          controller: controller,
          maxLength: _inputLimitName,
          maxLines: 1,
          enabled: enabled,
          autofocus: autofocus,
          onChanged: onChanged,
          textInputAction: textInputAction,
        );

  TextInput.description(
    BuildContext context, {
    String? title,
    String? initialValue,
    String? hintText,
    required TextInputController controller,
    bool enabled = true,
    bool autofocus = false,
    ValueChanged<String>? onChanged,
  }) : this(
          initialValue: initialValue,
          label: title ?? Strings.of(context).inputDescriptionLabel,
          capitalization: TextCapitalization.sentences,
          controller: controller,
          maxLength: null, // No limit.
          enabled: enabled,
          autofocus: autofocus,
          onChanged: onChanged,
          hintText: hintText,
        );

  TextInput.number(
    BuildContext context, {
    double? initialValue,
    String? label,
    String? suffixText,
    String? requiredText,
    String? hintText,
    required NumberInputController? controller,
    bool enabled = true,
    bool autofocus = false,
    bool required = false,
    bool signed = true,
    bool decimal = true,
    bool showMaxLength = true,
    TextInputAction? textInputAction,
    ValueChanged<String>? onChanged,
  }) : this(
          initialValue: initialValue?.toString(),
          label: label,
          suffixText: suffixText,
          hintText: hintText,
          controller: controller,
          keyboardType:
              TextInputType.numberWithOptions(signed: signed, decimal: decimal),
          enabled: enabled,
          autofocus: autofocus,
          maxLength: showMaxLength ? _inputLimitNumber : null,
          maxLines: 1,
          textInputAction: textInputAction,
          onChanged: onChanged,
        );

  TextInput.email(
    BuildContext context, {
    String? initialValue,
    required EmailInputController controller,
    bool enabled = true,
    bool autofocus = false,
    ValueChanged<String>? onChanged,
    TextInputAction? textInputAction,
    VoidCallback? onSubmitted,
  }) : this(
          initialValue: initialValue,
          label: Strings.of(context).inputEmailLabel,
          capitalization: TextCapitalization.none,
          controller: controller,
          maxLength: _inputLimitEmail,
          maxLines: 1,
          enabled: enabled,
          autofocus: autofocus,
          onChanged: onChanged,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
        );

  TextInput.password(
    BuildContext context, {
    required PasswordInputController controller,
    ValueChanged<String>? onChanged,
    VoidCallback? onSubmitted,
  }) : this(
          label: Strings.of(context).inputPasswordLabel,
          capitalization: TextCapitalization.none,
          maxLength: null,
          obscureText: true,
          maxLines: 1,
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        );

  @override
  TextInputState createState() => TextInputState();
}

class TextInputState extends State<TextInput> {
  static const _maxErrorHintLines = 2;

  ValidationCallback? get _validationCallback =>
      widget.controller?.validator?.run(context, widget.controller!.value);

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
        initialValue: widget.initialValue,
        controller: widget.controller?.editingController,
        decoration: InputDecoration(
          labelText: widget.label,
          errorText: widget.controller?.error,
          errorMaxLines: _maxErrorHintLines,
          suffixText: widget.suffixText,
          suffixStyle: styleSecondary(context),
          hintText: widget.hintText,
          hintMaxLines: _maxErrorHintLines,
        ),
        style: widget.enabled ? null : styleDisabled(context),
        textCapitalization: widget.capitalization,
        textInputAction: widget.textInputAction,
        enabled: widget.enabled,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        onChanged: (value) {
          widget.onChanged?.call(value);
          setState(_updateError);
        },
        onFieldSubmitted: (_) => widget.onSubmitted?.call(),
        autofocus: widget.autofocus,
        obscureText: widget.obscureText,
        focusNode: widget.focusNode,
      ),
    );
  }

  void _updateError() {
    widget.controller?.error = _validationCallback?.call(context);
  }
}
