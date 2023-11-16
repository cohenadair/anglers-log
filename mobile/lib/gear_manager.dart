import 'package:flutter/material.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'model/gen/anglerslog.pb.dart';

class GearManager extends NamedEntityManager<Gear> {
  static GearManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).gearManager;

  GearManager(AppManager app) : super(app);

  @override
  Gear entityFromBytes(List<int> bytes) => Gear.fromBuffer(bytes);

  @override
  Id id(Gear entity) => entity.id;

  @override
  String name(Gear entity) => entity.name;

  @override
  String get tableName => "gear";
}
