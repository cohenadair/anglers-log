import 'package:flutter/material.dart';
import 'package:mobile/utils/string_utils.dart';

class TextInput extends TextFormField {
  final String label;
  final String requiredText;
  final TextCapitalization capitalization;

  TextInput({
    this.label,
    this.requiredText,
    this.capitalization = TextCapitalization.none,
  }) : super(
    key: GlobalKey<FormFieldState>(),
    decoration: InputDecoration(
      labelText: label,
    ),
    textCapitalization: capitalization,
    validator: (String value)
        => isNotEmpty(requiredText) && value.isEmpty ? requiredText : null,
  );
}