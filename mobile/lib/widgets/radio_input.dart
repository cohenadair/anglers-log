import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';

/// A radio button selection widget. This should be used when three or fewer
/// options are available. Anything more, or for dynamic lists,
/// [ListPickerInput] should be used.
class RadioInput extends StatefulWidget {
  final String? title;
  final int optionCount;
  final String Function(BuildContext, int) optionBuilder;
  final void Function(int) onSelect;
  final int initialSelectedIndex;
  final EdgeInsets? padding;

  RadioInput({
    required this.optionCount,
    required this.optionBuilder,
    required this.onSelect,
    this.title,
    this.initialSelectedIndex = 0,
    this.padding,
  });

  @override
  _RadioInputState createState() => _RadioInputState();
}

class _RadioInputState extends State<RadioInput> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? insetsZero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isEmpty(widget.title)
              ? Empty()
              : Padding(
                  padding: EdgeInsets.only(
                    left: paddingDefault,
                    right: paddingDefault,
                    bottom: paddingWidgetSmall,
                  ),
                  child: HeadingLabel(widget.title!),
                ),
        ]..addAll(List<Widget>.generate(widget.optionCount, _buildOption)),
      ),
    );
  }

  Widget _buildOption(int index) {
    var selected = _selectedIndex == index;
    var icon =
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked;

    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        widget.onSelect.call(index);
      },
      child: Padding(
        padding: insetsVerticalWidgetSmall,
        child: HorizontalSafeArea(
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: defaultAnimationDuration,
                child: Icon(icon, key: ValueKey(selected)),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: paddingWidgetDouble),
                  child: PrimaryLabel(widget.optionBuilder(context, index)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
