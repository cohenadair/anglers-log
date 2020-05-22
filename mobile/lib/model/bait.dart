import 'package:flutter/material.dart';
import 'package:mobile/model/named_entity.dart';
import 'package:mobile/model/property.dart';
import 'package:quiver/core.dart';
import 'package:quiver/strings.dart';

enum BaitType {
  artificial, live, real
}

/// A "bait" is anything an angler uses to catch a fish. Baits can be
/// artificial, real (something dead or non-alive food, such as dough balls),
/// or live.
@immutable
class Bait extends NamedEntity {
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
    @required String baseId,
    @required String photoId,
    @required String categoryId,
    @required String color,
    @required String model,
    @required String size,
    @required BaitType type,
    @required double minDiveDepth,
    @required double maxDiveDepth,
    @required String description,
  }) => [
    Property<String>(key: keyBaseId, value: baseId, searchable: false),
    Property<String>(key: keyPhotoId, value: photoId, searchable: false),
    Property<String>(key: keyBaitCategoryId, value: categoryId,
        searchable: false),
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
    String categoryId,
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
           baseId: baseId,
           photoId: photoId,
           categoryId: categoryId,
           color: color,
           model: model,
           size: size,
           type: type,
           minDiveDepth: minDiveDepth,
           maxDiveDepth: maxDiveDepth,
           description: description,
         ),
         id: id,
         name: name,
       );

  Bait.fromMap(Map<String, dynamic> map) : super.fromMap(map,
      properties: _propertyList(
        baseId: map[keyBaseId],
        photoId: map[keyPhotoId],
        categoryId: map[keyBaitCategoryId],
        color: map[keyColor],
        model: map[keyModel],
        size: map[keySize],
        type: map[keyType],
        minDiveDepth: map[keyMinDiveDepth],
        maxDiveDepth: map[keyMaxDiveDepth],
        description: map[keyDescription],
      ));

  Bait copyWith({
    String id,
    String name,
    Optional<String> baseId,
    Optional<String> photoId,
    Optional<String> categoryId,
    Optional<String> color,
    Optional<String> model,
    Optional<String> size,
    Optional<BaitType> type,
    Optional<double> minDiveDepth,
    Optional<double> maxDiveDepth,
    Optional<String> description,
  }) => Bait(
    id: id ?? this.id,
    name: name ?? this.name,
    baseId: baseId == null ? this.baseId : baseId.orNull,
    photoId: photoId == null ? this.photoId : photoId.orNull,
    categoryId: categoryId == null ? this.categoryId : categoryId.orNull,
    color: color == null ? this.color : color.orNull,
    model: model == null ? this.model : model.orNull,
    size: size == null ? this.size : size.orNull,
    type: type == null ? this.type : type.orNull,
    minDiveDepth: minDiveDepth == null
        ? this.minDiveDepth : minDiveDepth.orNull,
    maxDiveDepth: maxDiveDepth == null
        ? this.maxDiveDepth : maxDiveDepth.orNull,
    description: description == null ? this.description : description.orNull,
  );

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

  bool get hasCategory => isNotEmpty(categoryId);

  bool isDuplicateOf(Bait bait) {
    if (bait == null) {
      return false;
    }

    // Only consider concrete properties when checking duplication.
    return bait.categoryId == categoryId
        && bait.baseId == baseId
        && bait.name == name
        && bait.color == color
        && bait.model == model
        && bait.type == type
        && bait.minDiveDepth == minDiveDepth
        && bait.maxDiveDepth == maxDiveDepth
        // When checking for duplicates, the IDs must be different, otherwise
        // they'd be considered the same Bait.
        && bait.id != id;
  }
}