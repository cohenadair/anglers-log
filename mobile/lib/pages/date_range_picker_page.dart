import 'dart:async';

import 'package:date_range_picker/date_range_picker.dart' as date_range_picker;
import 'package:flutter/material.dart';

import '../app_manager.dart';
import '../i18n/strings.dart';
import '../pages/picker_page.dart';
import '../time_manager.dart';
import '../utils/date_time_utils.dart';

/// A [ListPicker] wrapper widget for selecting a date range, such as the
/// "Last 7 days" or "This week" from a list.
class DateRangePickerPage extends StatefulWidget {
  final DisplayDateRange initialValue;
  final void Function(DisplayDateRange) onDateRangePicked;

  DateRangePickerPage({
    @required this.initialValue,
    @required this.onDateRangePicked,
  })  : assert(initialValue != null),
        assert(onDateRangePicked != null);

  @override
  _DateRangePickerPageState createState() => _DateRangePickerPageState();
}

class _DateRangePickerPageState extends State<DateRangePickerPage> {
  DisplayDateRange _customDateRange = DisplayDateRange.custom;

  TimeManager get _timeManager => AppManager.of(context).timeManager;

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

  PickerPageItem<DisplayDateRange> _buildItem(
    BuildContext context,
    DisplayDateRange duration,
  ) {
    return PickerPageItem<DisplayDateRange>(
      title: duration.title(context),
      value: duration,
    );
  }

  Future<void> _onTapCustom(BuildContext context) async {
    var now = _timeManager.currentDateTime;
    var customValue = _customDateRange.getValue(now);

    var pickedRange = await date_range_picker.showDatePicker(
      context: context,
      initialFirstDate: customValue.startDate,
      initialLastDate: customValue.endDate,
      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
      lastDate: now,
    );

    if (pickedRange == null) {
      return;
    }

    DateTime endDate;
    if (pickedRange.first == pickedRange.last) {
      // If only the start date was picked, or the start and end time are equal,
      // set the end date to a range of 1 day.
      endDate = pickedRange.first.add(Duration(days: 1));
    }

    var dateRange = DateRange(
      startDate: pickedRange.first,
      endDate: endDate ?? pickedRange.last,
    );

    widget.onDateRangePicked(
      DisplayDateRange.newCustomFromDateRange(dateRange),
    );
  }
}
