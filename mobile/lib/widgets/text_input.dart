import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:quiver/strings.dart';

class TextInput extends StatefulWidget {
  static const int inputLimitDefault = 40;
  static const int inputLimitName = 20;
  static const int inputLimitNumber = 10;
  static const int inputLimitDescription = 140;

  final String initialValue;
  final String label;
  final TextCapitalization capitalization;
  final TextEditingController controller;
  final bool enabled;
  final bool autofocus;
  final int maxLength;
  final int maxLines;
  final TextInputType keyboardType;
  final FutureOr<String> Function(String) validator;

  /// If true, invokes [validator] in the [TextFormField.onChanged] callback,
  /// and updates [errorText].
  final bool validateOnChange;

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
    this.validateOnChange = true,
  });

  TextInput.name(BuildContext context, {
    String label,
    String initialValue,
    TextEditingController controller,
    bool enabled,
    bool autofocus = false,
    FutureOr<String> Function(String) validator,
  }) : this(
    initialValue: initialValue,
    label: isEmpty(label) ? Strings.of(context).inputNameLabel : label,
    capitalization: TextCapitalization.words,
    controller: controller,
    maxLength: inputLimitName,
    enabled: enabled,
    autofocus: autofocus,
    validator: validator,
  );

  TextInput.description(BuildContext context, {
    String initialValue,
    TextEditingController controller,
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
    TextEditingController controller,
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
    validator: (String value) {
      if (double.tryParse(value) == null) {
        return Strings.of(context).inputInvalidNumber;
      }
      return null;
    },
  );

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  String _errorText;

  @override
  void initState() {
    super.initState();
    _updateErrorText(widget.controller.value.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      initialValue: widget.initialValue,
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: _errorText,
      ),
      textCapitalization: widget.capitalization,
      validator: (text) => widget.validator?.call(text),
      enabled: widget.enabled,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      onChanged: (newText) async {
        if (widget.validateOnChange) {
          _updateErrorText(newText);
        }
      },
      autofocus: widget.autofocus,
    );
  }

  void _updateErrorText(String inputText) async {
    var error = await widget.validator?.call(inputText);
    setState(() {
      _errorText = error;
    });
  }
}