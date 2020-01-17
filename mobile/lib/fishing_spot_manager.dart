import 'package:flutter/cupertino.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:provider/provider.dart';

class FishingSpotManager {
  static FishingSpotManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).fishingSpotManager;

  static final FishingSpotManager _instance = FishingSpotManager._internal();
  factory FishingSpotManager.get() => _instance;
  FishingSpotManager._internal();

  final List<FishingSpot> _fishingSpots = [
    FishingSpot(lat: 37.429876, lng: -122.291231, name: "Spot 1"),
    FishingSpot(lat: 37.329877, lng: -122.191232, name: "Spot 2"),
    FishingSpot(lat: 37.229875, lng: -122.091230),
  ];

  List<FishingSpot> get fishingSpots => List.of(_fishingSpots);

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