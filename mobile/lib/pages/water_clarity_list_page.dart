import 'package:flutter/material.dart';
import 'package:mobile/res/style.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../utils/string_utils.dart';
import '../water_clarity_manager.dart';
import '../widgets/text.dart';
import 'save_water_clarity_page.dart';

class WaterClarityListPage extends StatelessWidget {
  final ManageableListPagePickerSettings<WaterClarity>? pickerSettings;

  WaterClarityListPage({
    this.pickerSettings,
  });

  @override
  Widget build(BuildContext context) {
    var waterClarityManager = WaterClarityManager.of(context);

    return ManageableListPage<WaterClarity>(
      titleBuilder: (clarities) => Text(
        format(
            Strings.of(context).waterClarityListPageTitle, [clarities.length]),
      ),
      itemBuilder: (context, clarity) => ManageableListPageItemModel(
        child: Text(clarity.name, style: stylePrimary(context)),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).waterClarityListPageSearchHint,
      ),
      pickerSettings: pickerSettings?.copyWith(
        title: Text(Strings.of(context).pickerTitleWaterClarity),
        multiTitle: Text(Strings.of(context).pickerTitleWaterClarities),
      ),
      itemManager: ManageableListPageItemManager<WaterClarity>(
        listenerManagers: [waterClarityManager],
        loadItems: (query) =>
            waterClarityManager.listSortedByName(filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: Icons.person,
          title: Strings.of(context).waterClarityListPageEmptyListTitle,
          description:
              Strings.of(context).waterClarityListPageEmptyListDescription,
        ),
        deleteWidget: (context, clarity) =>
            Text(waterClarityManager.deleteMessage(context, clarity)),
        deleteItem: (context, clarity) =>
            waterClarityManager.delete(clarity.id),
        addPageBuilder: () => SaveWaterClarityPage(),
        editPageBuilder: (clarity) => SaveWaterClarityPage.edit(clarity),
      ),
    );
  }
}
