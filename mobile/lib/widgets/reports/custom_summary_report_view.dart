import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/custom_summary_report_manager.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/model/custom_summary_report.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/reports/custom_report_view.dart';
import 'package:mobile/widgets/reports/report_summary.dart';
import 'package:quiver/strings.dart';

class CustomSummaryReportView extends StatefulWidget {
  final String reportId;

  CustomSummaryReportView(this.reportId) : assert(isNotEmpty(reportId));

  @override
  _CustomSummaryReportViewState createState() =>
      _CustomSummaryReportViewState();
}

class _CustomSummaryReportViewState extends State<CustomSummaryReportView> {
  final Log _log = Log("CustomSummaryReportView");

  AppManager get _appManager => AppManager.of(context);
  CustomSummaryReportManager get _summaryReportManager =>
      CustomSummaryReportManager.of(context);

  @override
  Widget build(BuildContext context) {
    return CustomReportView(
      reportId: widget.reportId,
      reportManager: _summaryReportManager,
      buildModels: _updateModels,
    );
  }

  List<ReportSummaryModel> _updateModels(CustomReport customReport) {
    if (!(customReport is CustomSummaryReport)) {
      _log.w("Can't build widget with invalid report type "
          "${customReport.toString()}");
      return [];
    }

    var report = customReport as CustomSummaryReport;
    return [
      ReportSummaryModel(
        appManager: _appManager,
        context: context,
        displayDateRange: DisplayDateRange.of(report.displayDateRangeId,
            report.startTimestamp, report.endTimestamp),
        baitIds: _summaryReportManager.baitIds(report.id),
        fishingSpotIds: _summaryReportManager.fishingSpotIds(report.id),
        speciesIds: _summaryReportManager.speciesIds(report.id),
      )
    ];
  }
}