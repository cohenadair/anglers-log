import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

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
  /// one does not exist.
  FishingSpot withinRadius(LatLng latLng, [int meters = 0]) {
    if (latLng == null) {
      return null;
    }

    Map<FishingSpot, double> eligibleFishingSpotsMap = {};
    for (FishingSpot fishingSpot in entities.values) {
      double distance = distanceBetween(
          LatLng(fishingSpot.lat, fishingSpot.lng), latLng);
      if (distance <= meters) {
        eligibleFishingSpotsMap[fishingSpot] = distance;
      }
    }

    FishingSpot result;
    double minDistance = (meters + 1).toDouble();

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
    return entities.values.firstWhere((fishingSpot) =>
        fishingSpot.lat == rhs.lat && fishingSpot.lng == rhs.lng,
        orElse: () => null);
  }

  int numberOfCatches(FishingSpot fishingSpot) {
    if (fishingSpot == null) {
      return 0;
    }

    int result = 0;
    _catchManager.list().forEach((cat) {
      result += fishingSpot.id == cat.fishingSpotId ? 1 : 0;
    });
    return result;
  }

  String deleteMessage(BuildContext context, FishingSpot fishingSpot) {
    assert(context != null);
    assert(fishingSpot != null);

    int numOfCatches = numberOfCatches(fishingSpot);
    String hasNameString = numOfCatches == 1
        ? Strings.of(context).mapPageDeleteFishingSpotSingular
        : Strings.of(context).mapPageDeleteFishingSpot;

    if (isNotEmpty(fishingSpot.name)) {
      return format(hasNameString, [fishingSpot.name, numOfCatches]);
    } else if (numOfCatches == 1) {
      return format(Strings.of(context).mapPageDeleteFishingSpotNoNameSingular,
          [numOfCatches]);
    } else {
      return format(Strings.of(context).mapPageDeleteFishingSpotNoName,
          [numOfCatches]);
    }
  }
}