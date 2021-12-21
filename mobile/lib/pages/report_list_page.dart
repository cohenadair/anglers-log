import 'package:flutter/material.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/report_utils.dart';

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
    } else if (item is HeadingNoteDivider) {
      return ManageableListPageItemModel(
        child: item,
        isEditable: false,
        isSelectable: false,
      );
    } else if (item is MinDivider) {
      return ManageableListPageItemModel(
        child: item,
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

  List<dynamic> _loadItems(BuildContext context) {
    var reportManager = ReportManager.of(context);

    var section1 = [reportIdPersonalBests];
    var section2 = [
      reportIdCatchSummary,
      reportIdSpeciesSummary,
      reportIdTripSummary,
    ];

    var result = [];
    var defaultReports = reportManager.defaultReports;

    var section1Reports = defaultReports.where((e) => section1.contains(e.id));
    if (section1Reports.isNotEmpty) {
      result.addAll(section1Reports);
    }

    var section2Reports = defaultReports.where((e) => section2.contains(e.id));
    if (section2Reports.isNotEmpty) {
      if (section1Reports.isNotEmpty) {
        result.add(const MinDivider());
      }
      result.addAll(section2Reports);
    }

    var remainingReports = defaultReports
        .where((e) => !section1.contains(e.id) && !section2.contains(e.id));
    if (remainingReports.isNotEmpty) {
      if (section2Reports.isNotEmpty) {
        result.add(const MinDivider());
      }
      result.addAll(remainingReports);
    }

    result.add(HeadingNoteDivider(
      hideNote: ReportManager.of(context).list().isNotEmpty,
      hideDivider: result.isEmpty,
      title: Strings.of(context).reportListPageReportTitle,
      note: Strings.of(context).reportListPageReportAddNote,
      noteIcon: Icons.add,
      padding: insetsBottomSmall,
    ));
    result.addAll(reportManager.listSortedByName());

    return result;
  }
}
