import 'package:flutter/material.dart';

import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../catch_manager.dart';
import '../entity_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/bait_page.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_bait_page.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/bait_variant_list_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/list_item.dart';
import '../widgets/multi_list_picker_input.dart';
import '../widgets/widget.dart';

class BaitListPage extends StatefulWidget {
  final BaitListPagePickerSettings? _pickerSettings;

  BaitListPage() : _pickerSettings = null;

  /// To create a picker, use [BaitPickerInput].
  BaitListPage._picker({
    BaitListPagePickerSettings? pickerSettings,
  }) : _pickerSettings = pickerSettings;

  @override
  _BaitListPageState createState() => _BaitListPageState();
}

class _BaitListPageState extends State<BaitListPage> {
  static const _log = Log("BaitListPage");

  // Required for comparisons when updating the list after data model changes.
  // Without a consistent ID, multiple "No Category" headings are created and
  // removed, resulting in a jarring UI transition.
  final _noCategoryId = Id(uuid: "131dfbc9-4313-48b6-930e-867298e553b9");

  BaitCategory? _firstCategory;
  var _baits = <Bait>[];
  final _selectedVariants = <BaitVariant>{};

  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  bool get _isPicking => widget._pickerSettings != null;

  @override
  void initState() {
    super.initState();

    if (_isPicking) {
      for (var attachment in _pickerSettings.initialValues) {
        var variant = _baitManager.variantFromAttachment(attachment);
        if (variant != null) {
          _selectedVariants.add(variant);
        }
      }
    }
  }

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
                top: paddingWidgetSmall,
                bottom: paddingWidget,
              ),
              child: HeadingDivider(
                item.name,
                showDivider: _firstCategory == null || item != _firstCategory,
              ),
            ),
          );
        } else {
          return _buildBaitItem(item);
        }
      },
      itemManager: ManageableListPageItemManager<dynamic>(
        listenerManagers: [
          _baitCategoryManager,
          _baitManager,
          _catchManager,
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
      ..id = _noCategoryId
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

      // Cache first item so we can hide the divider.
      if (result.isEmpty) {
        _firstCategory = category;
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
        isPicking: true,
        onCheckboxChanged: (variant, isChecked) {
          setState(() {
            if (isChecked) {
              _selectedVariants.add(variant);
            } else {
              _selectedVariants.remove(variant);
            }
          });
        },
        selectedItems: _selectedVariants,
      );
    }

    var numberOfCatches = _baitManager.numberOfCatches(bait.id);
    var subtitle = numberOfCatches == 1
        ? format(Strings.of(context).baitListPageNumberOfCatchesSingular,
            [numberOfCatches])
        : format(
            Strings.of(context).baitListPageNumberOfCatches, [numberOfCatches]);

    return ManageableListPageItemModel(
      grandchild: grandchild,
      child: ManageableListImageItem(
        imageName: bait.hasImageName() ? bait.imageName : null,
        title: bait.name,
        subtitle: subtitle,
        trailing: MinChip(format(
          Strings.of(context).baitListPageVariantsLabel,
          [bait.variants.length],
        )),
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
    return widget._pickerSettings!;
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
        var attachments = <BaitAttachment>{};
        attachments.addAll(_noVariantBaits(items).map((e) => e.toAttachment()));
        attachments.addAll(_selectedVariants.map((e) => e.toAttachment()));
        return _pickerSettings.onPicked(context, attachments);
      },
      onPickedAll: (isChecked) => setState(() => _onPickedAll(isChecked)),
      containsAll: (selectedItems) {
        // When checking if all items are selected, we only care about baits
        // without variants (variants are handled separately). If the selected
        // baits and selected variants combined equal the length of all
        // available BaitAttachment objects, we know the user has selected all
        // items.
        var baits = _noVariantBaits(selectedItems);
        var all = _baitManager.baitAttachmentList();
        return baits.length + _selectedVariants.length == all.length;
      },
      title: Text(Strings.of(context).pickerTitleBait),
      multiTitle: Text(Strings.of(context).pickerTitleBaits),
      initialValues: initialValues,
    );
  }

  /// ManageableListPage manages a list of [Bait] objects only, so we use this
  /// method to filter out all non [Bait] objects or [Bait] objects that
  /// include [BaitVariant] objects. [BaitVariant] objects are handled
  /// separately in this class.
  Set<Bait> _noVariantBaits(Set<dynamic> items) {
    var result = List.of(items);
    result..removeWhere((e) => !(e is Bait) || e.variants.isNotEmpty);
    return result.map<Bait>((e) => e as Bait).toSet();
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

class BaitPickerInput extends StatelessWidget {
  final SetInputController<BaitAttachment> controller;
  final String Function(BuildContext) emptyValue;

  /// If true, treats an empty controller value as "all" baits and variants
  /// being selected.
  final bool isAllEmpty;

  BaitPickerInput({
    required this.controller,
    required this.emptyValue,
    this.isAllEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    var baitCategoryManager = BaitCategoryManager.of(context);
    var baitManager = BaitManager.of(context);

    return EntityListenerBuilder(
      managers: [
        baitCategoryManager,
        baitManager,
      ],
      builder: (context) {
        return ValueListenableBuilder<Set<BaitAttachment>?>(
          valueListenable: controller,
          builder: (context, _, __) => MultiListPickerInput(
            padding: insetsHorizontalDefaultVerticalWidget,
            values: baitManager
                .attachmentsDisplayValues(controller.value, context)
                .toSet(),
            emptyValue: emptyValue,
            onTap: () => _showBaitListPage(context, baitManager),
          ),
        );
      },
    );
  }

  void _showBaitListPage(BuildContext context, BaitManager baitManager) {
    var allValues = baitManager.baitAttachmentList().toSet();

    push(
      context,
      BaitListPage._picker(
        pickerSettings: BaitListPagePickerSettings(
          onPicked: (context, attachments) {
            if (isAllEmpty && attachments.containsAll(allValues)) {
              controller.clear();
            } else {
              controller.value = attachments;
            }
            return true;
          },
          initialValues: isAllEmpty && controller.value.isEmpty
              ? allValues
              : controller.value,
        ),
      ),
    );
  }
}
