import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';
import 'input_controller.dart';

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
    required TimestampInputController controller,
    void Function(DateTime)? onChange,
    FormFieldValidator<DateTime>? validator,
    bool enabled = true,
  })  : assert(isNotEmpty(label)),
        super(
          initialValue: controller.date,
          validator: validator,
          builder: (state) {
            return _Picker(
              label: label,
              errorText: state.errorText,
              enabled: enabled,
              type: _PickerType(
                value: () {
                  return DateLabel(
                    controller.date,
                    enabled: enabled,
                  );
                },
                openPicker: () {
                  showDatePicker(
                    context: state.context,
                    initialDate: controller.date,
                    // Weird requirement of showDatePicker, but essentially
                    // let the user pick any date.
                    firstDate: DateTime(1900),
                    lastDate: DateTime(3000),
                  ).then((dateTime) {
                    if (dateTime == null) {
                      return;
                    }
                    controller.date = dateTime;
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
    required TimestampInputController controller,
    Function(TimeOfDay)? onChange,
    FormFieldValidator<TimeOfDay>? validator,
    bool enabled = true,
    EdgeInsets padding = insetsZero,
  })  : assert(isNotEmpty(label)),
        super(
          initialValue: controller.time,
          validator: validator,
          builder: (state) {
            return _Picker(
              label: label,
              errorText: state.errorText,
              enabled: enabled,
              padding: padding,
              type: _PickerType(
                value: () {
                  return TimeLabel(
                    controller.time,
                    enabled: enabled,
                  );
                },
                openPicker: () {
                  showTimePicker(
                    context: state.context,
                    initialTime: controller.time,
                  ).then((time) {
                    if (time == null) {
                      return;
                    }
                    controller.time = time;
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
  final Widget Function() value;
  final VoidCallback openPicker;

  _PickerType({
    required this.value,
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
                Expanded(child: type.value()),
                EnabledOpacity(
                  isEnabled: enabled,
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
