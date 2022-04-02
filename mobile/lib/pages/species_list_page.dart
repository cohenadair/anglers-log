import 'package:flutter/material.dart';
import 'package:mobile/widgets/widget.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_species_page.dart';
import '../res/style.dart';
import '../species_manager.dart';
import '../utils/dialog_utils.dart';
import '../utils/string_utils.dart';

class SpeciesListPage extends StatelessWidget {
  final ManageableListPagePickerSettings<Species>? pickerSettings;

  /// See [ManageableListPage.appBarLeading].
  final Widget? appBarLeading;

  const SpeciesListPage({
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
      appBarLeading: appBarLeading,
      forceCenterTitle: pickerSettings == null,
      itemBuilder: (context, species) => ManageableListPageItemModel(
        child: Text(species.name, style: stylePrimary(context)),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).speciesListPageSearchHint,
      ),
      pickerSettings: pickerSettings?.copyWith(
        title: Text(Strings.of(context).pickerTitleSpecies),
        multiTitle: Text(Strings.of(context).pickerTitleSpecies),
      ),
      itemManager: ManageableListPageItemManager<Species>(
        listenerManagers: [speciesManager],
        loadItems: (query) =>
            speciesManager.listSortedByDisplayName(context, filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: iconSpecies,
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
        addPageBuilder: () => const SaveSpeciesPage(),
        editPageBuilder: (species) => SaveSpeciesPage.edit(species),
      ),
    );
  }
}
