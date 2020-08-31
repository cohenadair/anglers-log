import 'package:flutter/material.dart';
import 'package:mobile/custom_comparison_report_manager.dart';
import 'package:mobile/custom_summary_report_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/custom_comparison_report.dart';
import 'package:mobile/model/custom_summary_report.dart';
import 'package:mobile/model/overview_report.dart';
import 'package:mobile/model/report.dart';
import 'package:mobile/pages/report_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/reports/custom_comparison_report_view.dart';
import 'package:mobile/widgets/reports/custom_summary_report_view.dart';
import 'package:mobile/widgets/reports/overview_report_view.dart';
import 'package:mobile/widgets/widget.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Report _currentReport = OverviewReport();

  CustomComparisonReportManager get _customComparisonReportManager =>
      CustomComparisonReportManager.of(context);
  CustomSummaryReportManager get _customSummaryReportManager =>
      CustomSummaryReportManager.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildReportDropdown(),
      ),
      body: SingleChildScrollView(
        child: EntityListenerBuilder(
          managers: [
            _customComparisonReportManager,
            _customSummaryReportManager,
          ],
          onUpdate: () => _updateCurrentReport(),
          builder: (context) => _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildReportDropdown() {
    return InkWell(
      onTap: () => present(context, ReportListPage.picker(
        currentItem: _currentReport,
        onPicked: (context, report) {
          if (report != _currentReport) {
            setState(() {
              _currentReport = report;
            });
          }
          return true;
        },
      )),
      child: Padding(
        padding: insetsVerticalDefault,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_currentReport.title(context)),
            DropdownIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_currentReport is OverviewReport) {
      return OverviewReportView();
    } else if (_currentReport is CustomSummaryReport) {
      return CustomSummaryReportView(_currentReport.id);
    } else {
      return CustomComparisonReportView(_currentReport.id);
    }
  }

  void _updateCurrentReport() {
    // If the current report no longer exists, show an overview.
    if ((_currentReport is CustomSummaryReport
        && !_customSummaryReportManager.entityExists(id: _currentReport.id))
        || (_currentReport is CustomComparisonReport
            && !_customComparisonReportManager
                .entityExists(id: _currentReport.id)))
    {
        _currentReport = OverviewReport();
    }
  }
}

