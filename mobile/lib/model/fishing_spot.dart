import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/property.dart';

@immutable
class FishingSpot extends Entity {
  static const keyLat = "lat";
  static const keyLng = "lng";
  static const keyName = "name";

  static List<Property> _propertyList(double lat, double lng, String name) => [
    SingleProperty<double>(key: keyLat, value: lat),
    SingleProperty<double>(key: keyLng, value: lng),
    SingleProperty<String>(key: keyName, value: name),
  ];

  FishingSpot({
    @required double lat,
    @required double lng,
    String name,
    String id,
  }) : assert(lat != null),
       assert(lng != null),
       super(_propertyList(lat, lng, name), id: id);

  FishingSpot.fromMap(Map<String, dynamic> map) : super.fromMap(
      _propertyList(map[keyLat], map[keyLng], map[keyName]), map);

  double get lat =>
      (propertyWithName(keyLat) as SingleProperty<double>).value;

  double get lng =>
      (propertyWithName(keyLng) as SingleProperty<double>).value;

  LatLng get latLng => LatLng(lat, lng);

  String get name =>
      (propertyWithName(keyName) as SingleProperty<String>).value;
}