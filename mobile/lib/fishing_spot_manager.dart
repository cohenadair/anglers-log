import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:provider/provider.dart';

class FishingSpotManager {
  static FishingSpotManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).fishingSpotManager;

  static final FishingSpotManager _instance = FishingSpotManager._internal();
  factory FishingSpotManager.get() => _instance;
  FishingSpotManager._internal();

  final List<FishingSpot> _fishingSpots = List();

  List<FishingSpot> get fishingSpots => [
    FishingSpot(latLng: LatLng(37.429876, -122.291231), name: "Spot 1"),
    FishingSpot(latLng: LatLng(37.329877, -122.191232), name: "Spot 2"),
    FishingSpot(latLng: LatLng(37.229875, -122.091230)),
  ];

  int get numberOfFishingSpots => _fishingSpots.length;

  bool exists(String id) {
    return fishingSpot(id) != null;
  }

  void add(FishingSpot fishingSpot) {
    if (_fishingSpots.contains(fishingSpot)) {
      return;
    }
    _fishingSpots.add(fishingSpot);
  }

  void remove(FishingSpot fishingSpot) {
    _fishingSpots.remove(fishingSpot);
  }

  FishingSpot fishingSpot(String id) {
    return _fishingSpots.firstWhere(
      (FishingSpot fishingSpot) => fishingSpot.id == id,
      orElse: () => null,
    );
  }
}