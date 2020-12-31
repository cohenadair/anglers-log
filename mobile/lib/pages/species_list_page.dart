import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_species_page.dart';
import '../res/gen/custom_icons.dart';
import '../species_manager.dart';
import '../utils/dialog_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/text.dart';

class SpeciesListPage extends StatelessWidget {
  final ManageableListPagePickerSettings<Species> pickerSettings;

  /// See [ManageableListPage.appBarLeading].
  final Widget appBarLeading;

  SpeciesListPage({
    this.pickerSettings,
    this.appBarLeading,
  });

  @override
  Widget build(BuildContext context) {
    var speciesManager = SpeciesManager.of(context);

    return ManageableListPage<Species>(
      titleBuilder: (species) => Text(
        format(Strings.of(context).speciesListPageTitle,
            [speciesManager.entityCount]),
      ),
      pickerTitleBuilder: (_) =>
          Text(Strings.of(context).speciesListPagePickerTitle),
      appBarLeading: appBarLeading,
      forceCenterTitle: pickerSettings == null,
      itemBuilder: (context, species) => ManageableListPageItemModel(
        child: PrimaryLabel(species.name),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).speciesListPageSearchHint,
      ),
      pickerSettings: pickerSettings,
      itemManager: ManageableListPageItemManager<Species>(
        listenerManagers: [speciesManager],
        loadItems: (query) => speciesManager.listSortedByName(filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: CustomIcons.species,
          title: Strings.of(context).speciesListPageEmptyListTitle,
          description: Strings.of(context).speciesListPageEmptyListDescription,
        ),
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
