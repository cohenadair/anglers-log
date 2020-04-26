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
import 'package:mobile/res/dimen.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/thumbnail.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class CatchListPage extends StatefulWidget {
  @override
  _CatchListPageState createState() => _CatchListPageState();
}

class _CatchListPageState extends State<CatchListPage> {
  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);
  BaitManager get _baitManager => BaitManager.of(context);
  CatchManager get _catchManager => CatchManager.of(context);
  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);
  ImageManager get _imageManager => ImageManager.of(context);
  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  List<Catch> get _catches => _catchManager.entityListSortedByTimestamp;

  Widget build(BuildContext context) {
    return EntityListenerBuilder<Catch>(
      manager: _catchManager,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(format(Strings.of(context).catchListPageTitle,
              [_catchManager.entityCount])),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => present(context, AddCatchJourney()),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: _catches.length,
          itemBuilder: (context, i) => _buildListItem(_catches[i]),
        ),
      ),
    );
  }

  Widget _buildListItem(Catch cat) {
    Widget subtitle2 = Empty();
    if (isNotEmpty(cat.fishingSpotId)) {
      var fishingSpot = _fishingSpotManager.entity(id: cat.fishingSpotId);
      subtitle2 = SubtitleText(fishingSpot.name ?? formatLatLng(
        context: context,
        lat: fishingSpot.lat,
        lng: fishingSpot.lng,
      ));
    } else if (isNotEmpty(cat.baitId)) {
      var bait = _baitManager.entity(id: cat.baitId);
      if (isNotEmpty(bait.categoryId)) {
        var category = _baitCategoryManager.entity(id: bait.categoryId);
        subtitle2 = SubtitleText(formatBaitName(bait, category));
      } else {
        subtitle2 = SubtitleText(formatBaitName(bait));
      }
    }

    List<File> imageFiles = _imageManager.imageFiles(entityId: cat.id);

    return InkWell(
      onTap: () {
      },
      child: Padding(
        padding: insetsDefault,
        child: Row(children: [
          Thumbnail.listItem(
              file: imageFiles.isNotEmpty ? imageFiles.first : null),
          Container(width: paddingWidget),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelText(_speciesManager.entity(id: cat.speciesId).name),
              SubtitleText(formatDateTime(context, cat.dateTime)),
              subtitle2,
            ],
          ),
          Spacer(),
          Container(width: paddingWidget),
          RightChevronIcon(),
        ]),
      ),
    );
  }
}