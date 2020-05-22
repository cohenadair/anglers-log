import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:mobile/utils/string_utils.dart';
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

  BaitCategoryManager get _baitCategoryManager =>
      appManager.baitCategoryManager;
  CatchManager get _catchManager => appManager.catchManager;

  @override
  Bait entityFromMap(Map<String, dynamic> map) => Bait.fromMap(map);

  @override
  String get tableName => "bait";

  /// Returns true if the given [Bait] is a duplicate of an existing bait.
  /// [Bait.isDuplicateOf] is called on each existing bait.
  bool duplicate(Bait lhs) {
    return entityList.firstWhere((rhs) => lhs.isDuplicateOf(lhs),
        orElse: () => null) != null;
  }

  bool matchesFilter(String baitId, String filter) {
    Bait bait = entity(id: baitId);
    if (bait != null && (bait.matchesFilter(filter)
        || (bait.hasCategory && _baitCategoryManager
            .entity(id: bait.categoryId).matchesFilter(filter))))
    {
      return true;
    }
    return false;
  }

  /// Returns the number of [Catch] objects associated with the given [Bait].
  int numberOfCatches(Bait bait) {
    if (bait == null) {
      return 0;
    }

    int result = 0;
    _catchManager.entityList.forEach((cat) {
      if (cat.baitId == bait.id) {
        result++;
      }
    });

    return result;
  }

  String formatNameWithCategory(Bait bait) {
    if (bait == null) {
      return null;
    }

    BaitCategory category = _baitCategoryManager.entity(id: bait.categoryId);
    if (category == null) {
      return bait.name;
    } else {
      return "${category.name} - ${bait.name}";
    }
  }

  String deleteMessage(BuildContext context, Bait bait) {
    int numOfCatches = numberOfCatches(bait);
    String string = numOfCatches == 1
        ? Strings.of(context).baitPageDeleteMessageSingular
        : Strings.of(context).baitPageDeleteMessage;

    BaitCategory category = _baitCategoryManager.entity(id: bait.categoryId);
    String baitName;
    if (category == null) {
      baitName =  bait.name;
    } else {
      baitName = "${category.name} (${bait.name})";
    }

    return format(string, [baitName, numOfCatches]);
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