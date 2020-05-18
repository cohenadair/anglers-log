import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/pages/entity_list_page.dart';
import 'package:mobile/pages/save_species_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/string_utils.dart';

class SpeciesListPage extends StatelessWidget {
  final bool Function(BuildContext, Species) onPicked;

  SpeciesListPage.picker({
    this.onPicked,
  }) : assert(onPicked != null);

  bool get _picking => onPicked != null;

  @override
  Widget build(BuildContext context) {
    SpeciesManager speciesManager = SpeciesManager.of(context);

    return EntityListPage<Species>(
      title: _picking
          ? Text(Strings.of(context).speciesListPagePickerTitle)
          : Text(Strings.of(context).speciesListPageTitle),
      itemBuilder: (context, species) => ManageableListPageItemModel(
        child: Text(species.name),
      ),
      searchSettings: ManageableListPageSearchSettings(
        hint: Strings.of(context).speciesListPageSearchHint,
        onStart: () {
          // TODO
        },
      ),
      pickerSettings: _picking
          ? ManageableListPageSinglePickerSettings<Species>(
              onPicked: onPicked,
            )
          : null,
      itemManager: ManageableListPageItemManager<Species>(
        listenerManagers: [ speciesManager ],
        loadItems: () => speciesManager.entityListSortedByName,
        deleteText: (context, species) => Text(format(Strings.of(context)
            .speciesListPageConfirmDelete, [species.name])),
        deleteItem: (context, species) async {
          if (!await speciesManager.delete(species)) {
            showErrorDialog(
              context: context,
              description: Text(format(Strings.of(context)
                  .speciesListPageCatchDeleteError, [species.name])),
            );
          }
        },
        onTapDeleteButton: (species) {
          int numOfCatches = speciesManager.numberOfCatches(species);
          if (numOfCatches <= 0) {
            return null;
          }

          return () {
            showErrorDialog(
              context: context,
              description: Text(format(
                Strings.of(context).speciesListPageCatchDeleteError,
                [species.name, numOfCatches]),
              ),
            );
          };
        },
        addPageBuilder: () => SaveSpeciesPage(),
        editPageBuilder: (species) => SaveSpeciesPage.edit(species),
      ),
    );
  }
}