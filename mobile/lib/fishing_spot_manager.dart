import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'catch_manager.dart';
import 'i18n/strings.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';
import 'utils/map_utils.dart';
import 'utils/string_utils.dart';

class FishingSpotManager extends NamedEntityManager<FishingSpot> {
  static FishingSpotManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).fishingSpotManager;

  CatchManager get _catchManager => appManager.catchManager;

  FishingSpotManager(AppManager app) : super(app);

  @override
  FishingSpot entityFromBytes(List<int> bytes) => FishingSpot.fromBuffer(bytes);

  @override
  Id id(FishingSpot fishingSpot) => fishingSpot.id;

  @override
  String name(FishingSpot fishingSpot) => fishingSpot.name;

  @override
  String get tableName => "fishing_spot";

  /// Returns the closest [FishingSpot] within [meters] of [latLng], or null if
  /// one does not exist. [meters] defaults to 30.
  FishingSpot withinRadius(LatLng latLng, [int meters = 30]) {
    if (latLng == null) {
      return null;
    }

    var eligibleFishingSpotsMap = <FishingSpot, double>{};
    for (var fishingSpot in entities.values) {
      var distance =
          distanceBetween(LatLng(fishingSpot.lat, fishingSpot.lng), latLng);
      if (distance <= meters) {
        eligibleFishingSpotsMap[fishingSpot] = distance;
      }
    }

    FishingSpot result;
    var minDistance = (meters + 1).toDouble();

    eligibleFishingSpotsMap.forEach((fishingSpot, distance) {
      if (distance < minDistance) {
        minDistance = distance;
        result = fishingSpot;
      }
    });

    return result;
  }

  /// Returns a [FishingSpot] with the same coordinates as the given
  /// [FishingSpot], or null if one doesn't exist.
  FishingSpot withLatLng(FishingSpot rhs) {
    if (rhs == null) {
      return null;
    }
    return entities.values.firstWhere(
        (fishingSpot) =>
            fishingSpot.lat == rhs.lat && fishingSpot.lng == rhs.lng,
        orElse: () => null);
  }

  int numberOfCatches(FishingSpot fishingSpot) {
    if (fishingSpot == null) {
      return 0;
    }

    var result = 0;
    _catchManager.list().forEach((cat) {
      result += fishingSpot.id == cat.fishingSpotId ? 1 : 0;
    });
    return result;
  }

  String deleteMessage(BuildContext context, FishingSpot fishingSpot) {
    assert(context != null);
    assert(fishingSpot != null);

    var numOfCatches = numberOfCatches(fishingSpot);
    var hasNameString = numOfCatches == 1
        ? Strings.of(context).mapPageDeleteFishingSpotSingular
        : Strings.of(context).mapPageDeleteFishingSpot;

    if (isNotEmpty(fishingSpot.name)) {
      return format(hasNameString, [fishingSpot.name, numOfCatches]);
    } else if (numOfCatches == 1) {
      return format(Strings.of(context).mapPageDeleteFishingSpotNoNameSingular,
          [numOfCatches]);
    } else {
      return format(
          Strings.of(context).mapPageDeleteFishingSpotNoName, [numOfCatches]);
    }
  }
}
