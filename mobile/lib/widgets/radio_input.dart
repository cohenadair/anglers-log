import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import '../res/style.dart';
import '../widgets/widget.dart';

/// A radio button selection widget. This should be used when three or fewer
/// options are available. Anything more, or for dynamic lists,
/// [ListPickerInput] should be used.
class RadioInput extends StatefulWidget {
  final String? title;
  final int optionCount;
  final String Function(BuildContext, int) optionBuilder;
  final void Function(int) onSelect;
  final int? initialSelectedIndex;
  final EdgeInsets? padding;

  const RadioInput({
    required this.optionCount,
    required this.optionBuilder,
    required this.onSelect,
    this.title,
    this.initialSelectedIndex = 0,
    this.padding,
  });

  @override
  RadioInputState createState() => RadioInputState();
}

class RadioInputState extends State<RadioInput> {
  late int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  @override
  void didUpdateWidget(RadioInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_selectedIndex != widget.initialSelectedIndex) {
      _selectedIndex = widget.initialSelectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: widget.padding?.top ?? 0,
        bottom: widget.padding?.bottom ?? 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isEmpty(widget.title)
              ? const Empty()
              : Padding(
                  padding: const EdgeInsets.only(
                    left: paddingDefault,
                    right: paddingDefault,
                    bottom: paddingSmall,
                  ),
                  child: Text(
                    widget.title!,
                    style: styleListHeading(context),
                  ),
                ),
          ...List<Widget>.generate(widget.optionCount, _buildOption),
        ],
      ),
    );
  }

  Widget _buildOption(int index) {
    var selected = _selectedIndex != null && _selectedIndex == index;
    var icon =
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked;

    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        widget.onSelect.call(index);
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: widget.padding?.left ?? 0,
          right: widget.padding?.right ?? 0,
          top: paddingSmall,
          bottom: paddingSmall,
        ),
        child: HorizontalSafeArea(
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: animDurationDefault,
                child: DefaultColorIcon(icon, key: ValueKey(selected)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: paddingXL),
                  child: Text(
                    widget.optionBuilder(context, index),
                    style: stylePrimary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
