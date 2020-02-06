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