import 'package:flutter/material.dart';
import 'package:mobile/model/one-to-many-row.dart';

/// An object that stores an entity ID to image name pair.
@immutable
class EntityImage extends OneToManyRow {
  static const keyEntityId = "entity_id";
  static const keyImageName = "image_name";

  EntityImage({
    @required String entityId,
    @required String imageName,
  }) : super(
    firstColumn: keyEntityId,
    secondColumn: keyImageName,
    firstValue: entityId,
    secondValue: imageName,
  );

  EntityImage.fromMap(Map<String, dynamic> map) : super.fromMap(
    firstColumn: keyEntityId,
    secondColumn: keyImageName,
    map: map,
  );

  String get entityId => firstValue;
  String get imageName => secondValue;
}