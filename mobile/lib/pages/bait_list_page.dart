import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/collection_utils.dart';

import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../catch_manager.dart';
import '../entity_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/bait_page.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_bait_page.dart';
import '../res/dimen.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/sectioned_list_model.dart';
import '../utils/string_utils.dart';
import '../widgets/bait_variant_list_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/list_item.dart';
import '../widgets/multi_list_picker_input.dart';
import '../widgets/widget.dart';

class BaitListPage extends StatefulWidget {
  final BaitListPagePickerSettings? pickerSettings;

  /// To create a picker, consider using [BaitPickerInput].
  const BaitListPage({this.pickerSettings});

  @override
  BaitListPageState createState() => BaitListPageState();
}

class BaitListPageState extends State<BaitListPage> {
  late final _BaitListPageModel _model;
  final _selectedVariants = <BaitVariant>{};

  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  MediaQueryData get _mediaQuery => MediaQuery.of(context);

  bool get _isPicking => widget.pickerSettings != null;

  @override
  void initState() {
    super.initState();

    _model = _BaitListPageModel(
      baitCategoryManager: _baitCategoryManager,
      baitManager: _baitManager,
      itemBuilder: _buildBaitItem,
    );

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
      pickerSettings: _manageableListPagePickerSettings,
      itemBuilder: _model.buildItemModel,
      itemManager: ManageableListPageItemManager<dynamic>(
        listenerManagers: [
          _baitCategoryManager,
          _baitManager,
          _catchManager,
        ],
        loadItems: (filter) => _model.buildModel(context, filter),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: iconBait,
          title: Strings.of(context).baitListPageEmptyListTitle,
          description: Strings.of(context).baitListPageEmptyListDescription,
        ),
        deleteWidget: (context, bait) =>
            Text(_baitManager.deleteMessage(context, bait)),
        deleteItem: (context, bait) {
          assert(bait is Bait, "Cannot delete a non-bait object");
          _baitManager.delete(bait.id);
        },
        addPageBuilder: () => const SaveBaitPage(),
        detailPageBuilder: (bait) => BaitPage(bait as Bait),
        editPageBuilder: (bait) => SaveBaitPage.edit(bait),
      ),
    );
  }

  ManageableListPageItemModel _buildBaitItem(BuildContext context, Bait bait) {
    Widget? grandchild;
    if (bait.variants.isNotEmpty && _isPicking) {
      grandchild = BaitVariantListInput.static(
        bait.variants,
        showHeader: false,
        isCondensed: true,
        onCheckboxChanged:
            _pickerSettings.isMulti ? _onVariantCheckboxChanged : null,
        onPicked: _pickerSettings.isMulti ? null : _onVariantPicked,
        selectedItems: _selectedVariants,
      );
    }

    var variantLabel = format(
      bait.variants.length == 1
          ? Strings.of(context).baitListPageVariantLabel
          : Strings.of(context).baitListPageVariantsLabel,
      [bait.variants.length],
    );

    // For people who use larger text and smaller screens, the variant label,
    // as a chip, takes up too much of the screen, cutting off the bait's
    // name.
    var showVariantsAsChip = _mediaQuery.textScaleFactor < maxTextScale;

    return ManageableListPageItemModel(
      grandchild: grandchild,
      child: ManageableListImageItem(
        imageName: bait.hasImageName() ? bait.imageName : null,
        title: bait.name,
        subtitle: formatNumberOfCatches(
            context, _baitManager.numberOfCatchQuantities(bait.id)),
        subtitle2: showVariantsAsChip ? null : variantLabel,
        trailing: showVariantsAsChip ? MinChip(variantLabel) : null,
      ),
    );
  }

  void _onVariantCheckboxChanged(BaitVariant variant, bool isChecked) {
    setState(() {
      if (isChecked) {
        _selectedVariants.add(variant);
      } else {
        _selectedVariants.remove(variant);
      }
    });
  }

  void _onVariantPicked(BaitVariant variant) {
    _pickerSettings.onPicked(context, {variant.toAttachment()});
    Navigator.of(context).pop();
  }

  void _onPickedAll(bool isChecked) {
    if (isChecked) {
      for (var bait in _model.items) {
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

  ManageableListPagePickerSettings<dynamic>?
      get _manageableListPagePickerSettings {
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
      if (attachment.hasVariantId() &&
          (_pickerSettings.isMulti ||
              _selectedVariants
                  .containsWhere((e) => e.id == attachment.variantId))) {
        continue;
      }

      var bait = _baitManager.entity(attachment.baitId);
      if (bait != null) {
        initialValues.add(bait);
      }
    }

    return ManageableListPagePickerSettings<dynamic>(
      // Invoked when a Bait is tapped, _not_ when a BaitVariant is tapped.
      onPicked: (context, items) {
        if (_pickerSettings.isMulti) {
          var attachments = <BaitAttachment>{};
          attachments
              .addAll(_noVariantBaits(items).map((e) => e.toAttachment()));
          attachments.addAll(_selectedVariants.map((e) => e.toAttachment()));
          return _pickerSettings.onPicked(context, attachments);
        } else {
          return _pickerSettings
              .onPicked(context, {(items.first as Bait).toAttachment()});
        }
      },
      onPickedAll: (isChecked) => setState(() => _onPickedAll(isChecked)),
      containsAll: (selectedItems) {
        // When checking if all items are selected, we only care about baits
        // without variants (variants are handled separately). If the selected
        // baits and selected variants combined equal the length of all
        // available BaitAttachment objects, we know the user has selected all
        // items.
        var baits = _noVariantBaits(selectedItems);
        var all = _baitManager.attachmentList();
        return baits.length + _selectedVariants.length == all.length;
      },
      title: Text(Strings.of(context).pickerTitleBait),
      multiTitle: Text(Strings.of(context).pickerTitleBaits),
      initialValues: initialValues,
      isRequired: _pickerSettings.isRequired,
      isMulti: _pickerSettings.isMulti,
    );
  }

  /// ManageableListPage manages a list of [Bait] objects only, so we use this
  /// method to filter out all non [Bait] objects or [Bait] objects that
  /// include [BaitVariant] objects. [BaitVariant] objects are handled
  /// separately in this class.
  Set<Bait> _noVariantBaits(Set<dynamic> items) {
    var result = List.of(items);
    result.removeWhere((e) => e is! Bait || e.variants.isNotEmpty);
    return result.map<Bait>((e) => e as Bait).toSet();
  }
}

class BaitListPagePickerSettings {
  final bool Function(BuildContext, Set<BaitAttachment>) onPicked;
  final Set<BaitAttachment> initialValues;
  final bool isRequired;
  final bool isMulti;

  BaitListPagePickerSettings({
    required this.onPicked,
    required this.initialValues,
    this.isRequired = false,
    this.isMulti = true,
  });

  BaitListPagePickerSettings.fromManageableList(
      ManageableListPagePickerSettings<BaitAttachment> settings)
      : onPicked = settings.onPicked,
        initialValues = settings.initialValues,
        isRequired = settings.isRequired,
        isMulti = settings.isMulti;
}

class BaitPickerInput extends StatelessWidget {
  final SetInputController<BaitAttachment> controller;
  final String Function(BuildContext) emptyValue;

  /// If true, treats an empty controller value as "all" baits and variants
  /// being selected.
  final bool isAllEmpty;

  const BaitPickerInput({
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
            padding: insetsDefault,
            values: baitManager
                .attachmentsDisplayValues(context, controller.value)
                .toSet(),
            emptyValue: emptyValue,
            onTap: () => _showBaitListPage(context, baitManager),
          ),
        );
      },
    );
  }

  void _showBaitListPage(BuildContext context, BaitManager baitManager) {
    var allValues = baitManager.attachmentList().toSet();

    push(
      context,
      BaitListPage(
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

class _BaitListPageModel extends SectionedListModel<BaitCategory, Bait> {
  final _noCategoryId = Id(uuid: "131dfbc9-4313-48b6-930e-867298e553b9");

  final BaitCategoryManager baitCategoryManager;
  final BaitManager baitManager;
  final ManageableListPageItemModel Function(BuildContext, Bait) itemBuilder;

  _BaitListPageModel({
    required this.baitCategoryManager,
    required this.baitManager,
    required this.itemBuilder,
  });

  @override
  ManageableListPageItemModel buildItem(BuildContext context, Bait item) =>
      itemBuilder(context, item);

  @override
  List<Bait> filteredItemList(BuildContext context, String? filter) =>
      baitManager.filteredList(context, filter);

  @override
  Id headerId(BaitCategory header) => header.id;

  @override
  String headerName(BaitCategory header) => header.name;

  @override
  bool itemHasHeaderId(Bait item) => item.hasBaitCategoryId();

  @override
  Id itemHeaderId(Bait item) => item.baitCategoryId;

  @override
  String itemName(BuildContext context, Bait item) => item.name;

  @override
  BaitCategory noSectionHeader(BuildContext context) {
    return BaitCategory(
      id: _noCategoryId,
      name: Strings.of(context).baitListPageOtherCategory,
    );
  }

  @override
  Id get noSectionHeaderId => _noCategoryId;

  @override
  List<BaitCategory> sectionHeaders(BuildContext context) =>
      baitCategoryManager.listSortedByDisplayName(context);
}
