import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../../comparison_report_manager.dart';
import '../../model/gen/anglerslog.pb.dart';
import '../../model/gen/google/protobuf/timestamp.pb.dart';
import '../../utils/date_time_utils.dart';
import '../../widgets/reports/report_summary.dart';
import '../../widgets/widget.dart';

class ComparisonReportView extends StatelessWidget {
  final Id reportId;

  ComparisonReportView(this.reportId) : assert(reportId != null);

  @override
  Widget build(BuildContext context) {
    var comparisonReportManager = ComparisonReportManager.of(context);

    var report = comparisonReportManager.entity(reportId);
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
    BuildContext context,
    ComparisonReport report,
  ) {
    var fromModel = _createModel(
      context,
      report,
      report.fromDisplayDateRangeId,
      report.fromStartTimestamp,
      report.fromEndTimestamp,
    );
    var toModel = _createModel(
      context,
      report,
      report.toDisplayDateRangeId,
      report.toStartTimestamp,
      report.toEndTimestamp,
    );
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
    Timestamp endTimestamp,
  ) {
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
