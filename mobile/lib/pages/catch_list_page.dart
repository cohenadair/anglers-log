import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/pages/add_catch_journey.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/save_catch_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/photo.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class CatchListPage extends StatelessWidget {
  /// If false, catches cannot be added. Defaults to true.
  final bool enableAdding;

  /// If not-null, shows only the catches within [dateRange].
  final DateRange dateRange;

  /// If set, shows only the catches whose ID is included in [catchIds].
  final Set<String> catchIds;

  /// If set, shows only the catches whose species is included in [speciesIds].
  final Set<String> speciesIds;

  /// If set, shows only the catches whose fishingSpot is included in
  /// [fishingSpotIds].
  final Set<String> fishingSpotIds;

  /// If set, shows only the catches whose bait is included in [baitIds].
  final Set<String> baitIds;

  bool get filtered => dateRange != null || catchIds.isNotEmpty
      || speciesIds.isNotEmpty || fishingSpotIds.isNotEmpty
      || baitIds.isNotEmpty;

  CatchListPage({
    this.enableAdding = true,
    this.dateRange,
    this.catchIds = const {},
    this.baitIds = const {},
    this.fishingSpotIds = const {},
    this.speciesIds = const {},
  }) : assert(enableAdding != null),
       assert(catchIds != null),
       assert(baitIds != null),
       assert(fishingSpotIds != null),
       assert(speciesIds != null);

  Widget build(BuildContext context) {
    BaitCategoryManager baitCategoryManager = BaitCategoryManager.of(context);
    BaitManager baitManager = BaitManager.of(context);
    CatchManager catchManager = CatchManager.of(context);
    FishingSpotManager fishingSpotManager = FishingSpotManager.of(context);
    SpeciesManager speciesManager = SpeciesManager.of(context);

    return ManageableListPage<Catch>(
      titleBuilder: (catches) => Text(format(
          Strings.of(context).catchListPageTitle, [catches.length])),
      forceCenterTitle: true,
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).catchListPageSearchHint,
        noResultsMessage: Strings.of(context).catchListPageNoSearchResults,
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
        loadItems: (String query) => catchManager.catchesSortedByTimestamp(
          context,
          filter: query,
          dateRange: dateRange,
          catchIds: catchIds,
          speciesIds: speciesIds,
          fishingSpotIds: fishingSpotIds,
          baitIds: baitIds,
        ),
        deleteText: (context, cat) =>
            Text(catchManager.deleteMessage(context, cat)),
        deleteItem: (context, cat) => catchManager.delete(cat),
        addPageBuilder: enableAdding ? () => AddCatchJourney() : null,
        detailPageBuilder: (cat) => CatchPage(cat.id),
        editPageBuilder: (cat) => SaveCatchPage.edit(cat),
      ),
    );
  }

  ManageableListPageItemModel _buildListItem(BuildContext context,
      Catch cat)
  {
    BaitManager baitManager = BaitManager.of(context);
    FishingSpotManager fishingSpotManager = FishingSpotManager.of(context);
    ImageManager imageManager = ImageManager.of(context);
    SpeciesManager speciesManager = SpeciesManager.of(context);

    Widget subtitle2 = Empty();

    var fishingSpot = fishingSpotManager.entity(id: cat.fishingSpotId);
    if (fishingSpot != null && isNotEmpty(fishingSpot.name)) {
      subtitle2 = SubtitleLabel(fishingSpot.name ?? formatLatLng(
        context: context,
        lat: fishingSpot.lat,
        lng: fishingSpot.lng,
      ));
    } else if (isNotEmpty(cat.baitId)) {
      subtitle2 = SubtitleLabel(baitManager
          .formatNameWithCategory(baitManager.entity(id: cat.baitId)));
    }

    List<String> imageNames = imageManager.imageNames(entityId: cat.id);

    return ManageableListPageItemModel(
      child: Row(
        children: [
          Photo.listThumbnail(
              fileName: imageNames.isNotEmpty ? imageNames.first : null),
          Container(width: paddingWidget),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrimaryLabel(speciesManager.entity(id: cat.speciesId).name),
                SubtitleLabel(formatDateTime(context, cat.dateTime)),
                subtitle2,
              ],
            ),
          ),
        ],
      ),
    );
  }
}