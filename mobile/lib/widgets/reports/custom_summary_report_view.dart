import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/custom_summary_report_manager.dart';
import 'package:mobile/model/custom_summary_report.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/reports/report_summary.dart';
import 'package:mobile/widgets/reports/report_view.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class CustomSummaryReportView extends StatefulWidget {
  final String reportId;

  CustomSummaryReportView(this.reportId) : assert(isNotEmpty(reportId));

  @override
  _CustomSummaryReportViewState createState() =>
      _CustomSummaryReportViewState();
}

class _CustomSummaryReportViewState extends State<CustomSummaryReportView> {
  CustomSummaryReport _report;
  ReportSummaryModel _model;

  AppManager get _appManager => AppManager.of(context);
  CustomSummaryReportManager get _summaryReportManager =>
      CustomSummaryReportManager.of(context);

  @override
  void initState() {
    super.initState();
    _updateModel();
  }

  @override
  void didUpdateWidget(CustomSummaryReportView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reportId != widget.reportId) {
      _updateModel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReportSummary(
      managers: [
        _summaryReportManager,
      ],
      onUpdate: _updateModel,
      headerBuilder: (context) => _buildDescription(),
    );
  }

  Widget _buildDescription() {
    if (!_report.hasDescription) {
      return Empty();
    }
    return Padding(
      padding: insetsDefault,
      child: Label.multiline(
        _report.description,
      ),
    );
  }

  ReportSummaryModel _updateModel() {
    if (!_summaryReportManager.entityExists(id: widget.reportId)) {
      return _model;
    }

    _report = _summaryReportManager.entity(id: widget.reportId);
    _model = ReportSummaryModel(
      appManager: _appManager,
      context: context,
      displayDateRange: DisplayDateRange.of(_report.displayDateRangeId,
          _report.startTimestamp, _report.endTimestamp),
      baitIds: _summaryReportManager.baitIds(_report.id),
      fishingSpotIds: _summaryReportManager.fishingSpotIds(_report.id),
      speciesIds: _summaryReportManager.speciesIds(_report.id),
    );

    return _model;
  }
}