import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/widgets/padded_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:mobile/pages/anglers_log_pro_page.dart';
import 'package:quiver/strings.dart';

import '../res/style.dart';
import '../widgets/list_item.dart';
import '../widgets/text.dart';

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
      value: SubscriptionManager.get.isPro && _isChecked,
      leading: widget.leading,
      padding: widget.padding,
      onChanged: (checked) {
        if (SubscriptionManager.get.isPro && checked) {
          _setIsChecked(true);
        } else if (checked) {
          // Uncheck, since user isn't Pro.
          _setIsChecked(false);
          present(context, const AnglersLogProPage());
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
    Widget descriptionWidget = const SizedBox();
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
        isChecked: value,
        isEnabled: enabled,
        onChanged: onChanged,
      ),
    );
  }
}
