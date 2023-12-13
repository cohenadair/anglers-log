import 'package:flutter/material.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/widgets/widget.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../utils/gear_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/list_item.dart';
import 'gear_page.dart';
import 'manageable_list_page.dart';
import 'save_gear_page.dart';

class GearListPage extends StatelessWidget {
  final ManageableListPagePickerSettings<Gear>? pickerSettings;

  const GearListPage({
    this.pickerSettings,
  });

  bool get _isPicking => pickerSettings != null;

  @override
  Widget build(BuildContext context) {
    var catchManager = CatchManager.of(context);
    var gearManager = GearManager.of(context);

    return ManageableListPage<Gear>(
      titleBuilder: (gear) => Text(
        format(Strings.of(context).gearListPageTitle, [gear.length]),
      ),
      forceCenterTitle: !_isPicking,
      itemBuilder: (context, gear) => ManageableListPageItemModel(
        child: _buildListItem(context, gear),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).gearListPageSearchHint,
      ),
      pickerSettings: pickerSettings?.copyWith(
        title: Text(Strings.of(context).pickerTitleGear),
        multiTitle: Text(Strings.of(context).pickerTitleGear),
      ),
      itemManager: ManageableListPageItemManager<Gear>(
        listenerManagers: [catchManager, gearManager],
        loadItems: (query) =>
            gearManager.listSortedByDisplayName(context, filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: iconGear,
          title: Strings.of(context).gearListPageEmptyListTitle,
          description: Strings.of(context).gearListPageEmptyListDescription,
        ),
        deleteWidget: (context, gear) =>
            Text(gearManager.deleteMessage(context, gear)),
        deleteItem: (context, gear) => gearManager.delete(gear.id),
        addPageBuilder: () => const SaveGearPage(),
        detailPageBuilder: (gear) => GearPage(gear),
        editPageBuilder: (gear) => SaveGearPage.edit(gear),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, Gear gear) {
    var model = GearListItemModel(context, gear);
    return ManageableListImageItem(
      imageName: model.imageName,
      title: model.title,
      subtitle: model.subtitle,
    );
  }
}
