import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:provider/provider.dart';

class BaitCategoryManager extends NamedEntityManager<BaitCategory> {
  static BaitCategoryManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).baitCategoryManager;

  BaitCategoryManager(AppManager app) : super(app);

  BaitManager get _baitManager => appManager.baitManager;

  @override
  BaitCategory entityFromMap(Map<String, dynamic> map) =>
      BaitCategory.fromMap(map);

  @override
  String get tableName => "bait_category";

  int numberOfBaits(BaitCategory baitCategory) {
    if (baitCategory == null) {
      return 0;
    }

    int result = 0;
    _baitManager.entityList().forEach((bait) {
      if (bait.hasCategory && bait.categoryId == baitCategory.id) {
        result++;
      }
    });

    return result;
  }

  String deleteMessage(BuildContext context, BaitCategory baitCategory) {
    if (context == null || baitCategory == null) {
      return null;
    }
    int numOfBaits = numberOfBaits(baitCategory);
    String string = numOfBaits == 1
        ? Strings.of(context).baitCategoryListPageDeleteMessageSingular
        : Strings.of(context).baitCategoryListPageDeleteMessage;
    return format(string, [baitCategory.name, numOfBaits]);
  }
}