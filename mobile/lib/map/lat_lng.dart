import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../utils/string_utils.dart';

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  String get latitudeString => formatCoordinate(latitude);

  String get longitudeString => formatCoordinate(longitude);

  Point toMapboxPoint() => Point(coordinates: Position(longitude, latitude));

  @override
  bool operator ==(Object other) {
    return other is LatLng && other.latitude == latitude && other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}