import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../method_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../utils/string_utils.dart';
import '../widgets/text.dart';
import 'save_method_page.dart';

class MethodListPage extends StatelessWidget {
  final ManageableListPagePickerSettings<Method>? pickerSettings;

  MethodListPage({
    this.pickerSettings,
  });

  @override
  Widget build(BuildContext context) {
    var methodManager = MethodManager.of(context);

    return ManageableListPage<Method>(
      titleBuilder: (anglers) => Text(
        format(Strings.of(context).methodListPageTitle, [anglers.length]),
      ),
      pickerTitleBuilder: (_) =>
          Text(Strings.of(context).methodListPagePickerTitle),
      itemBuilder: (context, method) => ManageableListPageItemModel(
        child: PrimaryLabel(method.name),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).methodListPageSearchHint,
      ),
      pickerSettings: pickerSettings,
      itemManager: ManageableListPageItemManager<Method>(
        listenerManagers: [methodManager],
        loadItems: (query) => methodManager.listSortedByName(filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: Icons.list,
          title: Strings.of(context).methodListPageEmptyListTitle,
          description: Strings.of(context).methodListPageEmptyListDescription,
        ),
        deleteWidget: (context, method) =>
            Text(methodManager.deleteMessage(context, method)),
        deleteItem: (context, method) => methodManager.delete(method.id),
        addPageBuilder: () => SaveMethodPage(),
        editPageBuilder: (method) => SaveMethodPage.edit(method),
      ),
    );
  }
}
