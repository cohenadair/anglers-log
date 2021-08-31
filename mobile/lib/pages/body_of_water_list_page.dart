import 'package:flutter/material.dart';

import '../body_of_water_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../res/style.dart';
import '../utils/string_utils.dart';
import 'save_body_of_water_page.dart';

class BodyOfWaterListPage extends StatelessWidget {
  final ManageableListPagePickerSettings<BodyOfWater>? pickerSettings;

  BodyOfWaterListPage({
    this.pickerSettings,
  });

  @override
  Widget build(BuildContext context) {
    var bodyOfWaterManager = BodyOfWaterManager.of(context);

    return ManageableListPage<BodyOfWater>(
      titleBuilder: (bodies) => Text(
        format(Strings.of(context).bodyOfWaterListPageTitle, [bodies.length]),
      ),
      itemBuilder: (context, body) => ManageableListPageItemModel(
        child: Text(body.name, style: stylePrimary(context)),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).bodyOfWaterListPageSearchHint,
      ),
      pickerSettings: pickerSettings?.copyWith(
        title: Text(Strings.of(context).pickerTitleBodyOfWater),
        multiTitle: Text(Strings.of(context).pickerTitleBodiesOfWater),
      ),
      itemManager: ManageableListPageItemManager<BodyOfWater>(
        listenerManagers: [bodyOfWaterManager],
        loadItems: (query) =>
            bodyOfWaterManager.listSortedByName(filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: Icons.water,
          title: Strings.of(context).bodyOfWaterListPageEmptyListTitle,
          description:
              Strings.of(context).bodyOfWaterListPageEmptyListDescription,
        ),
        deleteWidget: (context, body) =>
            Text(bodyOfWaterManager.deleteMessage(context, body)),
        deleteItem: (context, body) => bodyOfWaterManager.delete(body.id),
        addPageBuilder: () => SaveBodyOfWaterPage(),
        editPageBuilder: (body) => SaveBodyOfWaterPage.edit(body),
      ),
    );
  }
}
