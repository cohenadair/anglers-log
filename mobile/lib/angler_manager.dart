import 'package:flutter/material.dart';
import 'package:mobile/catch_field_entity_manager.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'i18n/strings.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/string_utils.dart';

class AnglerManager extends CatchFieldEntityManager<Angler> {
  static AnglerManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).anglerManager;

  AnglerManager(AppManager app) : super(app);

  @override
  Angler entityFromBytes(List<int> bytes) => Angler.fromBuffer(bytes);

  @override
  Id id(Angler entity) => entity.id;

  @override
  List<Id> idFromCatch(Catch cat) => [cat.anglerId];

  @override
  String name(Angler entity) => entity.name;

  @override
  String get tableName => "angler";

  String deleteMessage(BuildContext context, Angler angler) {
    var numOfCatches = numberOfCatches(angler.id);
    var string = numOfCatches == 1
        ? Strings.of(context).anglerListPageDeleteMessageSingular
        : Strings.of(context).anglerListPageDeleteMessage;
    return format(string, [angler.name, numOfCatches]);
  }
}
