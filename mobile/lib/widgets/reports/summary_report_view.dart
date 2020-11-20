import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../../model/gen/anglerslog.pb.dart';
import '../../summary_report_manager.dart';
import '../../utils/date_time_utils.dart';
import '../../widgets/reports/report_summary.dart';
import '../../widgets/widget.dart';

class SummaryReportView extends StatelessWidget {
  final Id reportId;

  SummaryReportView(this.reportId) : assert(reportId != null);

  @override
  Widget build(BuildContext context) {
    var summaryReportManager =
        SummaryReportManager.of(context);

    var report = summaryReportManager.entity(reportId);
    if (report == null) {
      return Empty();
    }

    return ReportSummary(
      managers: [summaryReportManager],
      onUpdate: () => _updateModels(context, report),
      descriptionBuilder: (context) =>
          isEmpty(report?.description) ? null : report?.description,
    );
  }

  List<ReportSummaryModel> _updateModels(
      BuildContext context, SummaryReport report) {
    return [
      ReportSummaryModel(
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
