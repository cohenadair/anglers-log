import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

void moveMap(Completer<GoogleMapController> controller, LatLng latLng,
    [bool animate = true])
{
  controller.future.then((controller) {
    var update = CameraUpdate.newLatLng(latLng);
    if (animate) {
      controller.animateCamera(update);
    } else {
      controller.moveCamera(update);
    }
  });
}