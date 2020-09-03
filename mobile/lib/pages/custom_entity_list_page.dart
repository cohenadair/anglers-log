import 'package:flutter/material.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/custom_entity_value_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/save_custom_entity_page.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class CustomEntityListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CustomEntityManager entityManager = CustomEntityManager.of(context);
    CustomEntityValueManager entityValueManager =
        CustomEntityValueManager.of(context);

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
        listenerManagers: [ entityManager ],
        loadItems: (String query) =>
            entityManager.entityListSortedByName(filter: query),
        deleteText: (context, entity) =>
            Text(format(Strings.of(context).customEntityListPageDelete, [
              entity.name,
              entityValueManager.catchValueCount(entity.id),
              entityValueManager.baitValueCount(entity.id),
            ])),
        deleteItem: (context, entity) async =>
            await entityManager.delete(entity),
        addPageBuilder: () => SaveCustomEntityPage(),
        editPageBuilder: (entity) => SaveCustomEntityPage.edit(entity),
      ),
    );
  }
}