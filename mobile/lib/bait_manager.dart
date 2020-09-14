import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

class BaitManager extends NamedEntityManager<Bait> {
  static BaitManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).baitManager;

  BaitCategoryManager get _baitCategoryManager =>
      appManager.baitCategoryManager;
  CatchManager get _catchManager => appManager.catchManager;
  CustomEntityManager get _customEntityManager =>
      appManager.customEntityManager;

  BaitManager(AppManager app) : super(app) {
    app.baitCategoryManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteBaitCategory,
    ));
  }

  @override
  Bait entityFromBytes(List<int> bytes) => Bait.fromBuffer(bytes);

  @override
  Id id(Bait bait) => Id(bait.id);

  @override
  String name(Bait bait) => bait.name;

  @override
  String get tableName => "bait";

  @override
  bool matchesFilter(Id id, String filter) {
    Bait bait = entity(id);
    if (bait == null) {
      return false;
    }

    if (super.matchesFilter(id, filter)
        || (bait.baitCategoryId.isNotEmpty
            && _baitCategoryManager.matchesFilter(Id(bait.baitCategoryId),
                filter))
        || entityValuesMatchesFilter(bait.customEntityValues, filter,
            _customEntityManager))
    {
      return true;
    }

    return false;
  }

  /// Returns true if the given [Bait] is a duplicate of an existing bait. A
  /// duplicate is defined as all equal properties, except [Bait.id].
  bool duplicate(Bait rhs) {
    return list().firstWhere((lhs) => lhs.baitCategoryId == rhs.baitCategoryId
        && equalsTrimmedIgnoreCase(lhs.name, rhs.name)
        && lhs.customEntityValues == rhs.customEntityValues
        // When checking for duplicates, the IDs must be different, otherwise
        // they'd be considered the same Bait.
        && lhs.id != rhs.id, orElse: () => null) != null;
  }

  /// Returns the number of [Catch] objects associated with the given [Bait].
  int numberOfCatches(Bait bait) {
    if (bait == null) {
      return 0;
    }

    int result = 0;
    _catchManager.list().forEach((cat) {
      if (cat.baitId == bait.id) {
        result++;
      }
    });

    return result;
  }

  /// Returns the total number of [CustomEntityValue] objects associated with
  /// [Bait] objects and [customEntityId].
  int numberOfCustomEntityValues(Id customEntityId) {
    return entityValuesCount<Bait>(list(), customEntityId,
        (bait) => bait.customEntityValues);
  }

  String formatNameWithCategory(Bait bait) {
    if (bait == null) {
      return null;
    }

    if (bait.baitCategoryId.isNotEmpty) {
      BaitCategory category =
          _baitCategoryManager.entityFromPbId(bait.baitCategoryId);
      if (category != null) {
        return "${category.name} - ${bait.name}";
      }
    }

    return bait.name;
  }

  String deleteMessage(BuildContext context, Bait bait) {
    int numOfCatches = numberOfCatches(bait);
    String string = numOfCatches == 1
        ? Strings.of(context).baitListPageDeleteMessageSingular
        : Strings.of(context).baitListPageDeleteMessage;

    BaitCategory category =
        _baitCategoryManager.entityFromPbId(bait.baitCategoryId);
    String baitName;
    if (category == null) {
      baitName =  bait.name;
    } else {
      baitName = "${bait.name} (${category.name})";
    }

    return format(string, [baitName, numOfCatches]);
  }

  void _onDeleteBaitCategory(BaitCategory baitCategory) async {
    List<Bait>.from(list()
        .where((bait) => baitCategory.id == bait.baitCategoryId))
        .forEach((bait) {
          entities[Id(bait.id)] = bait.copyWith((b) => b.baitCategoryId = []);
        });

    replaceDatabaseWithCache();
    notifyOnAddOrUpdate();
  }
}