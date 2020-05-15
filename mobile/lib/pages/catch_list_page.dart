import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
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
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/thumbnail.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class CatchListPage extends StatelessWidget {
  Widget build(BuildContext context) {
    CatchManager catchManager = CatchManager.of(context);
    List<Catch> catches = catchManager.entityListSortedByTimestamp;

    return EntityListenerBuilder<Catch>(
      manager: catchManager,
      builder: (context) => ManageableListPage<Catch>(
        title: Text(format(Strings.of(context).catchListPageTitle,
            [catchManager.entityCount])),
        forceCenterTitle: true,
        searchSettings: ManageableListPageSearchSettings(
          hint: Strings.of(context).catchListPageSearchHint,
          onStart: () {
            // TODO
          },
        ),
        itemCount: catches.length,
        itemBuilder: (context, i) => _buildListItem(context, catches[i]),
        itemsHaveThumbnail: true,
        itemManager: ManageableListPageItemManager(
          deleteText: (context, cat) =>
              Text(Strings.of(context).catchPageDeleteMessage),
          deleteItem: (context, cat) => catchManager.delete(cat),
          addPageBuilder: () => AddCatchJourney(),
          detailPageBuilder: (cat) => CatchPage(cat.id),
          editPageBuilder: (cat) => SaveCatchPage.edit(cat),
        ),
      ),
    );
  }

  ManageableListPageItemModel<Catch> _buildListItem(BuildContext context,
      Catch cat)
  {
    BaitCategoryManager baitCategoryManager = BaitCategoryManager.of(context);
    BaitManager baitManager = BaitManager.of(context);
    FishingSpotManager fishingSpotManager = FishingSpotManager.of(context);
    ImageManager imageManager = ImageManager.of(context);
    SpeciesManager speciesManager = SpeciesManager.of(context);

    Widget subtitle2 = Empty();

    var fishingSpot = fishingSpotManager.entity(id: cat.fishingSpotId);
    if (fishingSpot != null && isNotEmpty(fishingSpot.name)) {
      subtitle2 = SubtitleText(fishingSpot.name ?? formatLatLng(
        context: context,
        lat: fishingSpot.lat,
        lng: fishingSpot.lng,
      ));
    } else if (isNotEmpty(cat.baitId)) {
      var bait = baitManager.entity(id: cat.baitId);
      if (isNotEmpty(bait.categoryId)) {
        var category = baitCategoryManager.entity(id: bait.categoryId);
        subtitle2 = SubtitleText(formatBaitName(bait, category));
      } else {
        subtitle2 = SubtitleText(formatBaitName(bait));
      }
    }

    List<File> imageFiles = imageManager.imageFiles(entityId: cat.id);

    return ManageableListPageItemModel<Catch>(
      value: cat,
      child: Row(
        children: [
          Thumbnail.listItem(
              file: imageFiles.isNotEmpty ? imageFiles.first : null),
          Container(width: paddingWidget),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelText(speciesManager.entity(id: cat.speciesId).name),
              SubtitleText(formatDateTime(context, cat.dateTime)),
              subtitle2,
            ],
          ),
        ],
      ),
    );
  }
}