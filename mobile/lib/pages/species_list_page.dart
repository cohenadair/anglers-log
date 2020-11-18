import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/save_species_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';

class SpeciesListPage extends StatelessWidget {
  final bool Function(BuildContext, Set<Species>) onPicked;
  final bool multiPicker;
  final Set<Species> initialValues;

  SpeciesListPage()
      : onPicked = null,
        multiPicker = false,
        initialValues = null;

  SpeciesListPage.picker({
    @required this.onPicked,
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
              onPicked: (context, species) => onPicked(context, species),
              multi: multiPicker,
              initialValues: initialValues,
            )
          : null,
      itemManager: ManageableListPageItemManager<Species>(
        listenerManagers: [speciesManager],
        loadItems: (query) => speciesManager.listSortedByName(filter: query),
        deleteWidget: (context, species) => Text(format(
            Strings.of(context).speciesListPageConfirmDelete, [species.name])),
        deleteItem: (context, species) => speciesManager.delete(species.id),
        onTapDeleteButton: (species) {
          int numOfCatches = speciesManager.numberOfCatches(species.id);
          if (numOfCatches <= 0) {
            return false;
          }

          String message;
          if (numOfCatches == 1) {
            message = format(
                Strings.of(context).speciesListPageCatchDeleteErrorSingular,
                [species.name]);
          } else {
            message = format(
                Strings.of(context).speciesListPageCatchDeleteErrorPlural,
                [species.name, numOfCatches]);
          }

          showErrorDialog(
            context: context,
            description: Text(message),
          );

          return true;
        },
        addPageBuilder: () => SaveSpeciesPage(),
        editPageBuilder: (species) => SaveSpeciesPage.edit(species),
      ),
    );
  }
}
