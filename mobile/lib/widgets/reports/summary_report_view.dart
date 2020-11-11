import 'package:flutter/material.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/summary_report_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/reports/report_summary.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class SummaryReportView extends StatelessWidget {
  final Id reportId;

  SummaryReportView(this.reportId) : assert(reportId != null);

  @override
  Widget build(BuildContext context) {
    SummaryReportManager summaryReportManager =
        SummaryReportManager.of(context);

    SummaryReport report = summaryReportManager.entity(reportId);
    if (report == null) {
      return Empty();
    }

    return ReportSummary(
      managers: [summaryReportManager],
      onUpdate: () => _updateModels(context, report),
      descriptionBuilder: (context) => isEmpty(report?.description)
          ? null : report?.description,
    );
  }

  List<ReportSummaryModel> _updateModels(BuildContext context,
      SummaryReport report)
  {
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