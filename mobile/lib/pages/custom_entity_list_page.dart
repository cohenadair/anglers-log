import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../bait_manager.dart';
import '../catch_manager.dart';
import '../custom_entity_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_custom_entity_page.dart';
import '../utils/string_utils.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';

class CustomEntityListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var baitManager = BaitManager.of(context);
    var catchManager = CatchManager.of(context);
    var customEntityManager = CustomEntityManager.of(context);

    return ManageableListPage<CustomEntity>(
      titleBuilder: (entities) => Text(format(
          Strings.of(context).customEntityListPageTitle, [entities.length])),
      itemBuilder: (context, entity) => ManageableListPageItemModel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryLabel(entity.name),
            isEmpty(entity.description)
                ? Empty()
                : SubtitleLabel(entity.description),
          ],
        ),
      ),
      searchDelegate: ListPageSearchDelegate(
        hint: Strings.of(context).customEntityListPageSearchHint,
        noResultsMessage:
            Strings.of(context).customEntityListPageNoSearchResults,
      ),
      itemManager: ManageableListPageItemManager<CustomEntity>(
        listenerManagers: [customEntityManager],
        loadItems: (query) =>
            customEntityManager.listSortedByName(filter: query),
        deleteWidget: (context, entity) => Text(
          format(
            Strings.of(context).customEntityListPageDelete,
            [
              entity.name,
              catchManager.numberOfCustomEntityValues(entity.id),
              baitManager.numberOfCustomEntityValues(entity.id),
            ],
          ),
        ),
        deleteItem: (context, entity) async =>
            await customEntityManager.delete(entity.id),
        addPageBuilder: () => SaveCustomEntityPage(),
        editPageBuilder: (entity) => SaveCustomEntityPage.edit(entity),
      ),
    );
  }
}
