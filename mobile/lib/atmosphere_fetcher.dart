import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'model/gen/anglerslog.pb.dart';

class AtmosphereFetcher {
  final int timestamp;
  final LatLng? latLng;

  AtmosphereFetcher(this.timestamp, this.latLng);

  Future<Atmosphere?> fetch() {
    if (latLng == null) {
      return Future.value(null);
    }

    return Future.delayed(Duration(milliseconds: 2000), () => Atmosphere(
      // TODO
    ));
  }
}