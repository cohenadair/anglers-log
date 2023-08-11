import 'package:flutter/material.dart';
import 'package:mobile/utils/catch_utils.dart';

import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../catch_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/add_catch_journey.dart';
import '../pages/catch_page.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_catch_page.dart';
import '../res/gen/custom_icons.dart';
import '../species_manager.dart';
import '../utils/page_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/list_item.dart';

class CatchListPage extends StatelessWidget {
  /// If false, catches cannot be added. Defaults to true.
  final bool enableAdding;

  /// When not empty, only these [Catch] objects are shown in the list. If
  /// empty, all catches are shown.
  final List<Catch> catches;

  /// See [ManageableListPage.pickerSettings].
  final ManageableListPagePickerSettings<Catch>? pickerSettings;

  final CatchListItemModelSubtitleType? subtitleType;

  const CatchListPage({
    this.enableAdding = true,
    this.catches = const [],
    this.pickerSettings,
    this.subtitleType,
  });

  @override
  Widget build(BuildContext context) {
    var baitCategoryManager = BaitCategoryManager.of(context);
    var baitManager = BaitManager.of(context);
    var catchManager = CatchManager.of(context);
    var fishingSpotManager = FishingSpotManager.of(context);
    var speciesManager = SpeciesManager.of(context);

    return ManageableListPage<Catch>(
      titleBuilder: (catches) => Text(
        format(Strings.of(context).catchListPageTitle, [catches.length]),
      ),
      forceCenterTitle: pickerSettings == null,
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).catchListPageSearchHint,
      ),
      pickerSettings: pickerSettings?.copyWith(
        multiTitle: Text(Strings.of(context).pickerTitleCatches),
      ),
      itemBuilder: _buildListItem,
      itemsHaveThumbnail: true,
      itemManager: ManageableListPageItemManager<Catch>(
        listenerManagers: [
          baitCategoryManager,
          baitManager,
          catchManager,
          fishingSpotManager,
          speciesManager,
        ],
        loadItems: (query) => catches.isEmpty
            ? catchManager.catches(context, filter: query)
            : catches,
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: CustomIcons.catches,
          title: Strings.of(context).catchListPageEmptyListTitle,
          description: Strings.of(context).catchListPageEmptyListDescription,
        ),
        deleteWidget: (context, cat) =>
            Text(catchManager.deleteMessage(context, cat)),
        deleteItem: (context, cat) => catchManager.delete(cat.id),
        onAddButtonPressed: enableAdding
            ? () => present(context, const AddCatchJourney())
            : null,
        detailPageBuilder: (cat) => CatchPage(cat),
        editPageBuilder: (cat) => SaveCatchPage.edit(cat),
      ),
    );
  }

  ManageableListPageItemModel _buildListItem(BuildContext context, Catch cat) {
    var model = CatchListItemModel(context, cat, subtitleType);
    return ManageableListPageItemModel(
      child: ManageableListImageItem(
        imageName: model.imageName,
        title: model.title,
        subtitle: model.subtitle,
        subtitle2: model.subtitle2,
        trailing: model.trailing,
      ),
    );
  }
}
