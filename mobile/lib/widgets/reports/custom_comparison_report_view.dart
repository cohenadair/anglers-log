import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/custom_comparison_report_manager.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/custom_comparison_report.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/reports/custom_report_view.dart';
import 'package:mobile/widgets/reports/report_summary.dart';
import 'package:quiver/strings.dart';

class CustomComparisonReportView extends StatefulWidget {
  final String reportId;

  CustomComparisonReportView(this.reportId) : assert(isNotEmpty(reportId));

  @override
  _CustomComparisonReportViewState createState() =>
      _CustomComparisonReportViewState();
}

class _CustomComparisonReportViewState
    extends State<CustomComparisonReportView>
{
  final Log _log = Log("CustomComparisonReportView");

  AppManager get _appManager => AppManager.of(context);
  CustomComparisonReportManager get _summaryReportManager =>
      CustomComparisonReportManager.of(context);

  @override
  Widget build(BuildContext context) {
    return CustomReportView(
      reportId: widget.reportId,
      reportManager: _summaryReportManager,
      buildModels: _updateModels,
    );
  }

  List<ReportSummaryModel> _updateModels(CustomReport customReport) {
    if (!(customReport is CustomComparisonReport)) {
      _log.w("Can't build widget with invalid report type "
          "${customReport.toString()}");
      return [];
    }

    var report = customReport as CustomComparisonReport;
    ReportSummaryModel fromModel = _createModel(report,
        report.fromDisplayDateRangeId, report.fromStartTimestamp,
        report.fromEndTimestamp);
    ReportSummaryModel toModel = _createModel(report,
        report.toDisplayDateRangeId, report.toStartTimestamp,
        report.toEndTimestamp);
    fromModel.removeZerosComparedTo(toModel);

    return [
      fromModel,
      toModel,
    ];
  }

  ReportSummaryModel _createModel(CustomComparisonReport report,
      String displayDateRangeId, int startTimestamp, int endTimestamp)
  {
    return ReportSummaryModel(
      appManager: _appManager,
      context: context,
      includeZeros: true,
      sortOrder: ReportSummaryModelSortOrder.alphabetical,
      displayDateRange: DisplayDateRange.of(displayDateRangeId, startTimestamp,
          endTimestamp),
      baitIds: _summaryReportManager.baitIds(report.id),
      fishingSpotIds: _summaryReportManager.fishingSpotIds(report.id),
      speciesIds: _summaryReportManager.speciesIds(report.id),
    );
  }
}