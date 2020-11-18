import 'package:flutter/material.dart';
import 'package:mobile/comparison_report_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/overview_report.dart';
import 'package:mobile/summary_report_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/pages/report_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/reports/comparison_report_view.dart';
import 'package:mobile/widgets/reports/summary_report_view.dart';
import 'package:mobile/widgets/reports/overview_report_view.dart';
import 'package:mobile/widgets/widget.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  dynamic _currentReport = OverviewReport();

  ComparisonReportManager get _comparisonReportManager =>
      ComparisonReportManager.of(context);
  SummaryReportManager get _summaryReportManager =>
      SummaryReportManager.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildReportDropdown(),
      ),
      body: SingleChildScrollView(
        child: EntityListenerBuilder(
          managers: [
            _comparisonReportManager,
            _summaryReportManager,
          ],
          onUpdate: () => _updateCurrentReport(),
          builder: (context) => _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildReportDropdown() {
    return InkWell(
      onTap: () => present(
          context,
          ReportListPage.picker(
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
            _buildDropdownLabel(context),
            DropdownIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownLabel(BuildContext context) {
    if (_currentReport is OverviewReport) {
      return Text(_currentReport.title(context));
    } else {
      return Text(_currentReport.name);
    }
  }

  Widget _buildBody(BuildContext context) {
    if (_currentReport is OverviewReport) {
      return OverviewReportView();
    } else if (_currentReport is SummaryReport) {
      return SummaryReportView(_currentReport.id);
    } else {
      return ComparisonReportView(_currentReport.id);
    }
  }

  void _updateCurrentReport() {
    // If the current report no longer exists, show an overview.
    if (!_summaryReportManager.entityExists(_currentReport.id) &&
        !_comparisonReportManager.entityExists(_currentReport.id)) {
      setState(() {
        _currentReport = OverviewReport();
      });
    }
  }
}
