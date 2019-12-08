import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/property.dart';

@immutable
class FishingSpot extends Entity {
  static const _keyLat = "lat";
  static const _keyLng = "lng";
  static const _keyName = "name";

  FishingSpot({
    @required LatLng latLng,
    String name,
  }) : assert(latLng != null),
       super([
         SingleProperty<double>(key: _keyLat, value: latLng.latitude),
         SingleProperty<double>(key: _keyLng, value: latLng.longitude),
         SingleProperty<String>(key: _keyName, value: name),
       ]);

  double get lat =>
      (propertyWithName(_keyLat) as SingleProperty<double>).value;

  double get lng =>
      (propertyWithName(_keyLng) as SingleProperty<double>).value;

  String get name =>
      (propertyWithName(_keyName) as SingleProperty<String>).value;
}