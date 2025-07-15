import 'package:flutter/material.dart';
import 'package:mobile/named_entity_manager.dart';

import 'app_manager.dart';
import 'fishing_spot_manager.dart';
import 'model/gen/anglers_log.pb.dart';
import 'utils/string_utils.dart';

class BodyOfWaterManager extends NamedEntityManager<BodyOfWater> {
  static BodyOfWaterManager of(BuildContext context) =>
      AppManager.get.bodyOfWaterManager;

  FishingSpotManager get _fishingSpotManager => appManager.fishingSpotManager;

  BodyOfWaterManager(super.app);

  @override
  BodyOfWater entityFromBytes(List<int> bytes) => BodyOfWater.fromBuffer(bytes);

  @override
  Id id(BodyOfWater entity) => entity.id;

  @override
  String name(BodyOfWater entity) => entity.name;

  @override
  String get tableName => "body_of_water";

  int numberOfFishingSpots(Id? bodyOfWaterId) => numberOf<FishingSpot>(
    bodyOfWaterId,
    _fishingSpotManager.list(),
    (spot) => spot.bodyOfWaterId == bodyOfWaterId,
  );

  String deleteMessage(BuildContext context, BodyOfWater bodyOfWater) {
    var numOfSpots = numberOfFishingSpots(bodyOfWater.id);
    return numOfSpots == 1
        ? Strings.of(
            context,
          ).bodyOfWaterListPageDeleteMessageSingular(bodyOfWater.name)
        : Strings.of(
            context,
          ).bodyOfWaterListPageDeleteMessage(bodyOfWater.name, numOfSpots);
  }
}
