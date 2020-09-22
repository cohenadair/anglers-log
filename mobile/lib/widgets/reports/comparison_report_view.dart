import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/comparison_report_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/gen/google/protobuf/timestamp.pb.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/reports/pb_report_view.dart';
import 'package:mobile/widgets/reports/report_summary.dart';

class ComparisonReportView extends StatefulWidget {
  final Id reportId;

  ComparisonReportView(this.reportId) : assert(reportId != null);

  @override
  _ComparisonReportViewState createState() => _ComparisonReportViewState();
}

class _ComparisonReportViewState extends State<ComparisonReportView> {
  AppManager get _appManager => AppManager.of(context);
  ComparisonReportManager get _summaryReportManager =>
      ComparisonReportManager.of(context);

  @override
  Widget build(BuildContext context) {
    return PbReportView<ComparisonReport>(
      reportId: widget.reportId,
      reportManager: _summaryReportManager,
      buildModels: _updateModels,
      buildDescription: (report) => report.description,
    );
  }

  List<ReportSummaryModel> _updateModels(ComparisonReport report) {
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

  ReportSummaryModel _createModel(ComparisonReport report,
      String displayDateRangeId, Timestamp startTimestamp,
      Timestamp endTimestamp)
  {
    return ReportSummaryModel(
      appManager: _appManager,
      context: context,
      includeZeros: true,
      sortOrder: ReportSummaryModelSortOrder.alphabetical,
      displayDateRange: DisplayDateRange.of(displayDateRangeId, startTimestamp,
          endTimestamp),
      baitIds: report.baitIds.toSet(),
      fishingSpotIds: report.fishingSpotIds.toSet(),
      speciesIds: report.speciesIds.toSet(),
    );
  }
}