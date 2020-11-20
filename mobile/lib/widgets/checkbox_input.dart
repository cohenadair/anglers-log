import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import '../widgets/list_item.dart';
import '../widgets/text.dart';

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
  bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.checked;
  }

  @override
  void didUpdateWidget(PaddedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.checked != widget.checked) {
      _checked = widget.checked;
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
          value: _checked,
          onChanged: widget.enabled
              ? (value) {
                  setState(() {
                    _checked = !_checked;
                    widget.onChanged(_checked);
                  });
                }
              : null,
        ),
      ),
    );
  }
}
