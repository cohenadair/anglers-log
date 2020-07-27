import 'package:flutter/material.dart';
import 'package:mobile/pages/date_range_picker_page.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/list_picker_input.dart';

class DateRangePickerInput extends StatefulWidget {
  final Key key;

  /// See [ListPickerInput.title].
  final String title;

  final DisplayDateRange initialDateRange;
  final void Function(DisplayDateRange) onPicked;

  DateRangePickerInput({
    this.key,
    this.title,
    this.initialDateRange,
    @required this.onPicked,
  }) : assert(onPicked != null),
       super(key: key);

  @override
  _DateRangePickerInputState createState() => _DateRangePickerInputState();
}

class _DateRangePickerInputState extends State<DateRangePickerInput> {
  DisplayDateRange _currentDateRange;

  @override
  void initState() {
    super.initState();
    _currentDateRange = widget.initialDateRange ?? DisplayDateRange.allDates;
  }

  @override
  Widget build(BuildContext context) {
    return ListPickerInput<DisplayDateRange>(
      title: widget.title,
      initialValues: Set.of([_currentDateRange]),
      value: _currentDateRange.title(context),
      onTap: () {
        push(context, DateRangePickerPage(
          initialValue: _currentDateRange,
          onDateRangePicked: (dateRange) {
            setState(() {
              _currentDateRange = dateRange;
            });
            widget.onPicked(dateRange);
            Navigator.of(context).pop();
          },
        ));
      },
    );
  }
}