import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'catch_field_entity_manager.dart';
import 'i18n/strings.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/string_utils.dart';

class WaterClarityManager extends CatchFieldEntityManager<WaterClarity> {
  static WaterClarityManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).waterClarityManager;

  WaterClarityManager(AppManager app) : super(app);

  @override
  WaterClarity entityFromBytes(List<int> bytes) =>
      WaterClarity.fromBuffer(bytes);

  @override
  Id id(WaterClarity entity) => entity.id;

  @override
  List<Id> idFromCatch(Catch cat) => [cat.waterClarityId];

  @override
  String name(WaterClarity entity) => entity.name;

  @override
  String get tableName => "water_clarity";

  String deleteMessage(BuildContext context, WaterClarity clarity) {
    var numOfCatches = numberOfCatches(clarity.id);
    var string = numOfCatches == 1
        ? Strings.of(context).waterClarityListPageDeleteMessageSingular
        : Strings.of(context).waterClarityListPageDeleteMessage;
    return format(string, [clarity.name, numOfCatches]);
  }
}
