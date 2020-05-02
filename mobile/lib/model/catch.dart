import 'package:flutter/material.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/property.dart';
import 'package:quiver/core.dart';
import 'package:quiver/strings.dart';

/// A [Catch] is a record of fish caught by an anglers. A [Catch] can be a
/// single catch, or multiple catches, but one catch can only be associated
/// with a single species.
@immutable
class Catch extends Entity {
  static const keyTimestamp = "timestamp";
  static const keyBaitId = "bait_id";
  static const keyFishingSpotId = "fishing_spot_id";
  static const keySpeciesId = "species_id";

  static List<Property> _propertyList({
    @required int timestamp,
    @required String baitId,
    @required String fishingSpotId,
    @required String speciesId,
  }) => [
    Property<int>(key: keyTimestamp, value: timestamp),
    Property<String>(key: keyBaitId, value: baitId),
    Property<String>(key: keyFishingSpotId, value: fishingSpotId),
    Property<String>(key: keySpeciesId, value: speciesId),
  ];

  Catch({
    String id,
    @required int timestamp,
    @required String speciesId,
    String baitId,
    String fishingSpotId,
  }) : assert(timestamp != null),
       assert(speciesId != null),
       super(
         properties: _propertyList(
           timestamp: timestamp,
           baitId: baitId,
           fishingSpotId: fishingSpotId,
           speciesId: speciesId,
         ),
         id: id,
       );

  Catch.fromMap(Map<String, dynamic> map) : super.fromMap(map,
      properties: _propertyList(
        timestamp: map[keyTimestamp],
        baitId: map[keyBaitId],
        fishingSpotId: map[keyFishingSpotId],
        speciesId: map[keySpeciesId],
      ));

  Catch copyWith({
    String id,
    int timestamp,
    String speciesId,
    Optional<String> baitId,
    Optional<String> fishingSpotId,
  }) => Catch(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    speciesId: speciesId ?? this.speciesId,
    baitId: baitId == null ? this.baitId : baitId.orNull,
    fishingSpotId: fishingSpotId == null
        ? this.fishingSpotId : fishingSpotId.orNull,
  );

  int get timestamp =>
      (propertyWithName(keyTimestamp) as Property<int>).value;

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  String get baitId =>
      (propertyWithName(keyBaitId) as Property<String>).value;

  String get fishingSpotId =>
      (propertyWithName(keyFishingSpotId) as Property<String>).value;

  String get speciesId =>
      (propertyWithName(keySpeciesId) as Property<String>).value;

  bool get hasBait => isNotEmpty(baitId);
  bool get hasFishingSpot => isNotEmpty(fishingSpotId);
}