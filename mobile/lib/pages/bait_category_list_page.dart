import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/pages/entity_list_page.dart';
import 'package:mobile/pages/save_bait_category_page.dart';

class BaitCategoryListPage extends StatelessWidget {
  final bool Function(BuildContext, BaitCategory) onPicked;

  BaitCategoryListPage.picker({
    this.onPicked,
  }) : assert(onPicked != null);

  bool get _picking => onPicked != null;

  @override
  Widget build(BuildContext context) {
    BaitCategoryManager baitCategoryManager = BaitCategoryManager.of(context);

    return EntityListPage<BaitCategory>(
      title: _picking
          ? Text(Strings.of(context).baitCategoryListPagePickerTitle)
          : Text(Strings.of(context).baitCategoryListPageTitle),
      itemBuilder: (context, category) => ManageableListPageItemModel(
        child: Text(category.name),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).baitCategoryListPageSearchHint,
        noResultsMessage:
            Strings.of(context).baitCategoryListPageNoSearchResults,
      ),
      pickerSettings: _picking
          ? ManageableListPageSinglePickerSettings<BaitCategory>(
              onPicked: onPicked,
            )
          : null,
      itemManager: ManageableListPageItemManager<BaitCategory>(
        listenerManagers: [ baitCategoryManager ],
        loadItems: (String query) =>
            baitCategoryManager.entityListSortedByName(filter: query),
        deleteText: (context, category) =>
            Text(baitCategoryManager.deleteMessage(context, category)),
        deleteItem: (context, category) =>
            baitCategoryManager.delete(category),
        addPageBuilder: () => SaveBaitCategoryPage(),
        editPageBuilder: (category) => SaveBaitCategoryPage.edit(category),
      ),
    );
  }
}