import 'package:flutter/material.dart';
import 'package:mobile/model/overview_report.dart';
import 'package:mobile/model/report.dart';
import 'package:mobile/pages/report_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/overview_report_view.dart';
import 'package:mobile/widgets/widget.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Report _currentReport;

  @override
  void initState() {
    super.initState();
    _currentReport = OverviewReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildReportDropdown(),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          child: _buildBody(),
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

  Widget _buildBody() {
    if (_currentReport is OverviewReport) {
      return OverviewReportView();
    } else {
      return Text(_currentReport.title(context));
    }
  }
}

