import 'package:flutter/material.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/widgets/reports/report_summary.dart';
import 'package:protobuf/protobuf.dart';

class PbReportView<T extends GeneratedMessage> extends StatefulWidget {
  final Id reportId;
  final ReportManager reportManager;
  final List<ReportSummaryModel> Function(T) buildModels;
  final String Function(T) buildDescription;

  PbReportView({
    @required this.reportId,
    @required this.reportManager,
    @required this.buildModels,
    @required this.buildDescription,
  }) : assert(reportId != null),
       assert(reportManager != null),
       assert(buildModels != null),
       assert(buildDescription != null);

  @override
  _PbReportViewState createState() => _PbReportViewState();
}

class _PbReportViewState<T extends GeneratedMessage>
    extends State<PbReportView<T>>
{
  T _report;
  List<ReportSummaryModel> _models = [];

  @override
  void initState() {
    super.initState();
    _updateModels();
  }

  @override
  void didUpdateWidget(PbReportView oldWidget) {
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
      descriptionBuilder: (context) => widget.buildDescription(_report),
    );
  }

  List<ReportSummaryModel> _updateModels() {
    if (!widget.reportManager.entityExists(widget.reportId)) {
      return _models;
    }

    _report = widget.reportManager.entity(widget.reportId);
    _models = widget.buildModels(_report);

    return _models;
  }
}