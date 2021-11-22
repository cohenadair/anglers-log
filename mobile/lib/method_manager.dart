import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'catch_field_entity_manager.dart';
import 'i18n/strings.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/string_utils.dart';

class MethodManager extends CatchFieldEntityManager<Method> {
  static MethodManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).methodManager;

  MethodManager(AppManager app) : super(app);

  @override
  Method entityFromBytes(List<int> bytes) => Method.fromBuffer(bytes);

  @override
  Id id(Method entity) => entity.id;

  @override
  List<Id> idFromCatch(Catch cat) => cat.methodIds;

  @override
  String name(Method entity) => entity.name;

  @override
  String get tableName => "method";

  String deleteMessage(BuildContext context, Method method) {
    var numOfCatches = numberOfCatches(method.id);
    var string = numOfCatches == 1
        ? Strings.of(context).methodListPageDeleteMessageSingular
        : Strings.of(context).methodListPageDeleteMessage;
    return format(string, [method.name, numOfCatches]);
  }
}
