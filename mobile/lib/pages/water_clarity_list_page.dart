import 'package:flutter/material.dart';
import 'package:mobile/widgets/widget.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../res/style.dart';
import '../utils/string_utils.dart';
import '../water_clarity_manager.dart';
import 'save_water_clarity_page.dart';

class WaterClarityListPage extends StatelessWidget {
  final ManageableListPagePickerSettings<WaterClarity>? pickerSettings;

  const WaterClarityListPage({
    this.pickerSettings,
  });

  bool get _isPicking => pickerSettings != null;

  @override
  Widget build(BuildContext context) {
    var waterClarityManager = WaterClarityManager.of(context);

    return ManageableListPage<WaterClarity>(
      titleBuilder: (clarities) => Text(
        format(
            Strings.of(context).waterClarityListPageTitle, [clarities.length]),
      ),
      forceCenterTitle: !_isPicking,
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
            waterClarityManager.listSortedByDisplayName(context, filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: iconWaterClarity,
          title: Strings.of(context).waterClarityListPageEmptyListTitle,
          description:
              Strings.of(context).waterClarityListPageEmptyListDescription,
        ),
        deleteWidget: (context, clarity) =>
            Text(waterClarityManager.deleteMessage(context, clarity)),
        deleteItem: (context, clarity) =>
            waterClarityManager.delete(clarity.id),
        addPageBuilder: () => const SaveWaterClarityPage(),
        editPageBuilder: (clarity) => SaveWaterClarityPage.edit(clarity),
      ),
    );
  }
}
