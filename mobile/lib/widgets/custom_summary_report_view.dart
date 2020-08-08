import 'package:flutter/material.dart';
import 'package:mobile/custom_summary_report_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/custom_summary_report.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/report_view.dart';
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
  CustomSummaryReportViewData _reportData;

  CustomSummaryReportManager get _summaryReportManager =>
      CustomSummaryReportManager.of(context);

  @override
  void initState() {
    super.initState();
    _updateReportData();
  }

  @override
  Widget build(BuildContext context) {
    return ReportView(
      managers: [
        _summaryReportManager,
      ],
      onUpdate: _updateReportData,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDescription(),
          _buildViewCatches(),
          _buildSummary(),
          _buildCharts(),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    if (!_reportData.report.hasDescription) {
      return Empty();
    }
    return Padding(
      padding: insetsDefault,
      child: Label(_reportData.report.description),
    );
  }

  Widget _buildViewCatches() {
    return ListItem(
      title: Text(Strings.of(context).reportViewViewCatches),
      onTap: () => push(context, CatchListPage(
        dateRange: _reportData.dateRange,
        baitIds: _reportData.baitIds,
        fishingSpotIds: _reportData.fishingSpotIds,
        speciesIds: _reportData.speciesIds,
      )),
      trailing: RightChevronIcon(),
    );
  }

  Widget _buildSummary() {
    return Empty();
  }

  Widget _buildCharts() {
    return Empty();
  }

  void _updateReportData() {
    if (_summaryReportManager.entityExists(id: widget.reportId)) {
      _reportData = CustomSummaryReportViewData(context,
          _summaryReportManager.entity(id: widget.reportId));
    }
  }
}

/// A class, that when instantiated, gathers all the data required to display
/// an the data associated with a [CustomSummaryReport].
class CustomSummaryReportViewData {
  final BuildContext context;
  final CustomSummaryReport report;

  CustomSummaryReportManager get _summaryReportManager =>
      CustomSummaryReportManager.of(context);

  CustomSummaryReportViewData(this.context, this.report);

  DateRange get dateRange =>
      DisplayDateRange.of(report.displayDateRangeId).value;

  Set<String> get baitIds => _summaryReportManager.baitIds(report.id);

  Set<String> get fishingSpotIds =>
      _summaryReportManager.fishingSpotIds(report.id);

  Set<String> get speciesIds => _summaryReportManager.speciesIds(report.id);
}