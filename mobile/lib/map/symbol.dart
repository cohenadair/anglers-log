import 'package:mobile/map/symbol_options.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';

import 'lat_lng.dart';

class Symbol {
  // TODO: Probably don't need to use [data] in this way, since this is no
  //  longer a Mapbox class.
  static const _keyFishingSpot = "fishing_spot";

  static Map<String, dynamic> fishingSpotData(FishingSpot fishingSpot) {
    return {_keyFishingSpot: fishingSpot};
  }

  final Map<String, dynamic>? data;

  SymbolOptions options;

  Symbol({this.options = const SymbolOptions(), this.data});

  bool get hasFishingSpot => fishingSpot != null;

  FishingSpot? get fishingSpot => data?[_keyFishingSpot];

  set fishingSpot(FishingSpot? fishingSpot) =>
      data?[_keyFishingSpot] = fishingSpot;

  LatLng get latLng => options.geometry!;
}
