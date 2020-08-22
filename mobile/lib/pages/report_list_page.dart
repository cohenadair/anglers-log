import 'package:flutter/material.dart';
import 'package:mobile/custom_comparison_report_manager.dart';
import 'package:mobile/custom_summary_report_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/custom_comparison_report.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/model/custom_summary_report.dart';
import 'package:mobile/model/report.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/save_custom_report_page.dart';
import 'package:mobile/model/overview_report.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

class ReportListPage extends StatelessWidget {
  static const _log = Log("ReportListPage");

  final dynamic currentItem;
  final bool Function(BuildContext, dynamic) onPicked;

  ReportListPage.picker({
    this.currentItem,
    @required this.onPicked,
  }) : assert(onPicked != null);

  @override
  Widget build(BuildContext context) {
    var summaryReportManager = CustomSummaryReportManager.of(context);
    var comparisonReportManager = CustomComparisonReportManager.of(context);

    return ManageableListPage<dynamic>(
      titleBuilder: (_) => Text(Strings.of(context).reportListPagePickerTitle),
      itemBuilder: (context, item) => _buildItem(context, item),
      itemManager: ManageableListPageItemManager<dynamic>(
        listenerManagers: [
          summaryReportManager,
          comparisonReportManager,
        ],
        loadItems: (_) => _loadItems(context),
        deleteText: (context, report) => Text(format(Strings.of(context)
            .reportListPageConfirmDelete, [report.title(context)])),
        deleteItem: _deleteItem,
        addPageBuilder: () => SaveCustomReportPage(),
        editPageBuilder: (report) => SaveCustomReportPage.edit(report),
      ),
      pickerSettings: ManageableListPagePickerSettings<dynamic>(
        initialValues: Set.of([currentItem]),
        onPicked: (context, reports) => onPicked(context, reports.first),
      ),
    );
  }

  ManageableListPageItemModel _buildItem(BuildContext context, dynamic item) {
    if (item is Report) {
      return ManageableListPageItemModel(
        child: PrimaryLabel(item.title(context)),
        editable: item is CustomReport
      );
    } else {
      return ManageableListPageItemModel(
        child: item,
        editable: false,
        selectable: false,
      );
    }
  }

  void _deleteItem(BuildContext context, dynamic item) {
    if (item is CustomSummaryReport) {
      CustomSummaryReportManager.of(context).delete(item);
    } else if (item is CustomComparisonReport) {
      CustomComparisonReportManager.of(context).delete(item);
    } else {
      _log.w("Can't delete item: $item");
    }
  }

  List<dynamic> _loadItems(BuildContext context) {
    List<dynamic> result = [
      OverviewReport(),
    ];

    var summaryReportManager = CustomSummaryReportManager.of(context);
    var comparisonReportManager = CustomComparisonReportManager.of(context);

    List<CustomReport> customReports =
        List.of(summaryReportManager.entityList())
            ..addAll(comparisonReportManager.entityList());

    // Separate pre-defined reports from custom reports.
    result.add(HeadingNoteDivider(
      hideNote: customReports.isNotEmpty,
      title: Strings.of(context).reportListPageCustomReportTitle,
      note: Strings.of(context).reportListPageCustomReportAddNote,
      noteIcon: Icons.add,
      padding: insetsBottomWidgetSmall,
    ));

    // Sort alphabetically.
    customReports.sort(
        (CustomReport lhs, CustomReport rhs) => lhs.compareNameTo(rhs));
    return result..addAll(customReports);
  }
}