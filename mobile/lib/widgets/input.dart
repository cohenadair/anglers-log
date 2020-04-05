import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

/// A simple structure for storing build information for a form's input fields.
class InputData {
  final String id;

  /// Returns user-visible label text. This is required for displaying this
  /// input in the list of available inputs in an [EditableFormPage].
  final String Function(BuildContext) label;

  /// Whether the input can be removed from the associated form. Defaults to
  /// `true`.
  final bool removable;

  InputController controller;

  InputData({
    @required this.id,
    @required this.controller,
    @required this.label,
    this.removable = true,
  }) : assert(isNotEmpty(id)),
       assert(label != null),
       assert(controller != null);
}

/// A generic [Widget] used for gathering user input. The [Input] widget
/// supports and "editing mode" that reveals a [CheckBox] to the right of the
/// widget that can be used for removing [Input] widgets from the view
/// hierarchy.
class Input extends StatelessWidget {
  final Widget child;

  /// Set to `true` if the [Input] widget can be editable. If `false`, no
  /// [CheckBox] is shown in editing mode.
  final bool editable;

  final bool editing;
  final bool selected;
  final Function(bool) onEditingSelectionChanged;

  Input({
    @required this.child,
    this.editable = true,
    this.editing = false,
    this.selected = false,
    this.onEditingSelectionChanged,
  }) : assert(child != null);

  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        child,
        editable && editing ? PaddedCheckbox(
          padding: insetsLeftDefault,
          value: selected,
          onChanged: (bool value) {
            onEditingSelectionChanged?.call(value);
          },
        ) : Empty(),
      ],
    );
  }
}