import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

import '../app_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/picker_page.dart';
import '../time_manager.dart';
import '../utils/protobuf_utils.dart';

/// A [ListPicker] wrapper widget for selecting a date range, such as the
/// "Last 7 days" or "This week" from a list.
class DateRangePickerPage extends StatefulWidget {
  final DateRange initialValue;
  final void Function(DateRange) onDateRangePicked;

  const DateRangePickerPage({
    required this.initialValue,
    required this.onDateRangePicked,
  });

  @override
  DateRangePickerPageState createState() => DateRangePickerPageState();
}

class DateRangePickerPageState extends State<DateRangePickerPage> {
  DateRange _customDateRange = DateRange(period: DateRange_Period.custom);

  TimeManager get _timeManager => AppManager.of(context).timeManager;

  @override
  void initState() {
    super.initState();

    if (widget.initialValue.period == DateRange_Period.custom) {
      _customDateRange = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PickerPage<DateRange>.single(
      title: Text(Strings.of(context).pickerTitleDateRange),
      initialValue: widget.initialValue,
      onFinishedPicking: (context, dateRange) =>
          widget.onDateRangePicked(dateRange),
      allItem: _buildItem(context, DateRange_Period.allDates),
      itemBuilder: () => [
        _buildItem(context, DateRange_Period.today),
        _buildItem(context, DateRange_Period.yesterday),
        PickerPageItem.divider(),
        _buildItem(context, DateRange_Period.thisWeek),
        _buildItem(context, DateRange_Period.thisMonth),
        _buildItem(context, DateRange_Period.thisYear),
        PickerPageItem.divider(),
        _buildItem(context, DateRange_Period.lastWeek),
        _buildItem(context, DateRange_Period.lastMonth),
        _buildItem(context, DateRange_Period.lastYear),
        PickerPageItem.divider(),
        _buildItem(context, DateRange_Period.last7Days),
        _buildItem(context, DateRange_Period.last14Days),
        _buildItem(context, DateRange_Period.last30Days),
        _buildItem(context, DateRange_Period.last60Days),
        _buildItem(context, DateRange_Period.last12Months),
        PickerPageItem.divider(),
        PickerPageItem<DateRange>(
          isFinishedOnTap: false,
          title: _customDateRange.displayName(context),
          onTap: () => _onTapCustom(context),
          value: _customDateRange,
        ),
      ],
    );
  }

  PickerPageItem<DateRange> _buildItem(
    BuildContext context,
    DateRange_Period period,
  ) {
    var value = DateRange()..period = period;
    return PickerPageItem<DateRange>(
      title: value.displayName(context),
      value: value,
    );
  }

  Future<void> _onTapCustom(BuildContext context) async {
    var now = _timeManager.currentDateTime;

    var pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: _customDateRange.startDate(now),
        end: _customDateRange.endDate(now),
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
    var endDate = pickedRange.end.add(const Duration(days: 1));
    if (endDate.isAfter(now)) {
      endDate = now;
    }

    widget.onDateRangePicked(DateRange()
      ..period = DateRange_Period.custom
      ..startTimestamp = Int64(pickedRange.start.millisecondsSinceEpoch)
      ..endTimestamp = Int64(endDate.millisecondsSinceEpoch)
      ..timeZone = _timeManager.currentTimeZone);
  }
}
