import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/pages/save_name_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/validator.dart';

class SaveSpeciesPage extends StatelessWidget {
  final Id oldSpeciesId;

  SaveSpeciesPage() : oldSpeciesId = null;
  SaveSpeciesPage.edit(this.oldSpeciesId);

  @override
  Widget build(BuildContext context) {
    SpeciesManager speciesManager = SpeciesManager.of(context);
    Species oldSpecies = speciesManager.entity(oldSpeciesId);

    return SaveNamePage(
      title: oldSpecies == null
          ? Text(Strings.of(context).saveSpeciesPageNewTitle)
          : Text(Strings.of(context).saveSpeciesPageEditTitle),
      oldName: oldSpecies?.name,
      onSave: (newName) {
        var newSpecies = Species()
          ..id = oldSpecies?.id ?? Id.random()
          ..name = newName;

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