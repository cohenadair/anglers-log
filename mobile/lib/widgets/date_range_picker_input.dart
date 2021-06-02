import 'package:flutter/material.dart';

import '../model/gen/anglerslog.pb.dart';
import '../pages/date_range_picker_page.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/list_picker_input.dart';

class DateRangePickerInput extends StatefulWidget {
  final Key? key;

  /// See [ListPickerInput.title].
  final String? title;

  final DateRange? initialDateRange;
  final void Function(DateRange) onPicked;

  DateRangePickerInput({
    this.key,
    this.title,
    this.initialDateRange,
    required this.onPicked,
  }) : super(key: key);

  @override
  _DateRangePickerInputState createState() => _DateRangePickerInputState();
}

class _DateRangePickerInputState extends State<DateRangePickerInput> {
  late DateRange _currentDateRange;

  @override
  void initState() {
    super.initState();
    _currentDateRange =
        widget.initialDateRange ?? DateRange(period: DateRange_Period.allDates);
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
