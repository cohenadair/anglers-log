import 'package:flutter/material.dart';
import 'package:mobile/widgets/widget.dart';

import '../i18n/strings.dart';
import '../method_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../res/style.dart';
import '../utils/string_utils.dart';
import 'save_method_page.dart';

class MethodListPage extends StatelessWidget {
  final ManageableListPagePickerSettings<Method>? pickerSettings;

  const MethodListPage({
    this.pickerSettings,
  });

  bool get _isPicking => pickerSettings != null;

  @override
  Widget build(BuildContext context) {
    var methodManager = MethodManager.of(context);

    return ManageableListPage<Method>(
      titleBuilder: (methods) => Text(
        format(Strings.of(context).methodListPageTitle, [methods.length]),
      ),
      forceCenterTitle: !_isPicking,
      itemBuilder: (context, method) => ManageableListPageItemModel(
        child: Text(method.name, style: stylePrimary(context)),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).methodListPageSearchHint,
      ),
      pickerSettings: pickerSettings?.copyWith(
        multiTitle: Text(Strings.of(context).pickerTitleFishingMethods),
      ),
      itemManager: ManageableListPageItemManager<Method>(
        listenerManagers: [methodManager],
        loadItems: (query) =>
            methodManager.listSortedByDisplayName(context, filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: iconMethod,
          title: Strings.of(context).methodListPageEmptyListTitle,
          description: Strings.of(context).methodListPageEmptyListDescription,
        ),
        deleteWidget: (context, method) =>
            Text(methodManager.deleteMessage(context, method)),
        deleteItem: (context, method) => methodManager.delete(method.id),
        addPageBuilder: () => const SaveMethodPage(),
        editPageBuilder: (method) => SaveMethodPage.edit(method),
      ),
    );
  }
}
