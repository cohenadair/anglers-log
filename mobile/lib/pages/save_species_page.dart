import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/save_name_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/validator.dart';

class SaveSpeciesPage extends StatelessWidget {
  final Species oldSpecies;

  SaveSpeciesPage() : oldSpecies = null;
  SaveSpeciesPage.edit(this.oldSpecies);

  @override
  Widget build(BuildContext context) {
    SpeciesManager speciesManager = SpeciesManager.of(context);

    return SaveNamePage(
      title: oldSpecies == null
          ? Text(Strings.of(context).saveSpeciesPageNewTitle)
          : Text(Strings.of(context).saveSpeciesPageEditTitle),
      oldName: oldSpecies?.name,
      onSave: (newName) {
        var newSpecies = Species()
          ..id = oldSpecies?.id ?? randomId()
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