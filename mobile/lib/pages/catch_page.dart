import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/pages/bait_page.dart';
import 'package:mobile/pages/entity_page.dart';
import 'package:mobile/pages/save_catch_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/static_fishing_spot.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class CatchPage extends StatefulWidget {
  final String catchId;

  CatchPage(this.catchId) : assert(isNotEmpty(catchId));

  @override
  _CatchPageState createState() => _CatchPageState();
}

class _CatchPageState extends State<CatchPage> {
  BaitManager get _baitManager => BaitManager.of(context);
  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);
  CatchManager get _catchManager => CatchManager.of(context);
  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);
  ImageManager get _imageManager => ImageManager.of(context);
  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  Catch get _catch => _catchManager.entity(id: widget.catchId);

  // TODO: Remove this when Google Maps performance issue is fixed.
  // https://github.com/flutter/flutter/issues/28493
  Future<bool> _fishingSpotFuture =
      Future.delayed(Duration(milliseconds: 150), () => true);

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [
        _baitCategoryManager,
        _baitManager,
        _catchManager,
        _fishingSpotManager,
        _speciesManager,
      ],
      // When deleted, we pop immediately. Don't reload; catch will be null.
      onDeleteEnabled: false,
      builder: (context) => EntityPage(
        entityId: _catch.id,
        padding: insetsZero,
        onEdit: () => present(context, SaveCatchPage.edit(_catch)),
        onDelete: () => _catchManager.delete(_catch),
        deleteMessage: _catchManager.deleteMessage(context, _catch),
        imageNames: _imageManager.imageNames(entityId: widget.catchId),
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: paddingDefault,
              right: paddingDefault,
              bottom: paddingSmall,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleLabel(
                    _speciesManager.entity(id: _catch.speciesId).name),
                Padding(
                  padding: const EdgeInsets.only(
                    left: paddingDefault,
                  ),
                  child: SubtitleLabel(
                    formatDateTime(context,
                        DateTime.fromMillisecondsSinceEpoch(_catch.timestamp)),
                  ),
                ),
              ],
            ),
          ),
          _buildBait(),
          EmptyFutureBuilder<bool>(
            future: _fishingSpotFuture,
            builder: (context, _) => _buildFishingSpot(),
          ),
        ],
      ),
    );
  }

  Widget _buildBait() {
    if (!_catch.hasBait) {
      return Empty();
    }

    Bait bait = _baitManager.entity(id: _catch.baitId);

    Widget subtitle;
    if (bait.hasCategory) {
      subtitle = SubtitleLabel(
          _baitCategoryManager.entity(id: bait.categoryId).name);
    }

    return ListItem(
      title: Label(bait.name),
      subtitle: subtitle,
      trailing: RightChevronIcon(),
      onTap: () => push(context, BaitPage(bait.id,
        static: true,
      )),
    );
  }

  Widget _buildFishingSpot() {
    if (!_catch.hasFishingSpot) {
      return Empty();
    }

    FishingSpot fishingSpot =
        _fishingSpotManager.entity(id: _catch.fishingSpotId);

    return StaticFishingSpot(fishingSpot,
      padding: insetsHorizontalDefaultVerticalSmall,
    );
  }
}