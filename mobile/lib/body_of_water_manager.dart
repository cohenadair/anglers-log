import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'catch_field_entity_manager.dart';
import 'fishing_spot_manager.dart';
import 'i18n/strings.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/string_utils.dart';

class BodyOfWaterManager extends CatchFieldEntityManager<BodyOfWater> {
  static BodyOfWaterManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).bodyOfWaterManager;

  FishingSpotManager get _fishingSpotManager => appManager.fishingSpotManager;

  BodyOfWaterManager(AppManager app) : super(app);

  @override
  BodyOfWater entityFromBytes(List<int> bytes) => BodyOfWater.fromBuffer(bytes);

  @override
  Id id(BodyOfWater entity) => entity.id;

  @override
  List<Id> idFromCatch(Catch cat) {
    var fishingSpot = _fishingSpotManager.entity(cat.fishingSpotId);
    if (fishingSpot == null) {
      return [];
    }

    if (fishingSpot.hasBodyOfWaterId()) {
      return [fishingSpot.bodyOfWaterId];
    }

    return [];
  }

  @override
  String name(BodyOfWater entity) => entity.name;

  @override
  String get tableName => "body_of_water";

  int numberOfFishingSpots(Id? bodyOfWaterId) => numberOf<FishingSpot>(
      bodyOfWaterId,
      _fishingSpotManager.list(),
      (spot) => spot.bodyOfWaterId == bodyOfWaterId);

  String deleteMessage(BuildContext context, BodyOfWater bodyOfWater) {
    var numOfSpots = numberOfFishingSpots(bodyOfWater.id);
    var string = numOfSpots == 1
        ? Strings.of(context).bodyOfWaterListPageDeleteMessageSingular
        : Strings.of(context).bodyOfWaterListPageDeleteMessage;
    return format(string, [bodyOfWater.name, numOfSpots]);
  }
}
