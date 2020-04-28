import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:provider/provider.dart';

class SpeciesManager extends NamedEntityManager<Species> {
  static SpeciesManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).speciesManager;

  static SpeciesManager _instance;
  factory SpeciesManager.get(AppManager app) {
    if (_instance == null) {
      _instance = SpeciesManager._internal(app);
    }
    return _instance;
  }
  SpeciesManager._internal(AppManager app)
      : _catchManager = app.catchManager,
        super(app);

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
}