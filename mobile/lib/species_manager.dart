import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/utils/future_stream_builder.dart';
import 'package:mobile/utils/void_stream_controller.dart';
import 'package:provider/provider.dart';

class SpeciesManager {
  static SpeciesManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).speciesManager;

  static SpeciesManager _instance;
  factory SpeciesManager.get(AppManager app) {
    if (_instance == null) {
      _instance = SpeciesManager._internal(app);
    }
    return _instance;
  }
  SpeciesManager._internal(AppManager app) : _app = app;

  final String _tableName = "species";

  final AppManager _app;
  final VoidStreamController onUpdate = VoidStreamController();

  Future<bool> nameExists(String name) {
    return _app.dataManager.exists(_tableName, "name", name);
  }

  void createOrUpdate(Species species) async {
    _app.dataManager.insertOrUpdateEntity(species, _tableName,
        controller: onUpdate);
  }

  void delete(Species species) async {
    _app.dataManager.deleteEntity(species, _tableName,
        controller: onUpdate);
  }

  Future<List<Species>> _fetchAll() async {
    var results = await _app.dataManager.fetchAllEntities(_tableName);
    return results.map((map) => Species.fromMap(map)).toList();
  }

  Future<Species> fetchCategory(String id) async {
    var result = await _app.dataManager.fetchEntity(_tableName, id);
    return Species.fromMap(result);
  }
}

/// A [FutureStreamHolder] subclass for [Species] objects meant to be used
/// with a [PickerPage].
class SpeciesPickerFutureStreamHolder extends FutureStreamHolder {
  SpeciesPickerFutureStreamHolder(BuildContext context, {
    Species Function() currentValue,
    void Function(List<Species>, Species) onUpdate,
  }) : super.entityPicker(
    futureCallback: SpeciesManager.of(context)._fetchAll,
    stream: SpeciesManager.of(context).onUpdate.stream,
    currentValue: currentValue,
    onUpdate: (species, updatedSpecies) =>
        onUpdate(species as List<Species>, updatedSpecies as Species),
  );
}

/// A [FutureStreamBuilder] wrapper for listening for [Species] updates.
class SpeciesBuilder extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  final void Function(List<Species>) onUpdate;

  SpeciesBuilder({
    @required this.builder,
    @required this.onUpdate,
  }) : assert(builder != null);

  @override
  Widget build(BuildContext context) {
    return FutureStreamBuilder(
      holder: FutureStreamHolder.single(
        futureCallback: SpeciesManager.of(context)._fetchAll,
        stream: SpeciesManager.of(context).onUpdate.stream,
        onUpdate: (result) => onUpdate(result as List<Species>),
      ),
      builder: (context) => builder(context),
    );
  }
}