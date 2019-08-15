import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/widget.dart';

const int inputLimitName = 20;
const int inputLimitDescription = 140;

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

class TextInput extends StatelessWidget {
  final String initialValue;
  final String label;
  final String requiredText;
  final TextCapitalization capitalization;
  final TextEditingController controller;
  final bool enabled;
  final int maxLength;
  final int maxLines;

  TextInput({
    this.initialValue,
    this.label,
    this.requiredText,
    this.capitalization = TextCapitalization.none,
    this.controller,
    this.enabled = true,
    this.maxLength,
    this.maxLines,
  });

  TextInput.name(BuildContext context, {
    String initialValue,
    TextEditingController controller,
  }) : this(
    initialValue: initialValue,
    label: Strings.of(context).inputNameLabel,
    requiredText: Strings.of(context).inputNameRequired,
    capitalization: TextCapitalization.words,
    controller: controller,
    maxLength: inputLimitName,
  );

  TextInput.description(BuildContext context, {
    String initialValue,
    TextEditingController controller,
  }) : this(
    initialValue: initialValue,
    label: Strings.of(context).inputDescriptionLabel,
    capitalization: TextCapitalization.sentences,
    controller: controller,
    maxLength: inputLimitDescription,
  );

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
      maxLength: maxLength,
      maxLines: maxLines,
    );
  }

  String getValidationError(String input) =>
      isNotEmpty(requiredText) && input.isEmpty ? requiredText : null;
}

class DropdownInput<T> extends StatelessWidget {
  final List<T> options;
  final Function(T) onChanged;
  final T value;

  /// Return a [Widget] rendered as the option for the given [T] value.
  final Widget Function(T value) buildOption;

  DropdownInput({
    @required this.options,
    @required this.onChanged,
    @required this.buildOption,
    this.value,
  }) : assert(options != null && options.length > 0),
       assert(onChanged != null),
       assert(buildOption != null);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      items: options.map((T option) {
        return DropdownMenuItem(
          child: buildOption(option),
          value: option,
        );
      }).toList(),
      onChanged: onChanged,
      value: value,
    );
  }
}