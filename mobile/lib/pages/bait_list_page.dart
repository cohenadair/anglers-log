import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/pages/bait_page.dart';
import 'package:mobile/pages/save_bait_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class BaitListPage extends StatefulWidget {
  final void Function(Bait) onPicked;

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

  bool get isPicking => widget.onPicked != null;

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder<Bait>(
      manager: BaitManager.of(context),
      builder: (context) {
        List<dynamic> items = _buildItems();

        return Scaffold(
          appBar: AppBar(
            title: Text(format(Strings.of(context).baitListPageTitle,
                [_baitManager.entityCount])),
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => present(context, SaveBaitPage()),
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              var item = items[i];

              if (item is BaitCategory) {
                return Padding(
                  padding: insetsDefault,
                  child: HeadingText(item.name),
                );
              } else if (item is Bait) {
                return ListItem(
                  title: Text(item.name),
                  trailing: isPicking ? Empty() : RightChevronIcon(),
                  onTap: () {
                    if (isPicking) {
                      widget.onPicked(item);
                      Navigator.pop(context);
                    } else {
                      push(context, BaitPage(item.id));
                    }
                  },
                );
              } else {
                return item;
              }
            },
          ),
        );
      },
    );
  }

  List<dynamic> _buildItems() {
    List<dynamic> result = [];

    var categories = List.from(_baitCategoryManager.entityListSortedByName);
    var baits = _baitManager.entityListSortedByName;

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