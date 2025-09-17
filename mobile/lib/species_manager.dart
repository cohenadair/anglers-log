import 'package:flutter/material.dart';
import 'package:mobile/named_entity_manager.dart';

import 'app_manager.dart';
import 'catch_manager.dart';
import 'model/gen/anglers_log.pb.dart';

class SpeciesManager extends NamedEntityManager<Species> {
  static SpeciesManager of(BuildContext context) =>
      AppManager.get.speciesManager;

  SpeciesManager(super.app);

  @override
  Species entityFromBytes(List<int> bytes) => Species.fromBuffer(bytes);

  @override
  Id id(Species entity) => entity.id;

  @override
  String name(Species entity) => entity.name;

  @override
  String get tableName => "species";

  @override
  Future<bool> delete(Id entityId, {bool notify = true}) async {
    // Species is a required field of Catch, so do not allow users to delete
    // species that are attached to any catches.
    if (CatchManager.get.existsWith(speciesId: entityId)) {
      return false;
    }
    return super.delete(entityId, notify: notify);
  }

  int numberOfCatches(Id? speciesId) => numberOf<Catch>(
    speciesId,
    CatchManager.get.list(),
    (cat) => cat.speciesId == speciesId,
  );
}
