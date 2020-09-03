import 'package:flutter/material.dart';
import 'package:mobile/custom_report_manager.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/widgets/reports/report_summary.dart';
import 'package:quiver/strings.dart';

class CustomReportView extends StatefulWidget {
  final String reportId;
  final CustomReportManager reportManager;
  final List<ReportSummaryModel> Function(CustomReport) buildModels;

  CustomReportView({
    this.reportId,
    this.reportManager,
    this.buildModels,
  }) : assert(isNotEmpty(reportId)),
       assert(reportManager != null),
       assert(buildModels != null);

  @override
  _CustomReportViewState createState() => _CustomReportViewState();
}

class _CustomReportViewState extends State<CustomReportView> {
  CustomReport _report;
  List<ReportSummaryModel> _models = [];

  @override
  void initState() {
    super.initState();
    _updateModels();
  }

  @override
  void didUpdateWidget(CustomReportView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reportId != widget.reportId) {
      _updateModels();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReportSummary(
      managers: [widget.reportManager],
      onUpdate: _updateModels,
      descriptionBuilder: (context) => _report.description,
    );
  }

  List<ReportSummaryModel> _updateModels() {
    if (!widget.reportManager.entityExists(id: widget.reportId)) {
      return _models;
    }

    _report = widget.reportManager.entity(id: widget.reportId);
    _models = widget.buildModels(_report);

    return _models;
  }
}