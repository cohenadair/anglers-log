import 'package:flutter/material.dart';
import 'package:mobile/comparison_report_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/gen/google/protobuf/timestamp.pb.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/reports/report_summary.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class ComparisonReportView extends StatelessWidget {
  final Id reportId;

  ComparisonReportView(this.reportId) : assert(reportId != null);

  @override
  Widget build(BuildContext context) {
    ComparisonReportManager comparisonReportManager =
        ComparisonReportManager.of(context);

    ComparisonReport report = comparisonReportManager.entity(reportId);
    if (report == null) {
      return Empty();
    }

    return ReportSummary(
      managers: [comparisonReportManager],
      onUpdate: () => _updateModels(context, report),
      descriptionBuilder: (context) =>
          isEmpty(report?.description) ? null : report?.description,
    );
  }

  List<ReportSummaryModel> _updateModels(
      BuildContext context, ComparisonReport report) {
    ReportSummaryModel fromModel = _createModel(
        context,
        report,
        report.fromDisplayDateRangeId,
        report.fromStartTimestamp,
        report.fromEndTimestamp);
    ReportSummaryModel toModel = _createModel(
        context,
        report,
        report.toDisplayDateRangeId,
        report.toStartTimestamp,
        report.toEndTimestamp);
    fromModel.removeZerosComparedTo(toModel);

    return [
      fromModel,
      toModel,
    ];
  }

  ReportSummaryModel _createModel(
      BuildContext context,
      ComparisonReport report,
      String displayDateRangeId,
      Timestamp startTimestamp,
      Timestamp endTimestamp) {
    return ReportSummaryModel(
      context: context,
      includeZeros: true,
      sortOrder: ReportSummaryModelSortOrder.alphabetical,
      displayDateRange:
          DisplayDateRange.of(displayDateRangeId, startTimestamp, endTimestamp),
      baitIds: report.baitIds.toSet(),
      fishingSpotIds: report.fishingSpotIds.toSet(),
      speciesIds: report.speciesIds.toSet(),
    );
  }
}
