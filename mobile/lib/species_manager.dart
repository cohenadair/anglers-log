import 'package:flutter/material.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'catch_manager.dart';
import 'model/gen/anglerslog.pb.dart';

class SpeciesManager extends NamedEntityManager<Species> {
  static SpeciesManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).speciesManager;

  CatchManager get _catchManager => appManager.catchManager;

  SpeciesManager(AppManager app) : super(app);

  @override
  Species entityFromBytes(List<int> bytes) => Species.fromBuffer(bytes);

  @override
  Id id(Species entity) => entity.id;

  @override
  String name(Species entity) => entity.name;

  @override
  String get tableName => "species";

  @override
  Future<bool> delete(
    Id entityId, {
    bool notify = true,
  }) async {
    // Species is a required field of Catch, so do not allow users to delete
    // species that are attached to any catches.
    if (_catchManager.existsWith(speciesId: entityId)) {
      return false;
    }
    return super.delete(entityId, notify: notify);
  }

  int numberOfCatches(Id? speciesId) => numberOf<Catch>(
      speciesId, _catchManager.list(), (cat) => cat.speciesId == speciesId);
}
