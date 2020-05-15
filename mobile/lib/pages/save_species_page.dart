import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/pages/save_name_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/validator.dart';

class SaveSpeciesPage extends StatelessWidget {
  final Species oldSpecies;

  SaveSpeciesPage() : oldSpecies = null;
  SaveSpeciesPage.edit(this.oldSpecies);

  bool get _editing => oldSpecies != null;

  @override
  Widget build(BuildContext context) {
    SpeciesManager speciesManager = SpeciesManager.of(context);

    return SaveNamePage(
      title: _editing
          ? Text(Strings.of(context).saveSpeciesPageEditTitle)
          : Text(Strings.of(context).saveSpeciesPageNewTitle),
      oldName: oldSpecies?.name,
      onSave: (newName) {
        var newSpecies = Species(name: newName);
        if (_editing) {
          newSpecies = Species(name: newName, id: oldSpecies.id);
        }

        speciesManager.addOrUpdate(newSpecies);
        return true;
      },
      validator: NameValidator(
        nameExistsMessage: Strings.of(context).saveSpeciesPageExistsError,
        nameExists: (name) => speciesManager.nameExists(name),
      ),
    );
  }
}