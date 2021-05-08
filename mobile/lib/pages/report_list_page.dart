import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../model/overview_report.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_report_page.dart';
import '../report_manager.dart';
import '../res/dimen.dart';
import '../subscription_manager.dart';
import '../utils/string_utils.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';
import 'pro_page.dart';

class ReportListPage extends StatelessWidget {
  final _log = Log("ReportListPage");

  /// The generic type is dynamic here because different kinds of report
  /// objects are rendered in the list.
  final ManageableListPagePickerSettings<dynamic> pickerSettings;

  ReportListPage({
    required this.pickerSettings,
  });

  @override
  Widget build(BuildContext context) {
    var subscriptionManager = SubscriptionManager.of(context);
    var reportManager = ReportManager.of(context);

    return ManageableListPage<dynamic>(
      pickerTitleBuilder: (_) =>
          Text(Strings.of(context).reportListPagePickerTitle),
      itemBuilder: _buildItem,
      itemManager: ManageableListPageItemManager<dynamic>(
        listenerManagers: [
          reportManager,
        ],
        loadItems: (_) => _loadItems(context),
        deleteWidget: (context, report) => Text(
          format(
            Strings.of(context).reportListPageConfirmDelete,
            [report.name],
          ),
        ),
        deleteItem: (_, item) => reportManager.delete(item.id),
        addPageBuilder: () =>
            subscriptionManager.isPro ? SaveReportPage() : ProPage(),
        editPageBuilder: (report) => SaveReportPage.edit(report),
      ),
      pickerSettings: pickerSettings.copyWith(
        isRequired: true,
      ),
    );
  }

  ManageableListPageItemModel _buildItem(BuildContext context, dynamic item) {
    if (item is Report) {
      return ManageableListPageItemModel(
        child: PrimaryLabel(item.name),
        editable: true,
      );
    } else if (item is OverviewReport) {
      return ManageableListPageItemModel(
        child: PrimaryLabel(item.title(context)),
        editable: false,
      );
    } else if (item == HeadingNoteDivider) {
      return ManageableListPageItemModel(
        child: HeadingNoteDivider(
          hideNote: ReportManager.of(context).list().isNotEmpty,
          title: Strings.of(context).reportListPageReportTitle,
          note: Strings.of(context).reportListPageReportAddNote,
          noteIcon: Icons.add,
          padding: insetsBottomWidgetSmall,
        ),
        editable: false,
        selectable: false,
      );
    } else {
      _log.w("Unknown item type: $item");

      return ManageableListPageItemModel(
        child: Empty(),
        editable: false,
        selectable: false,
      );
    }
  }

  List<dynamic> _loadItems(BuildContext context) {
    return [
      OverviewReport(),
      HeadingNoteDivider,
    ]..addAll(ReportManager.of(context).listSortedByName());
  }
}
