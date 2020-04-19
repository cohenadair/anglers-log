import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
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
  SpeciesManager._internal(AppManager app) : super(app);

  @override
  Species entityFromMap(Map<String, dynamic> map) => Species.fromMap(map);

  @override
  String get tableName => "species";
}