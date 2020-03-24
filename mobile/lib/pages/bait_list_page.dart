import 'package:flutter/material.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/log.dart';
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
  @override
  _BaitListPageState createState() => _BaitListPageState();
}

class _BaitListPageState extends State<BaitListPage> {
  final _log = Log("BaitListPage");

  List<dynamic> _items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<int>(
          future: BaitManager.of(context).numberOfBaits,
          builder: (context, snapshot) {
            int numberOfBaits = 0;
            if (snapshot.hasData) {
              numberOfBaits = snapshot.data;
            }

            return Text(format(Strings.of(context).baitListPageTitle,
                [numberOfBaits]));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => present(context, SaveBaitPage()),
          ),
        ],
      ),
      body: BaitsBuilder(
        onUpdate: (baits, categories) {
          _log.d("Baits updated...");
          _updateItems(baits, categories);
        },
        builder: (context) => ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, i) {
            var item = _items[i];

            if (item is BaitCategory) {
              return Padding(
                padding: insetsDefault,
                child: HeadingText(item.name),
              );
            } else if (item is Bait) {
              return ListItem(
                title: Text(item.name),
                trailing: RightChevronIcon(),
                onTap: () {
                  push(context, BaitPage(item));
                },
              );
            } else {
              return item;
            }
          }
        ),
      ),
    );
  }

  void _updateItems(List<Bait> baits, List<BaitCategory> categories) {
    _items.clear();

    // Add a category for baits that don't have a category.
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
      if (_items.isNotEmpty) {
        _items.add(MinDivider());
      }

      _items.add(category);
      _items.addAll(map[category.id]);
    }
  }
}