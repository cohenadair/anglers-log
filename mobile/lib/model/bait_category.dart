import 'package:flutter/material.dart';
import 'package:mobile/model/entity.dart';
import 'package:quiver/strings.dart';

/// A "bait category" is a tool meant to easily organize a user's baits.
/// Categories can be very generic like "Lure" and "Fly", or be specific like
/// "Woolly Bugger", "Rapala", "Stone Fly", etc.
@immutable
class BaitCategory extends Entity {
  BaitCategory({
    @required String name,
    String id,
  }) : assert(isNotEmpty(name)),
       super(id: id, name: name);
}