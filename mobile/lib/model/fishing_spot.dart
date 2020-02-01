import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/property.dart';

/// A [FishingSpot] is a single location at which an angler can fish.
@immutable
class FishingSpot extends Entity {
  static const keyLat = "lat";
  static const keyLng = "lng";
  static const keyName = "name";

  static List<Property> _propertyList(double lat, double lng, String name) => [
    Property<double>(key: keyLat, value: lat),
    Property<double>(key: keyLng, value: lng),
    Property<String>(key: keyName, value: name),
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
      (propertyWithName(keyLat) as Property<double>).value;

  double get lng =>
      (propertyWithName(keyLng) as Property<double>).value;

  LatLng get latLng => LatLng(lat, lng);

  String get name =>
      (propertyWithName(keyName) as Property<String>).value;
}