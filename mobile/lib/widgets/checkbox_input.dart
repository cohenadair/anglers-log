import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:quiver/strings.dart';

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
      title: enabled ? Label(label) : DisabledLabel(label),
      trailing: PaddedCheckbox(
        checked: value,
        enabled: enabled,
        onChanged: onChanged,
      ),
    );
  }
}

/// A [Checkbox] widget with optional padding.
class PaddedCheckbox extends StatefulWidget {
  final bool checked;
  final bool enabled;
  final EdgeInsets padding;
  final Function(bool) onChanged;

  PaddedCheckbox({
    this.checked = false,
    this.enabled = true,
    this.padding = insetsZero,
    this.onChanged,
  });

  @override
  _PaddedCheckboxState createState() => _PaddedCheckboxState();
}

class _PaddedCheckboxState extends State<PaddedCheckbox> {
  bool checked;

  @override
  void initState() {
    super.initState();
    checked = widget.checked;
  }

  @override
  void didUpdateWidget(PaddedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.checked != widget.checked) {
      checked = widget.checked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: SizedBox(
        width: checkboxSizeDefault,
        height: checkboxSizeDefault,
        child: Checkbox(
          value: checked,
          onChanged: widget.enabled ? (value) {
            setState(() {
              checked = !checked;
              widget.onChanged(checked);
            });
          } : null,
        ),
      ),
    );
  }
}