import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';

enum FieldType {
  number, boolean, text
}

/// Returns a user-visible label for the given [FieldType].
String localizedFieldType(BuildContext context, FieldType fieldType) {
  switch (fieldType) {
    case FieldType.number:  return Strings.of(context).fieldTypeNumber;
    case FieldType.boolean: return Strings.of(context).fieldTypeBoolean;
    case FieldType.text:    return Strings.of(context).fieldTypeText;
  }

  // To remove static warning.
  return null;
}

/// Returns the default object used for value tracking for the given
/// [FieldType].
dynamic defaultFieldTypeValue(FieldType fieldType) {
  switch (fieldType) {
    case FieldType.number:  return null;
    case FieldType.boolean: return null;
    case FieldType.text:    return TextEditingController();
  }

  // To remove static warning.
  return null;
}