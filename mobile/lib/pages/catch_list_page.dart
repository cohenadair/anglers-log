import 'package:flutter/material.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/pages/add_catch_journey.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/image_placeholder.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class CatchListPage extends StatefulWidget {
  @override
  _CatchListPageState createState() => _CatchListPageState();
}

class _CatchListPageState extends State<CatchListPage> {
  final double _thumbnailSize = 45;

  List<Catch> _catches = [];

  // Stash futures used in list items to minimize database calls.
  Map<String, Future<Species>> _speciesFutures = {};
  Map<String, Future<FishingSpot>> _fishingSpotFutures = {};
  Map<String, Future<Bait>> _baitFutures = {};
  Map<String, Future<BaitCategory>> _baitCategoryFutures = {};

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: EmptyFutureBuilder<int>(
          future: CatchManager.of(context).numberOfCatches,
          builder: (context, numberOfCatches) => Text(format(
              Strings.of(context).catchListPageTitle, [numberOfCatches])),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => present(context, AddCatchJourney()),
          ),
        ],
      ),
      body: CatchesBuilder(
        onUpdate: (catches) {
          _catches = catches;

          // Reset futures for all catches.
          _speciesFutures.clear();
          _fishingSpotFutures.clear();
          _baitFutures.clear();

          for (Catch cat in _catches) {
            _speciesFutures[cat.speciesId] =
                SpeciesManager.of(context).fetch(id: cat.speciesId);

            if (isNotEmpty(cat.fishingSpotId)) {
              _fishingSpotFutures[cat.fishingSpotId] =
                  FishingSpotManager.of(context).fetch(id: cat.fishingSpotId);
            }

            if (isNotEmpty(cat.baitId)) {
              _baitFutures[cat.baitId] =
                  BaitManager.of(context).fetchBait(id: cat.baitId);
            }
          }
        },
        builder: (context) => ListView.builder(
          itemCount: _catches.length,
          itemBuilder: (context, index) => _buildListItem(_catches[index]),
        ),
      ),
    );
  }

  Widget _buildListItem(Catch cat) {
    Widget subtitle2 = Empty();
    if (isNotEmpty(cat.fishingSpotId)) {
      subtitle2 = EmptyFutureBuilder<FishingSpot>(
        future: _fishingSpotFutures[cat.fishingSpotId],
        builder: (context, fishingSpot) {
          return SubtitleText(fishingSpot.name ?? formatLatLng(
            context: context,
            lat: fishingSpot.lat,
            lng: fishingSpot.lng,
          ));
        },
      );
    } else if (isNotEmpty(cat.baitId)) {
      subtitle2 = EmptyFutureBuilder<Bait>(
        future: _baitFutures[cat.baitId],
        builder: (context, bait) {
          if (isNotEmpty(bait.categoryId)) {
            _baitCategoryFutures.putIfAbsent(bait.categoryId, () =>
                BaitManager.of(context).fetchCategory(id: bait.categoryId));

            return EmptyFutureBuilder<BaitCategory>(
              future: _baitCategoryFutures[bait.categoryId],
              builder: (context, category) =>
                  SubtitleText(formatBaitName(bait, category)),
            );
          }

          return SubtitleText(formatBaitName(bait));
        },
      );
    }

    return Row(children: [
      ImagePlaceholder(size: _thumbnailSize),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmptyFutureBuilder<Species>(
            future: _speciesFutures[cat.speciesId],
            builder: (context, species) => LabelText(species.name),
          ),
          SubtitleText(formatDateTime(context, cat.dateTime)),
          subtitle2,
        ],
      ),
      RightChevronIcon(),
    ]);
  }
}