import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import '../time_manager.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';

/// A container for separate date and time pickers. Renders a horizontal [Flex]
/// widget with a 3:2 ratio for [DatePicker] and [TimePicker] respectively.
class DateTimePicker extends StatelessWidget {
  final DatePicker datePicker;
  final TimePicker timePicker;
  final Widget? helper;

  DateTimePicker({
    required this.datePicker,
    required this.timePicker,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flex(
          crossAxisAlignment: CrossAxisAlignment.start,
          direction: Axis.horizontal,
          children: <Widget>[
            Flexible(
              flex: 3,
              child: SafeArea(
                right: false,
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: paddingDefault,
                    right: paddingWidget,
                  ),
                  child: datePicker,
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: SafeArea(
                left: false,
                bottom: false,
                child: Padding(
                  padding: insetsRightDefault,
                  child: timePicker,
                ),
              ),
            ),
          ],
        ),
        helper == null
            ? Empty()
            : Padding(
                padding: insetsTopSmall,
                child: helper,
              ),
      ],
    );
  }
}

class DatePicker extends FormField<DateTime> {
  DatePicker(
    BuildContext context, {
    required String label,
    DateTime? initialDate,
    void Function(DateTime)? onChange,
    FormFieldValidator<DateTime>? validator,
    bool enabled = true,
  })  : assert(isNotEmpty(label)),
        super(
          initialValue: initialDate ?? TimeManager.of(context).currentDateTime,
          validator: validator,
          builder: (state) {
            return _Picker(
              label: label,
              errorText: state.errorText,
              enabled: enabled,
              type: _PickerType(
                getValue: () {
                  return DateLabel(
                    state.value!,
                    enabled: enabled,
                  );
                },
                openPicker: () {
                  showDatePicker(
                    context: state.context,
                    initialDate: state.value!,
                    // Weird requirement of showDatePicker, but essentially
                    // let the user pick any date.
                    firstDate: DateTime(1900),
                    lastDate: DateTime(3000),
                  ).then((dateTime) {
                    if (dateTime == null) {
                      return;
                    }
                    state.didChange(dateTime);
                    onChange?.call(dateTime);
                  });
                },
              ),
            );
          },
        );
}

class TimePicker extends FormField<TimeOfDay> {
  TimePicker(
    BuildContext context, {
    required String label,
    TimeOfDay? initialTime,
    Function(TimeOfDay)? onChange,
    FormFieldValidator<TimeOfDay>? validator,
    bool enabled = true,
    EdgeInsets padding = insetsZero,
  })  : assert(isNotEmpty(label)),
        super(
          initialValue: initialTime ?? TimeManager.of(context).currentTime,
          validator: validator,
          builder: (state) {
            return _Picker(
              label: label,
              errorText: state.errorText,
              enabled: enabled,
              padding: padding,
              type: _PickerType(
                getValue: () {
                  return TimeLabel(
                    state.value!,
                    enabled: enabled,
                  );
                },
                openPicker: () {
                  showTimePicker(
                    context: state.context,
                    initialTime: state.value!,
                  ).then((time) {
                    if (time == null) {
                      return;
                    }
                    state.didChange(time);
                    onChange?.call(time);
                  });
                },
              ),
            );
          },
        );
}

class _PickerType {
  final Widget Function() getValue;
  final VoidCallback openPicker;

  _PickerType({
    required this.getValue,
    required this.openPicker,
  });
}

class _Picker extends StatelessWidget {
  final _PickerType type;
  final String label;
  final String? errorText;
  final bool enabled;
  final EdgeInsets padding;

  _Picker({
    required this.type,
    required this.label,
    this.errorText,
    this.enabled = true,
    this.padding = insetsZero,
  }) : assert(isNotEmpty(label));

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? type.openPicker : null,
      child: HorizontalSafeArea(
        child: Padding(
          padding: padding,
          child: InputDecorator(
            decoration: InputDecoration(
              enabled: enabled,
              labelText: label,
              errorText: errorText,
              errorMaxLines: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(child: type.getValue()),
                EnabledOpacity(
                  enabled: enabled,
                  child: DropdownIcon(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
