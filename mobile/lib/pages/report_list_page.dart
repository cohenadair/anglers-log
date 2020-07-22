import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/model/report.dart';
import 'package:mobile/pages/entity_list_page.dart';
import 'package:mobile/pages/save_report_page.dart';
import 'package:mobile/custom_report_manager.dart';
import 'package:mobile/model/overview_report.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';

class ReportListPage extends StatelessWidget {
  final dynamic currentItem;
  final bool Function(BuildContext, dynamic) onPicked;

  ReportListPage.picker({
    this.currentItem,
    @required this.onPicked,
  }) : assert(onPicked != null);

  @override
  Widget build(BuildContext context) {
    var reportManager = CustomReportManager.of(context);

    return EntityListPage<dynamic>(
      title: Text(Strings.of(context).reportListPagePickerTitle),
      itemBuilder: (context, item) => _buildItem(context, item),
      itemManager: ManageableListPageItemManager<dynamic>(
        listenerManagers: [ reportManager ],
        loadItems: (_) => _loadItems(context),
        deleteText: (context, report) => Text(format(Strings.of(context)
            .reportListPageConfirmDelete, [report.title(context)])),
        deleteItem: (context, report) => reportManager.delete(report),
        addPageBuilder: () => SaveReportPage(),
        editPageBuilder: (report) => SaveReportPage.edit(report),
      ),
      pickerSettings: ManageableListPageSinglePickerSettings<dynamic>(
        initialValue: currentItem,
        onPicked: onPicked,
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

  List<dynamic> _loadItems(BuildContext context) {
    List<dynamic> result = [
      OverviewReport(),
    ];

    var reportManager = CustomReportManager.of(context);

    // Separate pre-defined reports from custom reports.
    if (reportManager.entityCount > 0) {
      result.add(Divider());
    }

    return result..addAll(reportManager.entityListSortedByName());
  }
}