import 'package:flutter/cupertino.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/validator.dart';
import 'package:mobile/widgets/text.dart';

class SpeciesPickerPage extends StatefulWidget {
  final void Function(BuildContext, Species) onPicked;

  SpeciesPickerPage({
    this.onPicked,
  }) : assert(onPicked != null);

  @override
  _SpeciesPickerPageState createState() => _SpeciesPickerPageState();
}

class _SpeciesPickerPageState extends State<SpeciesPickerPage> {
  List<Species> _species = [];

  @override
  Widget build(BuildContext context) {
    return SpeciesBuilder(
      onUpdate: (species) {
        _species = species;
      },
      builder: (context) => PickerPage<Species>.single(
        title: Text(Strings.of(context).speciesPickerPageTitle),
        itemBuilder: () => _species.map((species) => PickerPageItem<Species>(
          title: species.name,
          value: species,
        )).toList(),
        onFinishedPicking: widget.onPicked,
        itemManager: PickerPageItemNameManager<Species>(
          addTitle: Text(Strings.of(context).speciesPickerPageNewTitle),
          editTitle: Text(Strings.of(context).speciesPickerPageEditTitle),
          deleteMessageBuilder: (context, species) => InsertedBoldText(
            text: Strings.of(context).speciesPickerPageConfirmDelete,
            args: [species.name],
          ),
          oldNameCallback: (oldSpecies) => oldSpecies.name,
          validator: NameValidator(
            nameExistsMessage:
                Strings.of(context).speciesPickerPageSpeciesExists,
            nameExistsFuture: (name) =>
                SpeciesManager.of(context).nameExists(name),
          ),
          onSave: (newName, oldSpecies) {
            var newSpecies = Species(name: newName);
            if (oldSpecies != null) {
              newSpecies = Species(name: newName, id: oldSpecies.id);
            }

            SpeciesManager.of(context).createOrUpdate(newSpecies);
          },
          onDelete: (speciesToDelete) =>
              SpeciesManager.of(context).delete(speciesToDelete),
        ),
      ),
    );
  }
}