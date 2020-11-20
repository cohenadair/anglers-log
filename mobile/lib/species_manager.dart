import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'catch_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';

class SpeciesManager extends NamedEntityManager<Species> {
  static SpeciesManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).speciesManager;

  CatchManager get _catchManager => appManager.catchManager;

  SpeciesManager(AppManager app) : super(app);

  @override
  Species entityFromBytes(List<int> bytes) => Species.fromBuffer(bytes);

  @override
  Id id(Species species) => species.id;

  @override
  String name(Species species) => species.name;

  @override
  String get tableName => "species";

  @override
  Future<bool> delete(Id id) async {
    // Species is a required field of Catch, so do not allow users to delete
    // species that are attached to any catches.
    if (_catchManager.existsWith(speciesId: id)) {
      return false;
    }
    return super.delete(id);
  }

  int numberOfCatches(Id speciesId) {
    if (speciesId == null) {
      return 0;
    }
    var result = 0;
    _catchManager.list().forEach((cat) {
      if (speciesId == cat.speciesId) {
        result++;
      }
    });

    return result;
  }
}
