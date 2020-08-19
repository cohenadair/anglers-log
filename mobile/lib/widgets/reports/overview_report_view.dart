import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/date_range_picker_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/reports/report_summary.dart';
import 'package:mobile/widgets/reports/report_view.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

class OverviewReportView extends StatefulWidget {
  @override
  _OverviewReportViewState createState() => _OverviewReportViewState();
}

class _OverviewReportViewState extends State<OverviewReportView> {
  DisplayDateRange _currentDateRange =
      DisplayDateRange.of(DisplayDateRange.allDates.id);

  ReportSummaryModel _model;

  @override
  void initState() {
    super.initState();
    _updateModel();
  }

  @override
  Widget build(BuildContext context) {
    return ReportView(
      onUpdate: _updateModel,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDurationPicker(),
          _buildCatchItems(),
        ],
      ),
    );
  }

  Widget _buildDurationPicker() => DateRangePickerInput(
    initialDateRange: _currentDateRange,
    onPicked: (dateRange) => setState(() {
      _currentDateRange = dateRange;
      _updateModel();
    }),
  );

  Widget _buildCatchItems() {
    if (_model.totalCatches <= 0) {
      return Column(
        children: [
          MinDivider(),
          Padding(
            padding: insetsDefault,
            child: PrimaryLabel(
              Strings.of(context).reportViewNoCatches,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildViewCatchesRow(),
        ReportSummary(model: _model),
      ],
    );
  }

  Widget _buildViewCatchesRow() {
    return ListItem(
      title: Text(Strings.of(context).reportViewViewCatches),
      onTap: () => push(context, CatchListPage(
        dateRange: _model.dateRange,
      )),
      trailing: RightChevronIcon(),
    );
  }

  void _updateModel() {
    _model = ReportSummaryModel(
      appManager: AppManager.of(context),
      context: context,
      displayDateRange: _currentDateRange,
    );
  }
}