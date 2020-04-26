import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

/// An object that stores an entity ID to image name pair.
class EntityImage {
  static const keyEntityId = "entity_id";
  static const keyImageName = "image_name";

  final String entityId;
  final String imageName;

  EntityImage({
    @required this.entityId,
    @required this.imageName,
  }) : assert(isNotEmpty(entityId)),
       assert(isNotEmpty(imageName));

  EntityImage.fromMap(Map<String, dynamic> map) : this(
    entityId: map[keyEntityId],
    imageName: map[keyImageName],
  );

  Map<String, dynamic> toMap() => {
    keyEntityId: entityId,
    keyImageName: imageName,
  };
}