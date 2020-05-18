import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:provider/provider.dart';

class SpeciesManager extends NamedEntityManager<Species> {
  static SpeciesManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).speciesManager;

  SpeciesManager(AppManager app) : _catchManager = app.catchManager, super(app);

  final CatchManager _catchManager;

  @override
  Species entityFromMap(Map<String, dynamic> map) => Species.fromMap(map);

  @override
  String get tableName => "species";

  @override
  Future<bool> delete(Species species) async {
    // Species is a required field of Catch, so do not allow users to delete
    // species that are attached to any catches.
    if (_catchManager.existsWith(speciesId: species.id)) {
      return false;
    }
    return super.delete(species);
  }

  int numberOfCatches(Species species) {
    if (species == null) {
      return 0;

    }
    int result = 0;
    _catchManager.entityList.forEach((cat) {
      if (cat.speciesId == species.id) {
        result++;
      }
    });

    return result;
  }
}