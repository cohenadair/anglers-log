import 'package:flutter/material.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import '../res/style.dart';
import '../widgets/list_item.dart';
import '../widgets/text.dart';
import 'widget.dart';

class ProCheckboxInput extends StatefulWidget {
  final String label;
  final String? description;
  final bool value;
  final Widget? leading;
  final EdgeInsets? padding;
  final void Function(bool) onSetValue;

  const ProCheckboxInput({
    required this.label,
    this.description,
    required this.value,
    this.leading,
    this.padding,
    required this.onSetValue,
  });

  @override
  State<ProCheckboxInput> createState() => _ProCheckboxInputState();
}

class _ProCheckboxInputState extends State<ProCheckboxInput> {
  var _isChecked = false;

  SubscriptionManager get _subscriptionManager =>
      SubscriptionManager.of(context);

  @override
  void initState() {
    super.initState();
    _isChecked = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxInput(
      label: widget.label,
      description: widget.description,
      value: _subscriptionManager.isPro && _isChecked,
      leading: widget.leading,
      padding: widget.padding,
      onChanged: (checked) {
        if (_subscriptionManager.isPro && checked) {
          _setIsChecked(true);
        } else if (checked) {
          // Uncheck, since user isn't Pro.
          _setIsChecked(false);
          present(context, const ProPage());
        } else {
          _setIsChecked(false);
        }
      },
    );
  }

  void _setIsChecked(bool isChecked) {
    setState(() {
      _isChecked = isChecked;
      widget.onSetValue(isChecked);
    });
  }
}

class CheckboxInput extends StatelessWidget {
  final String label;
  final String? description;
  final bool value;
  final bool enabled;
  final Widget? leading;
  final EdgeInsets? padding;
  final void Function(bool)? onChanged;

  CheckboxInput({
    required this.label,
    this.description,
    this.value = false,
    this.enabled = true,
    this.leading,
    this.padding,
    this.onChanged,
  }) : assert(isNotEmpty(label));

  @override
  Widget build(BuildContext context) {
    Widget descriptionWidget = const Empty();
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
      leading: leading,
      padding: padding,
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

  const PaddedCheckbox({
    this.checked = false,
    this.enabled = true,
    this.padding = insetsZero,
    this.onChanged,
  });

  @override
  PaddedCheckboxState createState() => PaddedCheckboxState();
}

class PaddedCheckboxState extends State<PaddedCheckbox> {
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
      isEnabled: widget.enabled,
      child: Padding(
        padding: widget.padding,
        child: SizedBox(
          width: checkboxSizeDefault,
          height: checkboxSizeDefault,
          child: Checkbox(
            activeColor: context.colorDefault,
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
