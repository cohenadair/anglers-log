import 'package:flutter/material.dart';
import 'package:mobile/named_entity_manager.dart';

import 'app_manager.dart';
import 'bait_manager.dart';
import 'model/gen/anglers_log.pb.dart';
import 'utils/string_utils.dart';

class BaitCategoryManager extends NamedEntityManager<BaitCategory> {
  static BaitCategoryManager of(BuildContext context) =>
      AppManager.get.baitCategoryManager;

  BaitManager get _baitManager => appManager.baitManager;

  BaitCategoryManager(super.app);

  @override
  BaitCategory entityFromBytes(List<int> bytes) =>
      BaitCategory.fromBuffer(bytes);

  @override
  Id id(BaitCategory entity) => entity.id;

  @override
  String name(BaitCategory entity) => entity.name;

  @override
  String get tableName => "bait_category";

  int numberOfBaits(Id? baitCategoryId) => numberOf<Bait>(baitCategoryId,
      _baitManager.list(), (bait) => bait.baitCategoryId == baitCategoryId);

  String deleteMessage(BuildContext context, BaitCategory baitCategory) {
    var numOfBaits = numberOfBaits(baitCategory.id);
    return numOfBaits == 1
        ? Strings.of(context)
            .baitCategoryListPageDeleteMessageSingular(baitCategory.name)
        : Strings.of(context)
            .baitCategoryListPageDeleteMessage(baitCategory.name, numOfBaits);
  }
}
