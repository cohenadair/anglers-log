import 'package:flutter/material.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/report_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/pro_overlay.dart';

import '../i18n/strings.dart';
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
        addPageBuilder: () => subscriptionManager.isPro
            ? const SaveReportPage()
            : const ProPage(),
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
    } else if (item == _ItemType.headingNoteDivider) {
      return _buildImmutableItem(context, _buildCustomReportsHeader(context));
    } else if (item == _ItemType.divider) {
      return _buildImmutableItem(context, const MinDivider());
    } else if (item == _ItemType.blurredReports) {
      return _buildImmutableItem(context, _buildBlurredReports(context));
    } else {
      assert(false, "Unknown item type: $item");
      return _buildImmutableItem(context, const Empty());
    }
  }

  Widget _buildCustomReportsHeader(BuildContext context) {
    var reportManager = ReportManager.of(context);

    return HeadingNoteDivider(
      hideNote: reportManager.list().isNotEmpty,
      hideDivider: reportManager.defaultReports.isEmpty,
      title: Strings.of(context).reportListPageReportTitle,
      note: Strings.of(context).reportListPageReportAddNote,
      noteIcon: Icons.add,
      padding: insetsBottomSmall,
    );
  }

  Widget _buildBlurredReports(BuildContext context) {
    var reportManager = ReportManager.of(context);

    return Padding(
      padding: insetsBottomDefault,
      child: Column(
        children: [
          _buildCustomReportsHeader(context),
          ProOverlay(
            description:
                Strings.of(context).reportListPageReportsProDescription,
            proWidget: Column(
              children: reportManager
                  .listSortedByDisplayName(context)
                  .map(
                    (e) => ListItem(
                      title: Text(e.name),
                      onTap: () {
                        pickerSettings.onPicked(context, {e});
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  ManageableListPageItemModel _buildImmutableItem(
      BuildContext context, Widget child) {
    return ManageableListPageItemModel(
      child: child,
      isEditable: false,
      isSelectable: false,
    );
  }

  List<dynamic> _loadItems(BuildContext context) {
    var reportManager = ReportManager.of(context);
    var subscriptionManager = SubscriptionManager.of(context);

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
        result.add(_ItemType.divider);
      }
      result.addAll(section2Reports);
    }

    var remainingReports = defaultReports
        .where((e) => !section1.contains(e.id) && !section2.contains(e.id));
    if (remainingReports.isNotEmpty) {
      if (section2Reports.isNotEmpty) {
        result.add(_ItemType.divider);
      }
      result.addAll(remainingReports);
    }

    if (subscriptionManager.isFree && reportManager.entityCount > 0) {
      result.add(_ItemType.blurredReports);
    } else {
      result.add(_ItemType.headingNoteDivider);
      result.addAll(reportManager.listSortedByDisplayName(context));
    }

    return result;
  }
}

/// Helper for non-[Report] types to be shown in the list.
enum _ItemType {
  divider,
  headingNoteDivider,
  blurredReports,
}
