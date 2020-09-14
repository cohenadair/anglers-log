import 'package:flutter/material.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/save_custom_entity_page.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class CustomEntityListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BaitManager baitManager = BaitManager.of(context);
    CatchManager catchManager = CatchManager.of(context);
    CustomEntityManager customEntityManager = CustomEntityManager.of(context);

    return ManageableListPage<CustomEntity>(
      titleBuilder: (entities) => Text(format(
          Strings.of(context).customEntityListPageTitle, [entities.length])),
      itemBuilder: (context, entity) => ManageableListPageItemModel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryLabel(entity.name),
            isEmpty(entity.description)
                ? Empty() : SecondaryLabel(entity.description),
          ],
        ),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).customEntityListPageSearchHint,
        noResultsMessage:
            Strings.of(context).customEntityListPageNoSearchResults,
      ),
      itemManager: ManageableListPageItemManager<CustomEntity>(
        listenerManagers: [customEntityManager],
        loadItems: (query) =>
            customEntityManager.listSortedByName(filter: query),
        deleteText: (context, entity) =>
            Text(format(Strings.of(context).customEntityListPageDelete, [
              entity.name,
              catchManager.numberOfCustomEntityValues(Id(entity.id)),
              baitManager.numberOfCustomEntityValues(Id(entity.id)),
            ])),
        deleteItem: (context, entity) async =>
            await customEntityManager.delete(Id(entity.id)),
        addPageBuilder: () => SaveCustomEntityPage(),
        editPageBuilder: (entity) => SaveCustomEntityPage.edit(Id(entity.id)),
      ),
    );
  }
}