import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:provider/provider.dart';
import 'package:quiver/core.dart';

class BaitManager extends NamedEntityManager<Bait> {
  static BaitManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).baitManager;

  BaitManager(AppManager app) : super(app) {
    app.baitCategoryManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteBaitCategory,
    ));
  }

  @override
  Bait entityFromMap(Map<String, dynamic> map) => Bait.fromMap(map);

  @override
  String get tableName => "bait";

  /// Returns true if the given [Bait] is a duplicate of an existing bait.
  /// [Bait.isDuplicateOf] is called on each existing bait.
  bool isDuplicate(Bait lhs) {
    return entityList.firstWhere((rhs) => lhs.isDuplicateOf(lhs),
        orElse: () => null) != null;
  }

  void _onDeleteBaitCategory(BaitCategory baitCategory) async {
    // First, update database. If there are no affected baits, exit early.
    if (!await dataManager.rawUpdate(
        "UPDATE bait SET category_id = null WHERE category_id = ?",
        [baitCategory.id]))
    {
      return;
    }

    // Then, update memory cache.
    List<Bait>.from(entityList
        .where((bait) => baitCategory.id == bait.categoryId))
        .forEach((bait) {
          entities[bait.id] = bait.copyWith(categoryId: Optional.absent());
        });

    notifyOnAddOrUpdate();
  }
}