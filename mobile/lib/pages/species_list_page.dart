import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/save_species_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';

class SpeciesListPage extends StatelessWidget {
  final bool Function(BuildContext, Set<Id>) onPicked;
  final bool multiPicker;
  final Set<Id> initialValues;

  SpeciesListPage()
      : onPicked = null,
        multiPicker = false,
        initialValues = null;

  SpeciesListPage.picker({
    this.onPicked,
    this.multiPicker = false,
    this.initialValues,
  }) : assert(onPicked != null);

  bool get _picking => onPicked != null;

  @override
  Widget build(BuildContext context) {
    SpeciesManager speciesManager = SpeciesManager.of(context);

    return ManageableListPage<Species>(
      titleBuilder: _picking
          ? (_) => Text(Strings.of(context).speciesListPagePickerTitle)
          : (species) => Text(format(Strings.of(context).speciesListPageTitle,
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
          ? ManageableListPagePickerSettings<Species>(
              onPicked: (context, species) => onPicked(context,
                  speciesManager.listToIdList(species.toList())),
              multi: multiPicker,
              initialValues: speciesManager.idListToList(initialValues),
            )
          : null,
      itemManager: ManageableListPageItemManager<Species>(
        listenerManagers: [ speciesManager ],
        loadItems: (query) => speciesManager.listSortedByName(filter: query),
        deleteText: (context, species) => Text(format(Strings.of(context)
            .speciesListPageConfirmDelete, [species.name])),
        deleteItem: (context, species) => speciesManager.delete(Id(species.id)),
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