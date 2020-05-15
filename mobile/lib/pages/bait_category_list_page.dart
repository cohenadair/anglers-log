import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/save_bait_category_page.dart';
import 'package:mobile/widgets/text.dart';

class BaitCategoryListPage extends StatelessWidget {
  final bool Function(BuildContext, BaitCategory) onPicked;

  BaitCategoryListPage.picker({
    this.onPicked,
  }) : assert(onPicked != null);

  bool get _picking => onPicked != null;

  @override
  Widget build(BuildContext context) {
    BaitCategoryManager baitCategoryManager = BaitCategoryManager.of(context);
    List<BaitCategory> baitCategories = baitCategoryManager.entityList;

    return EntityListenerBuilder<BaitCategory>(
      manager: baitCategoryManager,
      builder: (context) => ManageableListPage<BaitCategory>(
        title: _picking
            ? Text(Strings.of(context).baitCategoryListPagePickerTitle)
            : Text(Strings.of(context).baitCategoryListPageTitle),
        itemCount: baitCategories.length,
        itemBuilder: (context, i) => ManageableListPageItemModel(
          child: Text(baitCategories[i].name),
          value: baitCategories[i],
        ),
        searchSettings: ManageableListPageSearchSettings(
          hint: Strings.of(context).baitCategoryListPageSearchHint,
          onStart: () {
            // TODO
          },
        ),
        pickerSettings: _picking
            ? ManageableListPageSinglePickerSettings<BaitCategory>(
                onPicked: (context, categoryPicked) =>
                    onPicked(context, categoryPicked),
              )
            : null,
        itemManager: ManageableListPageItemManager(
          deleteText: (context, category) => InsertedBoldText(
            text: Strings.of(context).baitCategoryListPageConfirmDelete,
            args: [category.name],
          ),
          deleteItem: (context, category) =>
              baitCategoryManager.delete(category),
          addPageBuilder: () => SaveBaitCategoryPage(),
          editPageBuilder: (category) => SaveBaitCategoryPage.edit(category),
        ),
      ),
    );
  }
}