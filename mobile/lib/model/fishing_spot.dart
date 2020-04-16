import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/named_entity.dart';
import 'package:mobile/model/property.dart';

/// A [FishingSpot] is a single location at which an angler can fish.
@immutable
class FishingSpot extends NamedEntity {
  static const keyLat = "lat";
  static const keyLng = "lng";

  static List<Property> _propertyList(double lat, double lng) => [
    Property<double>(key: keyLat, value: lat),
    Property<double>(key: keyLng, value: lng),
  ];

  FishingSpot({
    @required double lat,
    @required double lng,
    String name,
    String id,
  }) : assert(lat != null),
       assert(lng != null),
       super(
         properties: _propertyList(lat, lng),
         id: id,
         name: name,
       );

  FishingSpot.fromMap(Map<String, dynamic> map) : super.fromMap(map,
      properties: _propertyList(map[keyLat], map[keyLng]));

  double get lat =>
      (propertyWithName(keyLat) as Property<double>).value;

  double get lng =>
      (propertyWithName(keyLng) as Property<double>).value;

  LatLng get latLng => LatLng(lat, lng);
}