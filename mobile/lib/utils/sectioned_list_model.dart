import 'package:flutter/material.dart';

import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../res/dimen.dart';
import '../widgets/widget.dart';

abstract class SectionedListModel<Header, Item> {
  List<Header> sectionHeaders(BuildContext context);

  Header noSectionHeader(BuildContext context);

  /// A unique [Id] used for the "no section" header.
  ///
  /// Required for comparisons when updating the list after data model changes.
  /// Without a consistent ID, multiple "No Category" headings are created and
  /// removed, resulting in a jarring UI transition.
  Id get noSectionHeaderId;

  Id headerId(Header header);

  String headerName(Header header);

  List<Item> filteredItemList(BuildContext context, String? filter);

  bool itemHasHeaderId(Item item);

  Id itemHeaderId(Item item);

  String itemName(BuildContext context, Item item);

  ManageableListPageItemModel buildItem(BuildContext context, Item item);

  var _items = <Item>[];
  Header? _firstHeader;

  List<Item> get items => List<Item>.of(_items);

  Header? get firstHeader => _firstHeader;

  List<dynamic> buildModel(BuildContext context, String? query) {
    var result = <dynamic>[];

    var headers = List.from(sectionHeaders(context));
    _items = filteredItemList(context, query);

    // Add a section for items that aren't associated with another section.
    // This is purposely added to the end of the sorted list.
    headers.add(noSectionHeader(context));

    // First, organize items into header collections.
    var map = <Id, List<Item>>{};
    for (var item in _items) {
      var id = itemHasHeaderId(item) ? itemHeaderId(item) : noSectionHeaderId;
      map.putIfAbsent(id, () => []);
      map[id]!.add(item);
    }

    // Next, iterate headers and create list items.
    for (var i = 0; i < headers.length; i++) {
      var header = headers[i];

      // Skip headers that don't have any items.
      if (!map.containsKey(headerId(header)) ||
          map[headerId(header)]!.isEmpty) {
        continue;
      }

      // Cache first item so we can hide the divider.
      if (result.isEmpty) {
        _firstHeader = header;
      }

      result.add(header);
      map[headerId(header)]!.sort((lhs, rhs) =>
          itemName(context, lhs).compareTo(itemName(context, rhs)));
      result.addAll(map[headerId(header)]!);
    }

    return result;
  }

  ManageableListPageItemModel buildItemModel(
      BuildContext context, dynamic item) {
    if (item is Header) {
      return ManageableListPageItemModel(
        isEditable: false,
        isSelectable: false,
        child: Padding(
          padding: insetsBottomDefault,
          child: HeadingDivider(
            headerName(item),
            showDivider: _firstHeader == null || item != _firstHeader,
          ),
        ),
      );
    } else {
      return buildItem(context, item);
    }
  }
}
