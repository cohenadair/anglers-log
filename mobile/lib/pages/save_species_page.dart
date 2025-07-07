import 'package:flutter/material.dart';

import '../model/gen/anglers_log.pb.dart';
import '../pages/save_name_page.dart';
import '../species_manager.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../utils/validator.dart';

class SaveSpeciesPage extends StatelessWidget {
  final Species? oldSpecies;

  const SaveSpeciesPage() : oldSpecies = null;

  const SaveSpeciesPage.edit(Species this.oldSpecies);

  @override
  Widget build(BuildContext context) {
    var speciesManager = SpeciesManager.of(context);

    return SaveNamePage(
      title: oldSpecies == null
          ? Text(Strings.of(context).saveSpeciesPageNewTitle)
          : Text(Strings.of(context).saveSpeciesPageEditTitle),
      oldName: oldSpecies?.name,
      onSave: (newName) {
        var newSpecies = Species()
          ..id = oldSpecies?.id ?? randomId()
          ..name = newName!;

        speciesManager.addOrUpdate(newSpecies);
        return true;
      },
      validator: NameValidator(
        nameExistsMessage: (context) =>
            Strings.of(context).saveSpeciesPageExistsError,
        nameExists: (name) => speciesManager.nameExists(name),
      ),
    );
  }
}
