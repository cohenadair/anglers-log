import 'package:flutter/material.dart';

import '../model/gen/anglerslog.pb.dart';
import '../pages/date_range_picker_page.dart';
import '../time_manager.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/list_picker_input.dart';

class DateRangePickerInput extends StatefulWidget {
  /// See [ListPickerInput.title].
  final String? title;

  final DateRange? initialDateRange;
  final void Function(DateRange) onPicked;

  const DateRangePickerInput({
    Key? key,
    this.title,
    this.initialDateRange,
    required this.onPicked,
  }) : super(key: key);

  @override
  DateRangePickerInputState createState() => DateRangePickerInputState();
}

class DateRangePickerInputState extends State<DateRangePickerInput> {
  late DateRange _currentDateRange;

  TimeManager get _timeManager => TimeManager.of(context);

  @override
  void initState() {
    super.initState();
    _currentDateRange = widget.initialDateRange ??
        DateRange(
          period: DateRange_Period.allDates,
          timeZone: _timeManager.currentTimeZone,
        );
  }

  @override
  Widget build(BuildContext context) {
    return ListPickerInput(
      title: widget.title,
      value: _currentDateRange.displayName(context),
      onTap: () {
        push(
          context,
          DateRangePickerPage(
            initialValue: _currentDateRange,
            onDateRangePicked: (dateRange) {
              setState(() {
                _currentDateRange = dateRange;
              });
              widget.onPicked(dateRange);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}
