import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../bait_manager.dart';
import '../catch_manager.dart';
import '../custom_entity_manager.dart';
import '../model/gen/anglers_log.pb.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_custom_entity_page.dart';
import '../res/style.dart';
import '../utils/string_utils.dart';
import '../widgets/widget.dart';
import 'anglers_log_pro_page.dart';

class CustomEntityListPage extends StatelessWidget {
  const CustomEntityListPage();

  @override
  Widget build(BuildContext context) {
    var baitManager = BaitManager.of(context);
    var catchManager = CatchManager.of(context);
    var customEntityManager = CustomEntityManager.of(context);

    return ManageableListPage<CustomEntity>(
      titleBuilder: (entities) =>
          Text(Strings.of(context).customEntityListPageTitle(entities.length)),
      forceCenterTitle: true,
      itemBuilder: (context, entity) => ManageableListPageItemModel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entity.name, style: stylePrimary(context)),
            isEmpty(entity.description)
                ? const Empty()
                : Text(entity.description, style: styleSubtitle(context)),
          ],
        ),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).customEntityListPageSearchHint,
      ),
      itemManager: ManageableListPageItemManager<CustomEntity>(
        listenerManagers: [customEntityManager],
        loadItems: (query) =>
            customEntityManager.listSortedByDisplayName(context, filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: Icons.build,
          title: Strings.of(context).customEntityListPageEmptyListTitle,
          description:
              Strings.of(context).customEntityListPageEmptyListDescription,
        ),
        deleteWidget: (context, entity) => Text(
          Strings.of(context).customEntityListPageDelete(
            entity.name,
            catchManager.numberOfCustomEntityValues(entity.id),
            baitManager.numberOfCustomEntityValues(entity.id),
          ),
        ),
        deleteItem: (context, entity) async =>
            await customEntityManager.delete(entity.id),
        addPageBuilder: () => SubscriptionManager.get.isPro
            ? const SaveCustomEntityPage()
            : const AnglersLogProPage(),
        editPageBuilder: (entity) => SaveCustomEntityPage.edit(entity),
      ),
    );
  }
}
