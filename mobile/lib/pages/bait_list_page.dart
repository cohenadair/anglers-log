import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/pages/bait_page.dart';
import 'package:mobile/pages/entity_list_page.dart';
import 'package:mobile/pages/save_bait_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class BaitListPage extends StatefulWidget {
  final bool Function(BuildContext, Bait) onPicked;

  BaitListPage() : onPicked = null;

  BaitListPage.picker({
    this.onPicked,
  });

  @override
  _BaitListPageState createState() => _BaitListPageState();
}

class _BaitListPageState extends State<BaitListPage> {
  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);
  BaitManager get _baitManager => BaitManager.of(context);

  bool get _picking => widget.onPicked != null;

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [
        _baitCategoryManager,
        _baitManager,
      ],
      builder: (context) => EntityListPage<dynamic>(
        title: _picking
            ? Text(Strings.of(context).baitListPagePickerTitle)
            : Text(format(Strings.of(context).baitListPageTitle,
                [_baitManager.entityCount])),
        forceCenterTitle: true,
        searchDelegate: ManageableListPageSearchDelegate(
          hint: Strings.of(context).baitListPageSearchHint,
          noResultsMessage: Strings.of(context).baitListPageNoSearchResults,
        ),
        pickerSettings: _picking
            ? ManageableListPageSinglePickerSettings<dynamic>(
                onPicked: (context, baitPicked) =>
                    widget.onPicked(context, baitPicked as Bait)
              )
            : null,
        itemBuilder: (context, item) {
          if (item is BaitCategory) {
            return ManageableListPageItemModel(
              editable: false,
              child: Padding(
                padding: insetsDefault,
                child: HeadingText(item.name),
              ),
            );
          } else if (item is Bait) {
            return ManageableListPageItemModel(
              child: Text(item.name),
            );
          } else {
            return ManageableListPageItemModel(
              editable: false,
              child: item,
            );
          }
        },
        itemManager: ManageableListPageItemManager<dynamic>(
          loadItems: _buildItems,
          deleteText: (context, bait) =>
              Text(_baitManager.deleteMessage(context, bait)),
          deleteItem: (context, bait) => _baitManager.delete(bait),
          addPageBuilder: () => SaveBaitPage(),
          detailPageBuilder: (bait) => BaitPage(bait.id),
          editPageBuilder: (bait) => SaveBaitPage.edit(bait),
        ),
      ),
    );
  }

  List<dynamic> _buildItems(String query) {
    List<dynamic> result = [];

    var categories = List.from(_baitCategoryManager.entityListSortedByName());
    var baits = _baitManager.filteredBaits(query);

    // Add a category for baits that don't have a category. This is purposely
    // added to the end of the sorted list.
    BaitCategory noCategory =
        BaitCategory(name: Strings.of(context).baitListPageOtherCategory);
    categories.add(noCategory);

    // First, organize baits in to category collections.
    Map<String, List<Bait>> map = {};
    for (var bait in baits) {
      var id = isEmpty(bait.categoryId) ? noCategory.id : bait.categoryId;
      map.putIfAbsent(id, () => []);
      map[id].add(bait);
    }

    // Next, iterate categories and create list items.
    for (int i = 0; i < categories.length; i++) {
      BaitCategory category = categories[i];

      // Skip categories that don't have any baits.
      if (!map.containsKey(category.id) || map[category.id].isEmpty) {
        continue;
      }

      // Add a divider between categories; skip first one.
      if (result.isNotEmpty) {
        result.add(MinDivider());
      }

      result.add(category);
      result.addAll(map[category.id]);
    }

    return result;
  }
}