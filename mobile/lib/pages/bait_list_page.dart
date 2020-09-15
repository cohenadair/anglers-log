import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/pages/bait_page.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/save_bait_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

class BaitListPage extends StatefulWidget {
  final bool Function(BuildContext, Set<Bait>) onPicked;
  final bool multiPicker;
  final Set<Bait> initialValues;

  BaitListPage()
      : onPicked = null,
        multiPicker = false,
        initialValues = null;

  BaitListPage.picker({
    this.onPicked,
    this.multiPicker = false,
    this.initialValues = const {},
  }) : assert(onPicked != null);

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
      builder: (context) => ManageableListPage<dynamic>(
        titleBuilder: _picking
            ? (_) => Text(Strings.of(context).baitListPagePickerTitle)
            : (baits) => Text(format(Strings.of(context).baitListPageTitle,
                [baits.length])),
        forceCenterTitle: !_picking,
        searchDelegate: ManageableListPageSearchDelegate(
          hint: Strings.of(context).baitListPageSearchHint,
          noResultsMessage: Strings.of(context).baitListPageNoSearchResults,
        ),
        pickerSettings: _picking
            ? ManageableListPagePickerSettings<dynamic>(
                onPicked: (context, baits) => widget.onPicked(context, baits),
                multi: widget.multiPicker,
                initialValues: widget.initialValues,
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
            return ManageableListPageItemModel(
              editable: false,
              selectable: false,
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

    var categories = List.from(_baitCategoryManager.listSortedByName());
    var baits = _baitManager.filteredList(query);

    // Add a category for baits that don't have a category. This is purposely
    // added to the end of the sorted list.
    BaitCategory noCategory = BaitCategory()
      ..id = Id.random().bytes
      ..name = Strings.of(context).baitListPageOtherCategory;
    categories.add(noCategory);

    // First, organize baits in to category collections.
    Map<Id, List<Bait>> map = {};
    for (var bait in baits) {
      Id id =
          Id(bait.hasBaitCategoryId() ? noCategory.id : bait.baitCategoryId);
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