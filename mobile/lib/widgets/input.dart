import 'package:flutter/material.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/widget.dart';

abstract class InputField extends Widget {
}

/// A generic [Widget] used for gathering user input. The [Input] widget
/// supports and "editing mode" that reveals a [CheckBox] to the right of the
/// widget that can be used for removing [Input] widgets from the view
/// hierarchy.
class Input extends StatelessWidget {
  final Widget child;
  final bool editing;
  final bool selected;
  final Function(bool) onEditingSelectionChanged;

  Input({
    @required this.child,
    this.editing = false,
    this.selected = false,
    this.onEditingSelectionChanged,
  }) : assert(child != null);

  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        child,
        editing ? Checkbox(
          value: selected,
          onChanged: (bool value) {
            onEditingSelectionChanged?.call(value);
          },
        ) : Empty(),
      ],
    );
  }
}

class TextInput extends StatelessWidget implements InputField {
  final String initialValue;
  final String label;
  final String requiredText;
  final TextCapitalization capitalization;
  final TextEditingController controller;
  final bool enabled;

  TextInput({
    this.initialValue,
    this.label,
    this.requiredText,
    this.capitalization = TextCapitalization.none,
    this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      textCapitalization: capitalization,
      validator: getValidationError,
      enabled: enabled,
    );
  }

  String getValidationError(String input) =>
      isNotEmpty(requiredText) && input.isEmpty ? requiredText : null;
}