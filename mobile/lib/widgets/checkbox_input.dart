import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import '../res/style.dart';
import '../widgets/list_item.dart';
import '../widgets/text.dart';
import 'widget.dart';

class CheckboxInput extends StatelessWidget {
  final String label;
  final String? description;
  final bool value;
  final bool enabled;
  final void Function(bool)? onChanged;

  CheckboxInput({
    required this.label,
    this.description,
    this.value = false,
    this.enabled = true,
    this.onChanged,
  }) : assert(isNotEmpty(label));

  Widget build(BuildContext context) {
    Widget descriptionWidget = Empty();
    if (isNotEmpty(description)) {
      descriptionWidget = Text(
        description!,
        style: styleSubtitle(context, enabled: enabled),
        overflow: TextOverflow.visible,
      );
    }

    return ListItem(
      title: enabled ? Text(label) : DisabledLabel(label),
      subtitle: descriptionWidget,
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
  final void Function(bool)? onChanged;

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
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.checked;
  }

  @override
  void didUpdateWidget(PaddedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_checked != widget.checked) {
      _checked = widget.checked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return EnabledOpacity(
      enabled: widget.enabled,
      child: Padding(
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
                      widget.onChanged?.call(_checked);
                    });
                  }
                : null,
          ),
        ),
      ),
    );
  }
}
