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
import '../res/style.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/bait_variant_list_input.dart';
import '../widgets/widget.dart';

class BaitListPage extends StatefulWidget {
  final BaitListPagePickerSettings? pickerSettings;

  BaitListPage({
    this.pickerSettings,
  });

  @override
  _BaitListPageState createState() => _BaitListPageState();
}

class _BaitListPageState extends State<BaitListPage> {
  static const _log = Log("BaitListPage");

  var _baits = <Bait>[];
  final _selectedVariants = <BaitVariant>{};

  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  bool get _isPicking => widget.pickerSettings != null;

  @override
  Widget build(BuildContext context) {
    return ManageableListPage<dynamic>(
      titleBuilder: (baits) => Text(
        format(Strings.of(context).baitListPageTitle,
            [baits.whereType<Bait>().length]),
      ),
      forceCenterTitle: !_isPicking,
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).baitListPageSearchHint,
      ),
      pickerSettings: manageableListPagePickerSettings,
      itemBuilder: (context, item) {
        if (item is BaitCategory) {
          return ManageableListPageItemModel(
            editable: false,
            selectable: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: paddingDefault,
                right: paddingDefault,
                top: paddingDefault,
                bottom: paddingWidgetSmall,
              ),
              child: Text(item.name, style: styleListHeading(context)),
            ),
          );
        } else if (item is Bait) {
          return _buildBaitItem(item);
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

  ManageableListPageItemModel _buildBaitItem(Bait bait) {
    Widget? grandchild;
    if (bait.variants.isNotEmpty && _isPicking) {
      grandchild = BaitVariantListInput.static(
        bait.variants,
        showHeader: false,
        isCondensed: true,
        onCheckboxChanged: (variant, isChecked) {
          if (isChecked) {
            _selectedVariants.add(variant);
          } else {
            _selectedVariants.remove(variant);
          }
        },
        selectedItems: _selectedVariants,
      );
    }

    return ManageableListPageItemModel(
      grandchild: grandchild,
      child: Row(
        children: [
          Expanded(
            child: Text(
              bait.name,
              style: stylePrimary(context),
            ),
          ),
          Chip(
            label: Text(format(
              Strings.of(context).baitListPageVariantsLabel,
              [bait.variants.length],
            )),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  void _onPickedAll(bool isChecked) {
    if (isChecked) {
      for (var bait in _baits) {
        for (var variant in bait.variants) {
          _selectedVariants.add(variant);
        }
      }
    } else {
      _selectedVariants.clear();
    }
  }

  BaitListPagePickerSettings get _pickerSettings {
    assert(_isPicking, "Check _isPicking before accessing _pickerSettings");
    return widget.pickerSettings!;
  }

  ManageableListPagePickerSettings? get manageableListPagePickerSettings {
    if (!_isPicking) {
      return null;
    }

    // ManageableListPage picker manages Bait objects, so we need to ensure
    // only Bait objects are passed to the ManageableListPage's picker settings.
    // In addition, we only want to pass in Bait objects whose associated
    // BaitAttachment does not include a variant.
    //
    // Note that BaitVariant picking is handled exclusively in this widget.
    var initialValues = <Bait>{};
    for (var attachment in _pickerSettings.initialValues) {
      if (attachment.hasVariantId()) {
        continue;
      }

      var bait = _baitManager.entity(attachment.baitId);
      if (bait != null) {
        initialValues.add(bait);
      }
    }

    return ManageableListPagePickerSettings(
      onPicked: (context, items) {
        // Only include selected baits that don't have variants. Variants are
        // selected individually.
        items
          ..removeWhere((e) => !(e is Bait) || e.variants.isNotEmpty);

        var attachments = <BaitAttachment>{};
        attachments.addAll(items.map((e) => (e as Bait).toAttachment()));
        attachments.addAll(_selectedVariants.map((e) => e.toAttachment()));

        return _pickerSettings.onPicked(context, attachments);
      },
      onPickedAll: (isChecked) => setState(() => _onPickedAll(isChecked)),
      containsAll: (selectedItems) => selectedItems.containsAll(_baits),
      title: Text(Strings.of(context).pickerTitleBait),
      multiTitle: Text(Strings.of(context).pickerTitleBaits),
      initialValues: initialValues,
    );
  }
}

class BaitListPagePickerSettings {
  final bool Function(BuildContext, Set<BaitAttachment>) onPicked;
  final Set<BaitAttachment> initialValues;

  BaitListPagePickerSettings({
    required this.onPicked,
    required this.initialValues,
  });
}
