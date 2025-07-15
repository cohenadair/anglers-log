import 'package:flutter/material.dart';
import 'package:mobile/named_entity_manager.dart';

import 'app_manager.dart';
import 'catch_manager.dart';
import 'model/gen/anglers_log.pb.dart';
import 'utils/string_utils.dart';

class WaterClarityManager extends NamedEntityManager<WaterClarity> {
  static WaterClarityManager of(BuildContext context) =>
      AppManager.get.waterClarityManager;

  CatchManager get _catchManager => appManager.catchManager;

  WaterClarityManager(super.app);

  @override
  WaterClarity entityFromBytes(List<int> bytes) =>
      WaterClarity.fromBuffer(bytes);

  @override
  Id id(WaterClarity entity) => entity.id;

  @override
  String name(WaterClarity entity) => entity.name;

  @override
  String get tableName => "water_clarity";

  int numberOfCatches(Id? clarityId) => numberOf<Catch>(
    clarityId,
    _catchManager.list(),
    (cat) => cat.waterClarityId == clarityId,
  );

  String deleteMessage(BuildContext context, WaterClarity clarity) {
    var numOfCatches = numberOfCatches(clarity.id);
    return numOfCatches == 1
        ? Strings.of(
            context,
          ).waterClarityListPageDeleteMessageSingular(clarity.name)
        : Strings.of(
            context,
          ).waterClarityListPageDeleteMessage(clarity.name, numOfCatches);
  }
}
