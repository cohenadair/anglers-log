import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_species_page.dart';
import '../species_manager.dart';
import '../utils/dialog_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/text.dart';

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
    var speciesManager = SpeciesManager.of(context);

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
              onPicked: onPicked,
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
          var numOfCatches = speciesManager.numberOfCatches(species.id);
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
