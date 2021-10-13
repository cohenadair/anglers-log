import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

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
import '../utils/date_time_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/list_item.dart';
import '../widgets/widget.dart';

class CatchListPage extends StatelessWidget {
  /// If false, catches cannot be added. Defaults to true.
  final bool enableAdding;

  /// If not-null, shows only the catches within [dateRange].
  final DateRange? dateRange;

  /// If set, shows only the catches whose ID is included in [catchIds].
  final Set<Id> catchIds;

  /// If set, shows only the catches whose species is included in [speciesIds].
  final Set<Id> speciesIds;

  /// If set, shows only the catches whose fishingSpot is included in
  /// [fishingSpotIds].
  final Set<Id> fishingSpotIds;

  /// If set, shows only the catches whose bait is included in [baits].
  final Set<BaitAttachment> baits;

  /// See [ManageableListPage.pickerSettings].
  final ManageableListPagePickerSettings<Catch>? pickerSettings;

  bool get filtered =>
      dateRange != null ||
      catchIds.isNotEmpty ||
      speciesIds.isNotEmpty ||
      fishingSpotIds.isNotEmpty ||
      baits.isNotEmpty;

  const CatchListPage({
    this.enableAdding = true,
    this.dateRange,
    this.catchIds = const {},
    this.baits = const {},
    this.fishingSpotIds = const {},
    this.speciesIds = const {},
    this.pickerSettings,
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
        loadItems: (query) => catchManager.catchesSortedByTimestamp(
          context,
          filter: query,
          dateRange: dateRange,
          catchIds: catchIds,
          speciesIds: speciesIds,
          fishingSpotIds: fishingSpotIds,
          baits: baits,
        ),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: CustomIcons.catches,
          title: Strings.of(context).catchListPageEmptyListTitle,
          description: Strings.of(context).catchListPageEmptyListDescription,
        ),
        deleteWidget: (context, cat) =>
            Text(catchManager.deleteMessage(context, cat)),
        deleteItem: (context, cat) => catchManager.delete(cat.id),
        addPageBuilder: enableAdding ? () => const AddCatchJourney() : null,
        detailPageBuilder: (cat) => CatchPage(cat),
        editPageBuilder: (cat) => SaveCatchPage.edit(cat),
      ),
    );
  }

  ManageableListPageItemModel _buildListItem(BuildContext context, Catch cat) {
    var baitManager = BaitManager.of(context);
    var fishingSpotManager = FishingSpotManager.of(context);
    var speciesManager = SpeciesManager.of(context);

    String? subtitle2;

    var fishingSpot = fishingSpotManager.entity(cat.fishingSpotId);
    if (fishingSpot != null && isNotEmpty(fishingSpot.name)) {
      // Use fishing spot name as subtitle if available.
      subtitle2 = fishingSpot.name;
    } else if (cat.baits.isNotEmpty) {
      // Fallback on bait as a subtitle.
      var formattedName =
          baitManager.formatNameWithCategory(cat.baits.first.baitId);
      if (isNotEmpty(formattedName)) {
        subtitle2 = formattedName!;
      }
    }

    return ManageableListPageItemModel(
      child: ManageableListImageItem(
        imageName: cat.imageNames.isNotEmpty ? cat.imageNames.first : null,
        title: speciesManager.entity(cat.speciesId)?.name ??
            Strings.of(context).unknownSpecies,
        subtitle: formatTimestamp(context, cat.timestamp.toInt()),
        subtitle2: subtitle2,
        trailing: CatchFavoriteStar(cat),
      ),
    );
  }
}
