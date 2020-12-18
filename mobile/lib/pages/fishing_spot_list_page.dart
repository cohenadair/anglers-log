import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_fishing_spot_page.dart';
import '../utils/string_utils.dart';
import '../widgets/text.dart';

class FishingSpotListPage extends StatelessWidget {
  final ManageableListPagePickerSettings<FishingSpot> pickerSettings;

  FishingSpotListPage({
    this.pickerSettings,
  });

  @override
  Widget build(BuildContext context) {
    var fishingSpotManager = FishingSpotManager.of(context);

    String title;
    if (pickerSettings?.isMulti ?? false) {
      title = Strings.of(context).fishingSpotListPageMultiPickerTitle;
    } else if (!(pickerSettings?.isMulti ?? false)) {
      title = Strings.of(context).fishingSpotListPageSinglePickerTitle;
    }

    return ManageableListPage<FishingSpot>(
      titleBuilder: isNotEmpty(title)
          ? (_) => Text(title)
          : (fishingSpots) {
              return Text(
                format(
                  Strings.of(context).fishingSpotListPageTitle,
                  [fishingSpots.length],
                ),
              );
            },
      forceCenterTitle: pickerSettings == null,
      itemBuilder: (context, fishingSpot) => ManageableListPageItemModel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryLabel(fishingSpot.name),
            SubtitleLabel(formatLatLng(
              context: context,
              lat: fishingSpot.lat,
              lng: fishingSpot.lng,
            )),
          ],
        ),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).fishingSpotListPageSearchHint,
      ),
      pickerSettings: pickerSettings,
      itemManager: ManageableListPageItemManager<FishingSpot>(
        listenerManagers: [fishingSpotManager],
        loadItems: (query) =>
            fishingSpotManager.listSortedByName(filter: query),
        deleteWidget: (context, fishingSpot) =>
            Text(fishingSpotManager.deleteMessage(context, fishingSpot)),
        deleteItem: (context, fishingSpot) =>
            fishingSpotManager.delete(fishingSpot.id),
        editPageBuilder: (fishingSpot) => SaveFishingSpotPage.edit(fishingSpot),
      ),
    );
  }
}
