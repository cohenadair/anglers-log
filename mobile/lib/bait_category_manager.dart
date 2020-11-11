import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:provider/provider.dart';

class BaitCategoryManager extends NamedEntityManager<BaitCategory> {
  static BaitCategoryManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).baitCategoryManager;

  BaitManager get _baitManager => appManager.baitManager;

  BaitCategoryManager(AppManager app) : super(app);

  @override
  BaitCategory entityFromBytes(List<int> bytes) =>
      BaitCategory.fromBuffer(bytes);

  @override
  Id id(BaitCategory baitCategory) => baitCategory.id;

  @override
  String name(BaitCategory baitCategory) => baitCategory.name;

  @override
  String get tableName => "bait_category";

  int numberOfBaits(Id baitCategoryId) {
    if (baitCategoryId == null) {
      return 0;
    }

    int result = 0;
    _baitManager.list().forEach((bait) =>
        result += baitCategoryId == bait.baitCategoryId ? 1 : 0);

    return result;
  }

  String deleteMessage(BuildContext context, BaitCategory baitCategory) {
    assert(context != null);
    assert(baitCategory != null);

    int numOfBaits = numberOfBaits(baitCategory.id);
    String string = numOfBaits == 1
        ? Strings.of(context).baitCategoryListPageDeleteMessageSingular
        : Strings.of(context).baitCategoryListPageDeleteMessage;
    return format(string, [baitCategory.name, numOfBaits]);
  }
}