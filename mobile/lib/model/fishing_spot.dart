import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/property.dart';

@immutable
class FishingSpot extends Entity {
  static const keyLat = "lat";
  static const keyLng = "lng";
  static const keyName = "name";

  FishingSpot({
    @required LatLng latLng,
    String name,
    String id,
  }) : assert(latLng != null),
       super([
         SingleProperty<double>(key: keyLat, value: latLng.latitude),
         SingleProperty<double>(key: keyLng, value: latLng.longitude),
         SingleProperty<String>(key: keyName, value: name),
       ], id: id);

  double get lat =>
      (propertyWithName(keyLat) as SingleProperty<double>).value;

  double get lng =>
      (propertyWithName(keyLng) as SingleProperty<double>).value;

  LatLng get latLng => LatLng(lat, lng);

  String get name =>
      (propertyWithName(keyName) as SingleProperty<String>).value;
}