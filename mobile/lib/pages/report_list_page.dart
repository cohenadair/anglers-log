import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../comparison_report_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../model/overview_report.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_report_page.dart';
import '../res/dimen.dart';
import '../summary_report_manager.dart';
import '../utils/string_utils.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';

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
    var summaryReportManager = SummaryReportManager.of(context);
    var comparisonReportManager = ComparisonReportManager.of(context);

    return ManageableListPage<dynamic>(
      titleBuilder: (_) => Text(Strings.of(context).reportListPagePickerTitle),
      itemBuilder: _buildItem,
      itemManager: ManageableListPageItemManager<dynamic>(
        listenerManagers: [
          summaryReportManager,
          comparisonReportManager,
        ],
        loadItems: (_) => _loadItems(context),
        deleteWidget: (context, report) => Text(
          format(
            Strings.of(context).reportListPageConfirmDelete,
            [report.name],
          ),
        ),
        deleteItem: _deleteItem,
        addPageBuilder: () => SaveReportPage(),
        editPageBuilder: (report) => SaveReportPage.edit(report),
      ),
      pickerSettings: ManageableListPagePickerSettings<dynamic>(
        initialValues: {currentItem},
        onPicked: (context, reports) => onPicked(context, reports.first),
      ),
    );
  }

  ManageableListPageItemModel _buildItem(BuildContext context, dynamic item) {
    if (item is SummaryReport || item is ComparisonReport) {
      return ManageableListPageItemModel(
        child: PrimaryLabel(item.name),
        editable: true,
      );
    } else if (item is OverviewReport) {
      return ManageableListPageItemModel(
        child: PrimaryLabel(item.title(context)),
        editable: false,
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
    if (item is SummaryReport) {
      SummaryReportManager.of(context).delete(item.id);
    } else if (item is ComparisonReport) {
      ComparisonReportManager.of(context).delete(item.id);
    } else {
      _log.w("Can't delete item: $item");
    }
  }

  List<dynamic> _loadItems(BuildContext context) {
    var result = <dynamic>[
      OverviewReport(),
    ];

    var summaryReportManager = SummaryReportManager.of(context);
    var comparisonReportManager = ComparisonReportManager.of(context);

    var customReports = <dynamic>[]
      ..addAll(summaryReportManager.list())
      ..addAll(comparisonReportManager.list())
      // Sort alphabetically.
      ..sort((lhs, rhs) => compareIgnoreCase(lhs.name, rhs.name));

    // Separate pre-defined reports from custom reports.
    result.add(HeadingNoteDivider(
      hideNote: customReports.isNotEmpty,
      title: Strings.of(context).reportListPageCustomReportTitle,
      note: Strings.of(context).reportListPageCustomReportAddNote,
      noteIcon: Icons.add,
      padding: insetsBottomWidgetSmall,
    ));

    return result..addAll(customReports);
  }
}
