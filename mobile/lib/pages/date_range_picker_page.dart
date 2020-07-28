import 'dart:async';

import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/utils/date_time_utils.dart';

/// A [ListPicker] wrapper widget for selecting a date range, such as the
/// "Last 7 days" or "This week" from a list.
class DateRangePickerPage extends StatefulWidget {
  final DisplayDateRange initialValue;
  final void Function(DisplayDateRange) onDateRangePicked;

  DateRangePickerPage({
    @required this.initialValue,
    @required this.onDateRangePicked
  }) : assert(initialValue != null),
       assert(onDateRangePicked != null);

  @override
  _DateRangePickerPageState createState() => _DateRangePickerPageState();
}

class _DateRangePickerPageState extends State<DateRangePickerPage> {
  DisplayDateRange _customDateRange = DisplayDateRange.custom;

  @override
  void initState() {
    super.initState();

    if (widget.initialValue == DisplayDateRange.custom) {
      _customDateRange = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PickerPage<DisplayDateRange>.single(
      title: Text(Strings.of(context).dateRangePickerPageTitle),
      initialValue: widget.initialValue,
      onFinishedPicking: (context, dateRange) =>
          widget.onDateRangePicked(dateRange),
      allItem: _buildItem(context, DisplayDateRange.allDates),
      itemBuilder: () => [
        PickerPageItem.divider(),
        _buildItem(context, DisplayDateRange.today),
        _buildItem(context, DisplayDateRange.yesterday),
        PickerPageItem.divider(),
        _buildItem(context, DisplayDateRange.thisWeek),
        _buildItem(context, DisplayDateRange.thisMonth),
        _buildItem(context, DisplayDateRange.thisYear),
        PickerPageItem.divider(),
        _buildItem(context, DisplayDateRange.lastWeek),
        _buildItem(context, DisplayDateRange.lastMonth),
        _buildItem(context, DisplayDateRange.lastYear),
        PickerPageItem.divider(),
        _buildItem(context, DisplayDateRange.last7Days),
        _buildItem(context, DisplayDateRange.last14Days),
        _buildItem(context, DisplayDateRange.last30Days),
        _buildItem(context, DisplayDateRange.last60Days),
        _buildItem(context, DisplayDateRange.last12Months),
        PickerPageItem.divider(),
        PickerPageItem<DisplayDateRange>(
          popsOnPicked: false,
          title: _customDateRange.title(context),
          onTap: () => _onTapCustom(context),
          value: _customDateRange,
        ),
      ],
    );
  }

  PickerPageItem<DisplayDateRange> _buildItem(BuildContext context,
      DisplayDateRange duration)
  {
    return PickerPageItem<DisplayDateRange>(
      title: duration.title(context),
      value: duration,
    );
  }

  Future<void> _onTapCustom(BuildContext context) async {
    DateTime now = DateTime.now();
    DateRange customValue = _customDateRange.getValue(now);

    List<DateTime> pickedRange = await DateRangePicker.showDatePicker(
      context: context,
      initialFirstDate: customValue.startDate,
      initialLastDate: customValue.endDate,
      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
      lastDate: now,
    );

    if (pickedRange == null) {
      return widget.initialValue;
    }

    DateTime endDate;
    if (pickedRange.first == pickedRange.last) {
      // If only the start date was picked, or the start and end time are equal,
      // set the end date to a range of 1 day.
      endDate = pickedRange.first.add(Duration(days: 1));
    }

    DateRange dateRange = DateRange(
      startDate: pickedRange.first,
      endDate: endDate ?? pickedRange.last,
    );

    widget.onDateRangePicked(DisplayDateRange.newCustom(
      getValue: (_) => dateRange,
      getTitle: (_) => formatDateRange(dateRange),
    ));
  }
}