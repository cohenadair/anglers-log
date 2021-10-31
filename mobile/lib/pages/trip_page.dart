import 'package:flutter/material.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/widgets/atmosphere_wrap.dart';
import 'package:mobile/widgets/label_value_list.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

import '../entity_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/entity_page.dart';
import '../res/dimen.dart';
import '../species_manager.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import 'save_trip_page.dart';

class TripPage extends StatelessWidget {
  static const _skunkedBorderRadius = 7.5;
  static const _skunkedBorderWidth = 1.0;
  static const _skunkedFontSize = 20.0;

  final Trip trip;

  const TripPage(this.trip);

  @override
  Widget build(BuildContext context) {
    var bodyOfWaterManager = BodyOfWaterManager.of(context);
    var catchManager = CatchManager.of(context);
    var tripManager = TripManager.of(context);

    return EntityListenerBuilder(
      managers: [
        bodyOfWaterManager,
        catchManager,
        tripManager,
      ],
      onDeleteEnabled: false,
      builder: (context) {
        // Always fetch the latest trip when the widget tree is (re)built.
        // Fallback on the current trip (if the current was deleted).
        var trip = tripManager.entity(this.trip.id) ?? this.trip;

        return EntityPage(
          customEntityValues: trip.customEntityValues,
          padding: insetsZero,
          onEdit: () => present(context, SaveTripPage.edit(trip)),
          onDelete: () => tripManager.delete(trip.id),
          deleteMessage: tripManager.deleteMessage(context, trip),
          imageNames: tripManager.allImageNames(trip),
          children: <Widget>[
            _buildSkunked(context, trip),
            _buildHeader(context, trip),
            _buildBodiesOfWater(context, trip),
            _buildCatches(context, trip),
            _buildAtmosphere(context, trip),
            _buildCatchesPerAngler(context, trip),
            _buildCatchesPerSpecies(context, trip),
            _buildCatchesPerBait(context, trip),
            _buildCatchesPerFishingSpot(context, trip),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Trip trip) {
    var title = trip.name;
    String? subtitle;
    var elapsed = trip.elapsedDisplayValue(context);

    if (isEmpty(title)) {
      title = elapsed;
    } else {
      subtitle = elapsed;
    }

    return Padding(
      padding: insetsVerticalWidget,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isEmpty(subtitle)
              ? Empty()
              : Padding(
                  padding: insetsHorizontalDefault,
                  child: Text(subtitle!, style: styleListHeading(context)),
                ),
          TitleLabel(title),
          isEmpty(trip.notes)
              ? Empty()
              : Padding(
                  padding: insetsHorizontalDefault,
                  child: Text(trip.notes, style: styleSecondary(context)),
                ),
        ],
      ),
    );
  }

  Widget _buildBodiesOfWater(BuildContext context, Trip trip) {
    if (trip.bodyOfWaterIds.isEmpty) {
      return Empty();
    }

    var bodyOfWaterManager = BodyOfWaterManager.of(context);
    return Padding(
      padding: insetsHorizontalDefaultBottomWidget,
      child: ChipWrap(bodyOfWaterManager
          .list(trip.bodyOfWaterIds)
          .map((e) => bodyOfWaterManager.displayName(context, e))
          .toSet()),
    );
  }

  Widget _buildCatches(BuildContext context, Trip trip) {
    if (trip.catchIds.isEmpty) {
      return Empty();
    }

    return Column(
      children: trip.catchIds.map((e) {
        var cat = CatchManager.of(context).entity(e);
        if (cat == null) {
          return Empty();
        }

        var model = CatchListItemModel(context, cat);
        return ImageListItem(
          imageName: model.imageName,
          title: model.title,
          subtitle: model.subtitle,
          trailing: RightChevronIcon(),
          onTap: () => push(context, CatchPage(cat)),
        );
      }).toList(),
    );
  }

  Widget _buildAtmosphere(BuildContext context, Trip trip) {
    if (!trip.hasAtmosphere()) {
      return Empty();
    }

    return Padding(
      padding: insetsDefault,
      child: AtmosphereWrap(trip.atmosphere),
    );
  }

  Widget _buildCatchesPerAngler(BuildContext context, Trip trip) {
    return LabelValueList(
      title: Strings.of(context).tripCatchesPerAngler,
      padding: insetsBottomWidgetSmall,
      items: _defaultLabelValueListItems(
          context, AnglerManager.of(context), trip.catchesPerAngler),
    );
  }

  Widget _buildCatchesPerSpecies(BuildContext context, Trip trip) {
    return LabelValueList(
      title: Strings.of(context).tripCatchesPerSpecies,
      padding: insetsBottomWidgetSmall,
      items: _defaultLabelValueListItems(
          context, SpeciesManager.of(context), trip.catchesPerSpecies),
    );
  }

  Widget _buildCatchesPerBait(BuildContext context, Trip trip) {
    var items = <LabelValueListItem>[];
    for (var catches in trip.catchesPerBait) {
      var displayName = BaitManager.of(context)
          .attachmentDisplayValue(catches.attachment, context);
      if (isEmpty(displayName)) {
        continue;
      }
      items.add(LabelValueListItem(displayName!, catches.value.toString()));
    }

    return LabelValueList(
      title: Strings.of(context).tripCatchesPerBait,
      padding: insetsBottomWidgetSmall,
      items: items,
    );
  }

  Widget _buildCatchesPerFishingSpot(BuildContext context, Trip trip) {
    return LabelValueList(
      title: Strings.of(context).tripCatchesPerFishingSpot,
      padding: insetsBottomWidgetSmall,
      items: _defaultLabelValueListItems(
          context, FishingSpotManager.of(context), trip.catchesPerFishingSpot),
    );
  }

  Widget _buildSkunked(BuildContext context, Trip trip) {
    if (TripManager.of(context).numberOfCatches(trip) > 0) {
      return Empty();
    }

    return Padding(
      padding: insetsHorizontalDefaultTopWidget,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                const BorderRadius.all(Radius.circular(_skunkedBorderRadius)),
            border: Border.all(color: Colors.red, width: _skunkedBorderWidth),
          ),
          child: Padding(
            padding: insetsSmall,
            child: Text(
              Strings.of(context).tripSkunked.toUpperCase(),
              style: styleError.copyWith(
                fontSize: _skunkedFontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Iterable<LabelValueListItem> _defaultLabelValueListItems(BuildContext context,
      EntityManager manager, List<Trip_CatchesPerEntity> catchesPerEntity) {
    return catchesPerEntity.where((e) => manager.entityExists(e.entityId)).map(
          (e) => LabelValueListItem(
            manager.displayName(context, manager.entity(e.entityId)!),
            e.value.toString(),
          ),
        );
  }
}
