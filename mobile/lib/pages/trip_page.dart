import 'package:flutter/material.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/gps_trail_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/pages/gps_trail_page.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/share_utils.dart';
import 'package:mobile/utils/string_utils.dart';
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
import '../utils/gps_trail_utils.dart';
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
          onShare: () => _onShare(context, trip),
          deleteMessage: tripManager.deleteMessage(context, trip),
          imageNames: trip.imageNames,
          children: <Widget>[
            _buildSkunked(context, trip),
            _buildHeader(context, trip),
            _buildBodiesOfWater(context, trip),
            _buildCatches(context, trip),
            _buildGpsTrails(context, trip),
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
    var subtitle = trip.elapsedDisplayValue(context);

    return Padding(
      padding: insetsVerticalDefault,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmptyOr(
            isShowing: isNotEmpty(subtitle),
            childBuilder: (context) =>
                Text(subtitle, style: styleListHeading(context)),
            padding: insetsHorizontalDefault,
          ),
          EmptyOr(
            isShowing: isNotEmpty(trip.name),
            childBuilder: (context) => TitleLabel.style1(trip.name),
          ),
          EmptyOr(
            isShowing: isNotEmpty(trip.notes),
            childBuilder: (context) =>
                Text(trip.notes, style: styleSecondary(context)),
            padding: insetsHorizontalDefault,
          ),
        ],
      ),
    );
  }

  Widget _buildBodiesOfWater(BuildContext context, Trip trip) {
    if (trip.bodyOfWaterIds.isEmpty) {
      return const Empty();
    }

    var bodyOfWaterManager = BodyOfWaterManager.of(context);
    return Padding(
      padding: insetsHorizontalDefaultBottomDefault,
      child: ChipWrap(bodyOfWaterManager
          .list(trip.bodyOfWaterIds)
          .map((e) => bodyOfWaterManager.displayName(context, e))
          .toSet()),
    );
  }

  Widget _buildCatches(BuildContext context, Trip trip) {
    if (trip.catchIds.isEmpty) {
      return const Empty();
    }

    return Column(
      children: trip.catchIds.map((e) {
        var cat = CatchManager.of(context).entity(e);
        if (cat == null) {
          return const Empty();
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

  Widget _buildGpsTrails(BuildContext context, Trip trip) {
    if (trip.gpsTrailIds.isEmpty) {
      return const Empty();
    }

    return Column(
      children: trip.gpsTrailIds.map((e) {
        var gpsTrailManager = GpsTrailManager.of(context);

        var trail = gpsTrailManager.entity(e);
        if (trail == null) {
          return const Empty();
        }

        var model = GpsTrailListItemModel(context, trail);
        return ListItem(
          title: Text(model.title),
          trailing: Row(
            children: [
              model.trailing,
              const HorizontalSpace(paddingDefault),
              RightChevronIcon(),
            ],
          ),
          onTap: () => push(context, GpsTrailPage(trail)),
        );
      }).toList(),
    );
  }

  Widget _buildAtmosphere(BuildContext context, Trip trip) {
    if (!trip.hasAtmosphere()) {
      return const Empty();
    }

    return Padding(
      padding: insetsDefault,
      child: AtmosphereWrap(trip.atmosphere),
    );
  }

  Widget _buildCatchesPerAngler(BuildContext context, Trip trip) {
    return LabelValueList(
      title: Strings.of(context).tripCatchesPerAngler,
      padding: insetsBottomSmall,
      items: _defaultLabelValueListItems(
          context, AnglerManager.of(context), trip.catchesPerAngler),
    );
  }

  Widget _buildCatchesPerSpecies(BuildContext context, Trip trip) {
    return LabelValueList(
      title: Strings.of(context).tripCatchesPerSpecies,
      padding: insetsBottomSmall,
      items: _defaultLabelValueListItems(
          context, SpeciesManager.of(context), trip.catchesPerSpecies),
    );
  }

  Widget _buildCatchesPerBait(BuildContext context, Trip trip) {
    var items = <LabelValueListItem>[];
    for (var catches in trip.catchesPerBait) {
      var displayName = BaitManager.of(context)
          .attachmentDisplayValue(context, catches.attachment);
      if (isEmpty(displayName)) {
        continue;
      }
      items.add(LabelValueListItem(displayName, catches.value.toString()));
    }

    return LabelValueList(
      title: Strings.of(context).tripCatchesPerBait,
      padding: insetsBottomSmall,
      items: items,
    );
  }

  Widget _buildCatchesPerFishingSpot(BuildContext context, Trip trip) {
    var fishingSpotManager = FishingSpotManager.of(context);

    return LabelValueList(
      title: Strings.of(context).tripCatchesPerFishingSpot,
      padding: insetsBottomSmall,
      items: _defaultLabelValueListItems(
        context,
        fishingSpotManager,
        trip.catchesPerFishingSpot,
        labelBuilder: (entityId) => fishingSpotManager.displayName(
          context,
          fishingSpotManager.entity(entityId)!,
          includeBodyOfWater: true,
        ),
      ),
    );
  }

  Widget _buildSkunked(BuildContext context, Trip trip) {
    if (TripManager.of(context).numberOfCatches(trip) > 0) {
      return const Empty();
    }

    return Padding(
      padding: insetsHorizontalDefaultTopDefault,
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
              style: styleError(context).copyWith(
                fontSize: _skunkedFontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Iterable<LabelValueListItem> _defaultLabelValueListItems(
    BuildContext context,
    EntityManager manager,
    List<Trip_CatchesPerEntity> catchesPerEntity, {
    String Function(Id entityId)? labelBuilder,
  }) {
    return catchesPerEntity.where((e) => manager.entityExists(e.entityId)).map(
      (e) {
        return LabelValueListItem(
          labelBuilder?.call(e.entityId) ??
              manager.displayName(context, manager.entity(e.entityId)!),
          e.value.toString(),
        );
      },
    );
  }

  void _onShare(BuildContext context, Trip trip) {
    var tripManager = TripManager.of(context);
    var shareText = "";

    if (trip.hasName()) {
      shareText += tripManager.name(trip);
    }

    shareText += newLineOrEmpty(shareText);
    shareText += trip.elapsedDisplayValue(context);

    shareText += newLineOrEmpty(shareText);
    shareText += format(
        Strings.of(context).shareCatches, [tripManager.numberOfCatches(trip)]);

    share(context, trip.imageNames, text: shareText);
  }
}
