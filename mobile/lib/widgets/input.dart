import 'package:flutter/material.dart';
import 'package:mobile/utils/string_utils.dart';

class TextInput extends TextFormField {
  final String label;
  final String requiredText;

  TextInput({
    this.label,
    this.requiredText,
  }) : super(
    key: GlobalKey<FormFieldState>(),
    decoration: InputDecoration(
      labelText: label,
    ),
    validator: (String value)
        => isNotEmpty(requiredText) && value.isEmpty ? requiredText : null,
  );
}