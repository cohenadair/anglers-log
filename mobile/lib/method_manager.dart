import 'package:flutter/material.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'catch_manager.dart';
import 'i18n/strings.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/string_utils.dart';

class MethodManager extends NamedEntityManager<Method> {
  static MethodManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).methodManager;

  CatchManager get _catchManager => appManager.catchManager;

  MethodManager(AppManager app) : super(app);

  @override
  Method entityFromBytes(List<int> bytes) => Method.fromBuffer(bytes);

  @override
  Id id(Method entity) => entity.id;

  @override
  String name(Method entity) => entity.name;

  @override
  String get tableName => "method";

  int numberOfCatches(Id? methodId) => numberOf<Catch>(methodId,
      _catchManager.list(), (cat) => cat.methodIds.contains(methodId));

  String deleteMessage(BuildContext context, Method method) {
    var numOfCatches = numberOfCatches(method.id);
    var string = numOfCatches == 1
        ? Strings.of(context).methodListPageDeleteMessageSingular
        : Strings.of(context).methodListPageDeleteMessage;
    return format(string, [method.name, numOfCatches]);
  }
}
