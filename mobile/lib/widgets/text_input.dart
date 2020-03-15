import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:quiver/strings.dart';

class TextInput extends StatefulWidget {
  static const int inputLimitDefault = 40;
  static const int inputLimitName = 20;
  static const int inputLimitNumber = 10;
  static const int inputLimitDescription = 140;

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

  /// Invoked when the [TextInput] text changes. The updated text value can be
  /// read from the [TextInputController] used when creating this widget.
  final FutureOr<ValidationCallback> Function() validate;

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
    this.validate,
  });

  TextInput.name(BuildContext context, {
    String label,
    String initialValue,
    TextInputController controller,
    bool enabled,
    bool autofocus = false,
    FutureOr<ValidationCallback> Function() validate,
  }) : this(
    initialValue: initialValue,
    label: isEmpty(label) ? Strings.of(context).inputNameLabel : label,
    capitalization: TextCapitalization.words,
    controller: controller,
    maxLength: inputLimitName,
    enabled: enabled,
    autofocus: autofocus,
    validate: validate,
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
    validate: () {
      if (double.tryParse(controller.value.text) == null) {
        return (context) => Strings.of(context).inputInvalidNumber;
      }
      return null;
    },
  );

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  ValidationCallback _validate;

  @override
  void initState() {
    super.initState();
    _validate = widget.controller.validate;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      initialValue: widget.initialValue,
      controller: widget.controller.value,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.controller.error(context),
      ),
      textCapitalization: widget.capitalization,
      validator: (text) => _validate?.call(context),
      enabled: widget.enabled,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      onChanged: (_) async {
        var callback = await widget.validate?.call();
        if (widget.controller.validate != callback) {
          setState(() {
            _validate = callback;
          });
          widget.controller.validate = _validate;
        }
      },
      autofocus: widget.autofocus,
    );
  }
}