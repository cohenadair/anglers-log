import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:adair_flutter_lib/utils/date_range.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:flutter/material.dart';

import '../pages/date_range_picker_page.dart';
import '../widgets/list_picker_input.dart';

class DateRangePickerInput extends StatefulWidget {
  /// See [ListPickerInput.title].
  final String? title;

  final DateRange? initialDateRange;
  final void Function(DateRange) onPicked;

  const DateRangePickerInput({
    super.key,
    this.title,
    this.initialDateRange,
    required this.onPicked,
  });

  @override
  DateRangePickerInputState createState() => DateRangePickerInputState();
}

class DateRangePickerInputState extends State<DateRangePickerInput> {
  late DateRange _currentDateRange;

  @override
  void initState() {
    super.initState();
    _currentDateRange =
        widget.initialDateRange ??
        DateRange(
          period: DateRange_Period.allDates,
          timeZone: TimeManager.get.currentTimeZone,
        );
  }

  @override
  Widget build(BuildContext context) {
    return ListPickerInput(
      title: widget.title,
      value: _currentDateRange.displayName,
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
