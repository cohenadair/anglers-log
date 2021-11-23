import 'package:flutter/material.dart';
import 'package:mobile/utils/protobuf_utils.dart';

import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_report_page.dart';
import '../report_manager.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../subscription_manager.dart';
import '../utils/string_utils.dart';
import '../widgets/widget.dart';
import 'pro_page.dart';

class ReportListPage extends StatelessWidget {
  static const _log = Log("ReportListPage");

  /// The generic type is dynamic here because different kinds of report
  /// objects are rendered in the list.
  final ManageableListPagePickerSettings<dynamic> pickerSettings;

  const ReportListPage({
    required this.pickerSettings,
  });

  @override
  Widget build(BuildContext context) {
    var subscriptionManager = SubscriptionManager.of(context);
    var reportManager = ReportManager.of(context);

    return ManageableListPage<dynamic>(
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
            subscriptionManager.isPro ? const SaveReportPage() : ProPage(),
        editPageBuilder: (report) => SaveReportPage.edit(report),
      ),
      pickerSettings: pickerSettings.copyWith(
        isRequired: true,
        title: Text(Strings.of(context).pickerTitleReport),
      ),
    );
  }

  ManageableListPageItemModel _buildItem(BuildContext context, dynamic item) {
    var reportManager = ReportManager.of(context);

    if (item is Report) {
      return ManageableListPageItemModel(
        child: Text(
          reportManager.displayName(context, item),
          style: stylePrimary(context),
        ),
        isEditable: item.isCustom,
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
        isEditable: false,
        isSelectable: false,
      );
    } else if (item == MinDivider) {
      return const ManageableListPageItemModel(
        child: MinDivider(),
        isEditable: false,
        isSelectable: false,
      );
    } else {
      _log.w("Unknown item type: $item");

      return ManageableListPageItemModel(
        child: Empty(),
        isEditable: false,
        isSelectable: false,
      );
    }
  }

  List _loadItems(BuildContext context) {
    var reportManager = ReportManager.of(context);

    var section1 = [Report_Type.personal_bests];
    var section2 = [
      Report_Type.catch_summary,
      Report_Type.species_summary,
      Report_Type.trip_summary
    ];

    return [
      ...reportManager.defaultReports.where((e) => section1.contains(e.type)),
      MinDivider,
      ...reportManager.defaultReports.where((e) => section2.contains(e.type)),
      MinDivider,
      ...reportManager.defaultReports.where(
          (e) => !section1.contains(e.type) && !section2.contains(e.type)),
      HeadingNoteDivider,
      ...reportManager.listSortedByName(),
    ];
  }
}
