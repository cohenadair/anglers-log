import 'dart:async';

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
    required this.initialValue,
    required this.onDateRangePicked,
  });

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

    var pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: customValue.startDate,
        end: customValue.endDate,
      ),
      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
      lastDate: now,
      currentDate: now,
      confirmText: Strings.of(context).ok.toUpperCase(),
      cancelText: Strings.of(context).cancel.toUpperCase(),
      initialEntryMode: DatePickerEntryMode.input,
    );

    if (pickedRange == null) {
      return;
    }

    // Always add a day to the end date, so the end date is included. The
    // date range picker cuts the end date off at the beginning of the day. If
    // adding a day puts the end time in the future, clamp it to at "now".
    var endDate = pickedRange.end.add(Duration(days: 1));
    if (endDate.isAfter(now)) {
      endDate = now;
    }

    var dateRange = DateRange(
      startDate: pickedRange.start,
      endDate: endDate,
    );

    widget.onDateRangePicked(
      DisplayDateRange.newCustomFromDateRange(dateRange),
    );
  }
}
