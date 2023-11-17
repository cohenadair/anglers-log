import 'package:flutter/material.dart';
import 'package:mobile/widgets/widget.dart';

import '../angler_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../res/style.dart';
import '../utils/string_utils.dart';
import 'save_angler_page.dart';

class AnglerListPage extends StatelessWidget {
  final ManageableListPagePickerSettings<Angler>? pickerSettings;

  const AnglerListPage({
    this.pickerSettings,
  });

  bool get _isPicking => pickerSettings != null;

  @override
  Widget build(BuildContext context) {
    var anglerManager = AnglerManager.of(context);

    return ManageableListPage<Angler>(
      titleBuilder: (anglers) => Text(
        format(Strings.of(context).anglerListPageTitle, [anglers.length]),
      ),
      forceCenterTitle: !_isPicking,
      itemBuilder: (context, angler) => ManageableListPageItemModel(
        child: Text(angler.name, style: stylePrimary(context)),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).anglerListPageSearchHint,
      ),
      pickerSettings: pickerSettings?.copyWith(
        title: Text(Strings.of(context).pickerTitleAngler),
        multiTitle: Text(Strings.of(context).pickerTitleAnglers),
      ),
      itemManager: ManageableListPageItemManager<Angler>(
        listenerManagers: [anglerManager],
        loadItems: (query) =>
            anglerManager.listSortedByDisplayName(context, filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: iconAngler,
          title: Strings.of(context).anglerListPageEmptyListTitle,
          description: Strings.of(context).anglerListPageEmptyListDescription,
        ),
        deleteWidget: (context, angler) =>
            Text(anglerManager.deleteMessage(context, angler)),
        deleteItem: (context, angler) => anglerManager.delete(angler.id),
        addPageBuilder: () => const SaveAnglerPage(),
        editPageBuilder: (angler) => SaveAnglerPage.edit(angler),
      ),
    );
  }
}
