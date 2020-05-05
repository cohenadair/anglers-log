import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:provider/provider.dart';

class FishingSpotManager extends NamedEntityManager<FishingSpot> {
  static FishingSpotManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).fishingSpotManager;

  FishingSpotManager(AppManager app) : super(app);

  @override
  FishingSpot entityFromMap(Map<String, dynamic> map) =>
      FishingSpot.fromMap(map);

  @override
  String get tableName => "fishing_spot";

  /// Returns the closest [FishingSpot] within [meters] of [latLng], or null if
  /// one does not exist.
  FishingSpot withinRadius({@required LatLng latLng, int meters = 0}) {
    if (latLng == null) {
      return null;
    }

    Map<FishingSpot, double> eligibleFishingSpotsMap = {};
    for (FishingSpot fishingSpot in entities.values) {
      double distance = distanceBetween(fishingSpot.latLng, latLng);
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

  /// Returns a [FishingSpot] with the given [LatLng], or null if one doesn't
  /// exist.
  FishingSpot withLatLng(LatLng latLng, {double radiusInMeters}) {
    if (latLng == null) {
      return null;
    }
    return entities.values.firstWhere(
      (fishingSpot) => fishingSpot.latLng == latLng,
      orElse: () => null,
    );
  }
}