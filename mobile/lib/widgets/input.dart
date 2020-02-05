import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

import 'list_item.dart';

const int inputLimitDefault = 40;
const int inputLimitName = 20;
const int inputLimitNumber = 10;
const int inputLimitDescription = 140;

enum InputType {
  number, boolean, text
}

/// Returns a user-visible label for the given [InputType].
String inputTypeLocalizedString(BuildContext context, InputType fieldType) {
  switch (fieldType) {
    case InputType.number:  return Strings.of(context).fieldTypeNumber;
    case InputType.boolean: return Strings.of(context).fieldTypeBoolean;
    case InputType.text:    return Strings.of(context).fieldTypeText;
  }

  // To remove static warning.
  return null;
}

/// Returns the default object used for value tracking for the given
/// [InputType].
InputController inputTypeController(InputType fieldType) {
  switch (fieldType) {
    case InputType.text:
    case InputType.number:
      return TextInputController(controller: TextEditingController());
    case InputType.boolean:
      return InputController();
  }

  // To remove static warning.
  return null;
}

/// Converts the [CustomField] object to the appropriate [Widget].
/// @param controller The object that controls the value of the [CustomField].
///        Could be a [TextEditingController], or a primitive data type.
Widget inputTypeWidget(BuildContext context, {
  InputType type,
  String label,
  dynamic controller,
  Function(bool) onCheckboxChanged,
  bool enabled = false,
}) {
  TextEditingController textController = controller is TextEditingController
      ? controller : null;

  switch (type) {
    case InputType.number: return TextInput.number(context,
      label: label,
      initialValue: null,
      controller: textController,
      enabled: enabled,
    );
    case InputType.boolean: return CheckboxInput(
      label: label,
      value: controller is bool ? controller : false,
      onChanged: onCheckboxChanged,
      enabled: enabled,
    );
    case InputType.text: return TextInput(
      label: label,
      initialValue: null,
      controller: textController,
      enabled: enabled,
    );
  }

  // To remove static warning.
  return null;
}

class InputController<T> {
  T value;

  InputController({
    this.value,
  });

  void dispose() {
    clear();
  }

  void clear() {
    value = null;
  }
}

class TextInputController extends InputController<TextEditingController> {
  TextInputController({
    @required TextEditingController controller,
  }) : assert(controller != null),
       super(value: controller);

  @override
  void dispose() {
    value.dispose();
  }

  @override
  void clear() {
    value.clear();
  }
}

class TimestampInputController extends InputController<int> {
  /// The date component of the controller.
  DateTime date;

  /// The time component of the controller.
  TimeOfDay time;

  TimestampInputController({
    this.date,
    this.time,
  });

  @override
  int get value => combine(date, time).millisecondsSinceEpoch;

  @override
  void clear() {
    super.clear();
    date = null;
    time = null;
  }
}

/// A simple structure for storing build information for a form's input fields.
class InputData {
  final String id;

  /// Returns user-visible label text.
  final String Function(BuildContext) label;

  /// Whether the input can be removed from the associated form. Defaults to
  /// `true`.
  final bool removable;

  InputController controller;

  InputData({
    @required this.id,
    this.controller,
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
        editable && editing ? CondensedCheckBox(
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

class TextInput extends StatelessWidget {
  final String initialValue;
  final String label;
  final String requiredText;
  final TextCapitalization capitalization;
  final TextEditingController controller;
  final bool enabled;
  final bool required;
  final int maxLength;
  final int maxLines;
  final TextInputType keyboardType;
  final String Function(String) validator;

  TextInput({
    this.initialValue,
    this.label,
    this.requiredText,
    this.capitalization = TextCapitalization.none,
    this.controller,
    this.enabled = true,
    this.required = true,
    this.maxLength = inputLimitDefault,
    this.maxLines,
    this.keyboardType,
    this.validator,
  });

  TextInput.name(BuildContext context, {
    String label,
    String requiredText,
    String initialValue,
    TextEditingController controller,
    bool enabled,
    bool required = false,
  }) : this(
    initialValue: initialValue,
    label: isEmpty(label) ? Strings.of(context).inputNameLabel : label,
    requiredText: isEmpty(requiredText)
        ? Strings.of(context).inputNameRequired : requiredText,
    capitalization: TextCapitalization.words,
    controller: controller,
    maxLength: inputLimitName,
    enabled: enabled,
    required: required,
  );

  TextInput.description(BuildContext context, {
    String initialValue,
    TextEditingController controller,
    bool enabled,
    bool required = false,
  }) : this(
    initialValue: initialValue,
    label: Strings.of(context).inputDescriptionLabel,
    capitalization: TextCapitalization.sentences,
    controller: controller,
    maxLength: inputLimitDescription,
    enabled: enabled,
    required: required,
  );

  TextInput.number(BuildContext context, {
    double initialValue,
    String label,
    String requiredText,
    TextEditingController controller,
    bool enabled,
    bool required = false,
  }) : this(
    initialValue: initialValue == null ? null : initialValue.toString(),
    label: label,
    requiredText: requiredText,
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
    enabled: enabled,
    maxLength: inputLimitNumber,
    validator: (String value) {
      if (double.tryParse(value) == null) {
        return Strings.of(context).inputInvalidNumber;
      }
      return null;
    },
    required: required,
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      initialValue: initialValue,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      textCapitalization: capitalization,
      validator: required ? (String value) {
        String errorMessage;
        if (validator != null) {
          errorMessage = validator(value);
        }

        if (isEmpty(errorMessage)) {
          return _validationError(value);
        }

        return errorMessage;
      } : null,
      enabled: enabled,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }

  String _validationError(String input) =>
      isNotEmpty(requiredText) && input.isEmpty ? requiredText : null;
}

/// A [DropdownButtonFormField] wrapper. To disable, set either [options] or
/// [onChanged] to `null`.
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

class CheckboxInput extends StatelessWidget {
  final String label;
  final bool value;
  final bool enabled;
  final Function(bool) onChanged;

  CheckboxInput({
    @required this.label,
    this.value = false,
    this.enabled = true,
    this.onChanged,
  }) : assert(isNotEmpty(label));

  Widget build(BuildContext context) {
    return ListItem(
      contentPadding: insetsZero,
      title: enabled ? Text(label) : DisabledText(label),
      trailing: CondensedCheckBox(
        value: value,
        enabled: enabled,
        onChanged: onChanged,
      ),
    );
  }
}

/// A [Checkbox] widget with optional padding.
class CondensedCheckBox extends StatefulWidget {
  final bool value;
  final bool enabled;
  final EdgeInsets padding;
  final Function(bool) onChanged;

  CondensedCheckBox({
    this.value = false,
    this.enabled = true,
    this.padding = insetsZero,
    this.onChanged,
  });

  @override
  _CondensedCheckBoxState createState() => _CondensedCheckBoxState();
}

class _CondensedCheckBoxState extends State<CondensedCheckBox> {
  bool checked;

  @override
  void initState() {
    super.initState();
    checked = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: InkWell(
        child: Icon(
          checked ? Icons.check_box : Icons.check_box_outline_blank,
          color: widget.enabled
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColorLight,
        ),
        onTap: widget.enabled ? () {
          setState(() {
            checked = !checked;
            widget.onChanged(checked);
          });
        } : null,
      ),
    );
  }
}