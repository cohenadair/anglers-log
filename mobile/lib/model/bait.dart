import 'package:flutter/material.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/property.dart';
import 'package:quiver/strings.dart';

enum BaitType {
  artificial, live, real
}

/// A "bait" is anything an angler uses to catch a fish. Baits can be
/// artificial, real (something dead or non-alive food, such as dough balls),
/// or live.
@immutable
class Bait extends Entity {
  static const keyName = "name";
  static const keyBaseId = "base_id";
  static const keyPhotoId = "photo_id";
  static const keyBaitCategoryId = "category_id";
  static const keyColor = "color";
  static const keyModel = "model";
  static const keySize = "size";
  static const keyType = "type";
  static const keyMinDiveDepth = "min_dive_depth";
  static const keyMaxDiveDepth = "max_dive_depth";
  static const keyDescription = "description";

  static List<Property> _propertyList({
    @required String name,
    @required String baseId,
    @required String photoId,
    @required String baitCategoryId,
    @required String color,
    @required String model,
    @required String size,
    @required BaitType type,
    @required double minDiveDepth,
    @required double maxDiveDepth,
    @required String description,
  }) => [
    Property<String>(key: keyName, value: name),
    Property<String>(key: keyBaseId, value: baseId),
    Property<String>(key: keyPhotoId, value: photoId),
    Property<String>(key: keyBaitCategoryId, value: baitCategoryId),
    Property<String>(key: keyColor, value: color),
    Property<String>(key: keyModel, value: model),
    Property<String>(key: keySize, value: size),
    Property<BaitType>(key: keyType, value: type),
    Property<double>(key: keyMinDiveDepth, value: minDiveDepth),
    Property<double>(key: keyMaxDiveDepth, value: maxDiveDepth),
    Property<String>(key: keyDescription, value: description),
  ];

  Bait({
    @required String name,
    String id,
    String baseId,
    String photoId,
    String baitCategoryId,
    String color,
    String model,
    String size,
    BaitType type,
    double minDiveDepth,
    double maxDiveDepth,
    String description,
  }) : assert(isNotEmpty(name)),
       super(
         properties: _propertyList(
           name: name,
           baseId: baseId,
           photoId: photoId,
           baitCategoryId: baitCategoryId,
           color: color,
           model: model,
           size: size,
           type: type,
           minDiveDepth: minDiveDepth,
           maxDiveDepth: maxDiveDepth,
           description: description,
         ),
         id: id,
       );

  Bait.fromMap(Map<String, dynamic> map) : super.fromMap(map,
      properties: _propertyList(
        name: map[keyName],
        baseId: map[keyBaseId],
        photoId: map[keyPhotoId],
        baitCategoryId: map[keyBaitCategoryId],
        color: map[keyColor],
        model: map[keyModel],
        size: map[keySize],
        type: map[keyType],
        minDiveDepth: map[keyMinDiveDepth],
        maxDiveDepth: map[keyMaxDiveDepth],
        description: map[keyDescription],
      ));

  String get name => (propertyWithName(keyName) as Property<String>)?.value;

  String get baseId =>
      (propertyWithName(keyBaseId) as Property<String>).value;

  String get photoId =>
      (propertyWithName(keyPhotoId) as Property<String>).value;

  String get categoryId =>
      (propertyWithName(keyBaitCategoryId) as Property<String>).value;

  String get color =>
      (propertyWithName(keyColor) as Property<String>).value;

  String get model =>
      (propertyWithName(keyModel) as Property<String>).value;

  String get size =>
      (propertyWithName(keySize) as Property<String>).value;

  BaitType get type =>
      (propertyWithName(keyType) as Property<BaitType>).value;

  double get minDiveDepth =>
      (propertyWithName(keyMinDiveDepth) as Property<double>).value;

  double get maxDiveDepth =>
      (propertyWithName(keyMaxDiveDepth) as Property<double>).value;

  String get description =>
      (propertyWithName(keyDescription) as Property<String>).value;
}