import 'package:flutter/material.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/date_range_picker_input.dart';
import 'package:mobile/widgets/reports/report_summary.dart';

class OverviewReportView extends StatefulWidget {
  @override
  _OverviewReportViewState createState() => _OverviewReportViewState();
}

class _OverviewReportViewState extends State<OverviewReportView> {
  DisplayDateRange _currentDateRange =
      DisplayDateRange.of(DisplayDateRange.allDates.id);

  @override
  Widget build(BuildContext context) {
    return ReportSummary(
      onUpdate: () => [
        ReportSummaryModel(
          context: context,
          displayDateRange: _currentDateRange,
        ),
      ],
      headerBuilder: (context) => _buildDurationPicker(),
    );
  }

  Widget _buildDurationPicker() => DateRangePickerInput(
    initialDateRange: _currentDateRange,
    onPicked: (dateRange) => setState(() {
      _currentDateRange = dateRange;
    }),
  );
}