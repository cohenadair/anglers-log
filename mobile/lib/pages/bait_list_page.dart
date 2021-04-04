import 'package:flutter/material.dart';

import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/bait_page.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_bait_page.dart';
import '../res/dimen.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';

class BaitListPage extends StatefulWidget {
  /// Even though the generic type in this object is [dynamic],
  /// [pickerSettings.onPicked] is guaranteed to pass only [Bait] objects.
  ///
  /// The generic type is dynamic here because not only Bait objects are shown
  /// in the list; there are also BaitCategory objects.
  final ManageableListPagePickerSettings<dynamic>? pickerSettings;

  BaitListPage({
    this.pickerSettings,
  });

  @override
  _BaitListPageState createState() => _BaitListPageState();
}

class _BaitListPageState extends State<BaitListPage> {
  static const _log = Log("BaitListPage");

  List<Bait> _baits = [];

  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  bool get _picking => widget.pickerSettings != null;

  @override
  Widget build(BuildContext context) {
    return ManageableListPage<dynamic>(
      titleBuilder: (baits) => Text(
        format(Strings.of(context).baitListPageTitle,
            [baits.whereType<Bait>().length]),
      ),
      pickerTitleBuilder: (_) => Text(widget.pickerSettings!.isMulti
          ? Strings.of(context).baitListPagePickerTitleMulti
          : Strings.of(context).baitListPagePickerTitle),
      forceCenterTitle: !_picking,
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).baitListPageSearchHint,
      ),
      pickerSettings: _picking
          ? widget.pickerSettings!.copyWith(
              onPicked: (context, items) {
                items.removeWhere((e) => !(e is Bait));
                return widget.pickerSettings!.onPicked(
                  context,
                  items.map((e) => (e as Bait)).toSet(),
                );
              },
              containsAll: (selectedItems) => selectedItems.containsAll(_baits),
            )
          : null,
      itemBuilder: (context, item) {
        if (item is BaitCategory) {
          return ManageableListPageItemModel(
            editable: false,
            selectable: false,
            child: Padding(
              padding: insetsDefault,
              child: HeadingLabel(item.name),
            ),
          );
        } else if (item is Bait) {
          return ManageableListPageItemModel(
            child: PrimaryLabel(item.name),
          );
        } else {
          assert(item is Widget);
          return ManageableListPageItemModel(
            editable: false,
            selectable: false,
            child: item as Widget,
          );
        }
      },
      itemManager: ManageableListPageItemManager<dynamic>(
        listenerManagers: [
          _baitCategoryManager,
          _baitManager,
        ],
        loadItems: _buildItems,
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: Icons.bug_report,
          title: Strings.of(context).baitListPageEmptyListTitle,
          description: Strings.of(context).baitListPageEmptyListDescription,
        ),
        deleteWidget: (context, bait) =>
            Text(_baitManager.deleteMessage(context, bait)),
        deleteItem: (context, bait) {
          if (bait is Bait) {
            _baitManager.delete(bait.id);
          } else {
            _log.e("Calling deleteItem callback on non-bait object.");
          }
        },
        addPageBuilder: () => SaveBaitPage(),
        detailPageBuilder: (bait) => BaitPage(bait as Bait),
        editPageBuilder: (bait) => SaveBaitPage.edit(bait),
      ),
    );
  }

  List<dynamic> _buildItems(String? query) {
    var result = <dynamic>[];

    var categories = List.from(_baitCategoryManager.listSortedByName());
    _baits = _baitManager.filteredList(query);

    // Add a category for baits that don't have a category. This is purposely
    // added to the end of the sorted list.
    var noCategory = BaitCategory()
      ..id = randomId()
      ..name = Strings.of(context).baitListPageOtherCategory;
    categories.add(noCategory);

    // First, organize baits in to category collections.
    var map = <Id, List<Bait>>{};
    for (var bait in _baits) {
      var id = bait.hasBaitCategoryId() ? bait.baitCategoryId : noCategory.id;
      map.putIfAbsent(id, () => []);
      map[id]!.add(bait);
    }

    // Next, iterate categories and create list items.
    for (var i = 0; i < categories.length; i++) {
      BaitCategory category = categories[i];

      // Skip categories that don't have any baits.
      if (!map.containsKey(category.id) || map[category.id]!.isEmpty) {
        continue;
      }

      // Add a divider between categories; skip first one.
      if (result.isNotEmpty) {
        result.add(MinDivider());
      }

      result.add(category);
      map[category.id]!.sort((lhs, rhs) => lhs.name.compareTo(rhs.name));
      result.addAll(map[category.id]!);
    }

    return result;
  }
}
