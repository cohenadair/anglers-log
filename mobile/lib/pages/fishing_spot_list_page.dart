import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_fishing_spot_page.dart';
import '../utils/string_utils.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';

class FishingSpotListPage extends StatelessWidget {
  final ManageableListPagePickerSettings<FishingSpot> pickerSettings;

  FishingSpotListPage({
    this.pickerSettings,
  });

  @override
  Widget build(BuildContext context) {
    var fishingSpotManager = FishingSpotManager.of(context);

    return ManageableListPage<FishingSpot>(
      titleBuilder: (fishingSpots) => Text(
        format(
          Strings.of(context).fishingSpotListPageTitle,
          [fishingSpots.length],
        ),
      ),
      pickerTitleBuilder: (fishingSpots) {
        if (pickerSettings == null) {
          return Empty();
        }

        var title = "";
        if (pickerSettings.isMulti) {
          title = Strings.of(context).fishingSpotListPageMultiPickerTitle;
        } else {
          title = Strings.of(context).fishingSpotListPageSinglePickerTitle;
        }

        return Text(title);
      },
      forceCenterTitle: pickerSettings == null,
      itemBuilder: (context, fishingSpot) {
        var latLngString = formatLatLng(
          context: context,
          lat: fishingSpot.lat,
          lng: fishingSpot.lng,
        );
        return ManageableListPageItemModel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryLabel(isNotEmpty(fishingSpot.name)
                  ? fishingSpot.name
                  : latLngString),
              isNotEmpty(fishingSpot.name)
                  ? SubtitleLabel(latLngString)
                  : Empty(),
            ],
          ),
        );
      },
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).fishingSpotListPageSearchHint,
      ),
      pickerSettings: pickerSettings,
      itemManager: ManageableListPageItemManager<FishingSpot>(
        listenerManagers: [fishingSpotManager],
        loadItems: (query) =>
            fishingSpotManager.listSortedByName(filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: Icons.place,
          title: Strings.of(context).fishingSpotListPageEmptyListTitle,
          description:
              Strings.of(context).fishingSpotListPageEmptyListDescription,
        ),
        deleteWidget: (context, fishingSpot) =>
            Text(fishingSpotManager.deleteMessage(context, fishingSpot)),
        deleteItem: (context, fishingSpot) =>
            fishingSpotManager.delete(fishingSpot.id),
        editPageBuilder: (fishingSpot) => SaveFishingSpotPage.edit(fishingSpot),
      ),
    );
  }
}
