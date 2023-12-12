import 'package:flutter/material.dart';
import 'package:mobile/gps_trail_manager.dart';
import 'package:mobile/utils/gps_trail_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/widget.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../utils/string_utils.dart';
import 'gps_trail_page.dart';
import 'save_gps_trail_page.dart';

class GpsTrailListPage extends StatelessWidget {
  final ManageableListPagePickerSettings<GpsTrail>? pickerSettings;

  const GpsTrailListPage({
    this.pickerSettings,
  });

  bool get _isPicking => pickerSettings != null;

  @override
  Widget build(BuildContext context) {
    var gpsTrailManager = GpsTrailManager.of(context);

    return ManageableListPage<GpsTrail>(
      titleBuilder: (trails) => Text(
        format(Strings.of(context).gpsTrailListPageTitle, [trails.length]),
      ),
      forceCenterTitle: !_isPicking,
      itemBuilder: (context, trail) => ManageableListPageItemModel(
        child: _buildListItem(context, trail),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).gpsTrailListPageSearchHint,
      ),
      pickerSettings: pickerSettings?.copyWith(
        multiTitle: Text(Strings.of(context).pickerTitleGpsTrails),
      ),
      itemManager: ManageableListPageItemManager<GpsTrail>(
        listenerManagers: [gpsTrailManager],
        loadItems: (query) => gpsTrailManager.gpsTrails(context, filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: iconGpsTrail,
          descriptionIcon: iconGpsTrail,
          title: Strings.of(context).gpsTrailListPageEmptyListTitle,
          description: Strings.of(context).gpsTrailListPageEmptyListDescription,
        ),
        deleteWidget: (context, trail) =>
            Text(gpsTrailManager.deleteMessage(context, trail)),
        deleteItem: (context, trail) => gpsTrailManager.delete(trail.id),
        editPageBuilder: (trail) => SaveGpsTrailPage.edit(trail),
        detailPageBuilder: (trail) => GpsTrailPage(trail),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, GpsTrail trail) {
    var model = GpsTrailListItemModel(context, trail);
    return ManageableListImageItem(
      title: model.title,
      subtitle: model.subtitle,
      subtitleStyle: model.subtitleStyle,
      trailing: model.trailing,
      showPlaceholder: false,
    );
  }
}
