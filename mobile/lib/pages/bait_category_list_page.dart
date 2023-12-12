import 'package:flutter/material.dart';
import 'package:mobile/widgets/widget.dart';

import '../bait_category_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_bait_category_page.dart';
import '../res/style.dart';
import '../utils/string_utils.dart';

class BaitCategoryListPage extends StatelessWidget {
  final ManageableListPagePickerSettings<BaitCategory>? pickerSettings;

  const BaitCategoryListPage({
    this.pickerSettings,
  });

  bool get _isPicking => pickerSettings != null;

  @override
  Widget build(BuildContext context) {
    var baitCategoryManager = BaitCategoryManager.of(context);

    return ManageableListPage<BaitCategory>(
      titleBuilder: (categories) => Text(
        format(
            Strings.of(context).baitCategoryListPageTitle, [categories.length]),
      ),
      forceCenterTitle: !_isPicking,
      itemBuilder: (context, category) => ManageableListPageItemModel(
        child: Text(category.name, style: stylePrimary(context)),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).baitCategoryListPageSearchHint,
      ),
      pickerSettings: pickerSettings?.copyWith(
        title: Text(Strings.of(context).pickerTitleBaitCategory),
      ),
      itemManager: ManageableListPageItemManager<BaitCategory>(
        listenerManagers: [baitCategoryManager],
        loadItems: (query) =>
            baitCategoryManager.listSortedByDisplayName(context, filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: iconBaitCategories,
          title: Strings.of(context).baitCategoryListPageEmptyListTitle,
          description:
              Strings.of(context).baitCategoryListPageEmptyListDescription,
        ),
        deleteWidget: (context, category) =>
            Text(baitCategoryManager.deleteMessage(context, category)),
        deleteItem: (context, category) =>
            baitCategoryManager.delete(category.id),
        addPageBuilder: () => const SaveBaitCategoryPage(),
        editPageBuilder: (category) => SaveBaitCategoryPage.edit(category),
      ),
    );
  }
}
