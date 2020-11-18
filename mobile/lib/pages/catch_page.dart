import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
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

class CatchPage extends StatefulWidget {
  final Id catchId;

  CatchPage(this.catchId) : assert(catchId != null);

  @override
  _CatchPageState createState() => _CatchPageState();
}

class _CatchPageState extends State<CatchPage> {
  BaitManager get _baitManager => BaitManager.of(context);
  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);
  CatchManager get _catchManager => CatchManager.of(context);
  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);
  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  Catch get _catch => _catchManager.entity(widget.catchId);

  // TODO: Remove this when Google Maps performance issue is fixed.
  // https://github.com/flutter/flutter/issues/28493
  Future<bool> _fishingSpotFuture =
      Future.delayed(Duration(milliseconds: 150), () => true);

  @override
  Widget build(BuildContext context) {
    assert(_catch != null);

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
        customEntityValues: _catch.customEntityValues,
        padding: insetsZero,
        onEdit: () => present(context, SaveCatchPage.edit(_catch)),
        onDelete: () => _catchManager.delete(_catch.id),
        deleteMessage: _catchManager.deleteMessage(context, _catch),
        imageNames: _catch.imageNames,
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
                TitleLabel(_speciesManager.entity(_catch.speciesId).name),
                Padding(
                  padding: const EdgeInsets.only(
                    left: paddingDefault,
                  ),
                  child: SubtitleLabel(
                    formatTimestamp(context, _catch.timestamp),
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
    Bait bait = _baitManager.entity(_catch.baitId);
    if (bait == null) {
      return Empty();
    }

    Widget subtitle;
    BaitCategory baitCategory =
          _baitCategoryManager.entity(bait.baitCategoryId);
    if (baitCategory != null) {
      subtitle = SubtitleLabel(baitCategory.name);
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
    FishingSpot fishingSpot =
        _fishingSpotManager.entity(_catch.fishingSpotId);
    if (fishingSpot == null) {
      return Empty();
    }

    return StaticFishingSpot(
      fishingSpot,
      padding: insetsHorizontalDefaultVerticalSmall,
    );
  }
}