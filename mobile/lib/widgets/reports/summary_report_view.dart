import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/summary_report_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/reports/pb_report_view.dart';
import 'package:mobile/widgets/reports/report_summary.dart';

class SummaryReportView extends StatefulWidget {
  final Id reportId;

  SummaryReportView(this.reportId) : assert(reportId != null);

  @override
  _SummaryReportViewState createState() =>
      _SummaryReportViewState();
}

class _SummaryReportViewState extends State<SummaryReportView> {
  AppManager get _appManager => AppManager.of(context);
  SummaryReportManager get _summaryReportManager =>
      SummaryReportManager.of(context);

  @override
  Widget build(BuildContext context) {
    return PbReportView<SummaryReport>(
      reportId: widget.reportId,
      reportManager: _summaryReportManager,
      buildModels: _updateModels,
      buildDescription: (report) => report.description,
    );
  }

  List<ReportSummaryModel> _updateModels(SummaryReport report) {
    return [
      ReportSummaryModel(
        appManager: _appManager,
        context: context,
        displayDateRange: DisplayDateRange.of(report.displayDateRangeId,
            report.startTimestamp, report.endTimestamp),
        baitIds: report.baitIds.toSet(),
        fishingSpotIds: report.fishingSpotIds.toSet(),
        speciesIds: report.speciesIds.toSet(),
      )
    ];
  }
}