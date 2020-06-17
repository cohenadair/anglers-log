import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/pages/entity_list_page.dart';
import 'package:mobile/pages/save_species_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';

class SpeciesListPage extends StatelessWidget {
  final bool Function(BuildContext, Species) onPicked;

  SpeciesListPage() : onPicked = null;

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
          : Text(format(Strings.of(context).speciesListPageTitle,
              [speciesManager.entityCount])),
      forceCenterTitle: !_picking,
      itemBuilder: (context, species) => ManageableListPageItemModel(
        child: PrimaryLabel(species.name),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).speciesListPageSearchHint,
        noResultsMessage: Strings.of(context).speciesListPageNoSearchResults,
      ),
      pickerSettings: _picking
          ? ManageableListPageSinglePickerSettings<Species>(
              onPicked: onPicked,
            )
          : null,
      itemManager: ManageableListPageItemManager<Species>(
        listenerManagers: [ speciesManager ],
        loadItems: (String query) =>
            speciesManager.entityListSortedByName(filter: query),
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