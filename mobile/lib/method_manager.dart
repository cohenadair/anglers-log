import 'package:flutter/material.dart';
import 'package:mobile/named_entity_manager.dart';

import 'app_manager.dart';
import 'catch_manager.dart';
import 'model/gen/anglers_log.pb.dart';
import 'utils/string_utils.dart';

class MethodManager extends NamedEntityManager<Method> {
  static MethodManager of(BuildContext context) => AppManager.get.methodManager;

  MethodManager(super.app);

  @override
  Method entityFromBytes(List<int> bytes) => Method.fromBuffer(bytes);

  @override
  Id id(Method entity) => entity.id;

  @override
  String name(Method entity) => entity.name;

  @override
  String get tableName => "method";

  int numberOfCatches(Id? methodId) => numberOf<Catch>(
    methodId,
    CatchManager.get.list(),
    (cat) => cat.methodIds.contains(methodId),
  );

  String deleteMessage(BuildContext context, Method method) {
    var numOfCatches = numberOfCatches(method.id);
    return numOfCatches == 1
        ? Strings.of(context).methodListPageDeleteMessageSingular(method.name)
        : Strings.of(
            context,
          ).methodListPageDeleteMessage(method.name, numOfCatches);
  }
}
